import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact_model.dart';

/// Manages CRUD for emergency contacts stored in Firestore with local SharedPreferences cache.
///
/// Schema:
///   `emergency_contacts/{driverId}/contacts/{contactId}`
///
/// Security:
///   Only the authenticated driver can read/write their own contacts.
class EmergencyContactService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;
  static const String _cachePrefix = 'sos_emergency_contacts_';

  static CollectionReference<Map<String, dynamic>> _contactsRef(String driverId) {
    return _firestore
        .collection('emergency_contacts')
        .doc(driverId)
        .collection('contacts');
  }

  // ─── Local SharedPreferences Cache Helpers ─────────────────────────────────

  static Future<void> _saveToCache(String uid, List<EmergencyContact> contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = contacts.map((c) => c.toJson()).toList();
      await prefs.setString('$_cachePrefix$uid', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('EmergencyContactService._saveToCache error: $e');
    }
  }

  static Future<List<EmergencyContact>> getCachedContacts([String? uid]) async {
    final targetUid = uid ?? _uid;
    if (targetUid == null) return [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_cachePrefix$targetUid');
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => EmergencyContact.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      debugPrint('EmergencyContactService.getCachedContacts error: $e');
      return [];
    }
  }

  // ─── Real-time Watching ───────────────────────────────────────────────────

  /// Stream of emergency contacts for the authenticated driver.
  /// Emits cached contacts first (for instant offline/restart display), then syncs live from Firestore.
  static Stream<List<EmergencyContact>> watchContacts() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    late StreamController<List<EmergencyContact>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? firestoreSub;

    controller = StreamController<List<EmergencyContact>>.broadcast(
      onListen: () async {
        // 1. Emit cached contacts immediately
        final cached = await getCachedContacts(uid);
        if (cached.isNotEmpty && !controller.isClosed) {
          controller.add(cached);
        }

        // 2. Listen to Firestore
        firestoreSub = _contactsRef(uid)
            .orderBy('createdAt')
            .snapshots()
            .listen(
          (snap) {
            final contacts = snap.docs
                .map((doc) => EmergencyContact.fromMap(doc.data(), docId: doc.id))
                .toList();
            _saveToCache(uid, contacts);
            if (!controller.isClosed) {
              controller.add(contacts);
            }
          },
          onError: (Object err) async {
            debugPrint('EmergencyContactService Firestore stream error: $err');
            // If offline or permission issue, fallback to cache
            final fallback = await getCachedContacts(uid);
            if (!controller.isClosed) {
              if (fallback.isNotEmpty) {
                controller.add(fallback);
              } else {
                controller.addError(err);
              }
            }
          },
        );
      },
      onCancel: () {
        firestoreSub?.cancel();
      },
    );

    return controller.stream;
  }

  /// Fetch all contacts once (online with local cache fallback).
  static Future<List<EmergencyContact>> fetchContacts() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final snap = await _contactsRef(uid).orderBy('createdAt').get();
      final contacts = snap.docs
          .map((doc) => EmergencyContact.fromMap(doc.data(), docId: doc.id))
          .toList();
      await _saveToCache(uid, contacts);
      return contacts;
    } catch (e) {
      debugPrint('EmergencyContactService.fetchContacts Firestore error: $e');
      return getCachedContacts(uid);
    }
  }

  /// Fetch only enabled contacts.
  static Future<List<EmergencyContact>> fetchEnabledContacts() async {
    final contacts = await fetchContacts();
    return contacts.where((c) => c.isEnabled).toList();
  }

  /// Add a new emergency contact. Returns the new contact ID.
  static Future<String> addContact({
    required String name,
    required String phone,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('Driver authentication required. Please sign in to manage safety contacts.');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Please enter a valid contact name.');
    }

    final normalizedPhone = normalizePhone(phone);
    validatePhone(normalizedPhone);
    await _checkDuplicate(uid, normalizedPhone);

    final now = DateTime.now();
    final contact = EmergencyContact(
      id: '',
      name: trimmedName,
      phone: normalizedPhone,
      isEnabled: true,
      createdAt: now,
      updatedAt: now,
    );

    try {
      final docRef = await _contactsRef(uid).add(contact.toMap());
      final newContact = contact.copyWith();
      final savedContact = EmergencyContact(
        id: docRef.id,
        name: newContact.name,
        phone: newContact.phone,
        isEnabled: newContact.isEnabled,
        createdAt: newContact.createdAt,
        updatedAt: newContact.updatedAt,
      );

      // Update cache
      final currentList = await getCachedContacts(uid);
      currentList.add(savedContact);
      await _saveToCache(uid, currentList);

      return docRef.id;
    } on FirebaseException catch (e) {
      debugPrint('Firestore error adding contact: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        throw Exception('Cloud security error. Please make sure you are signed in.');
      }
      throw Exception('Could not save contact: ${e.message ?? e.code}');
    }
  }

  /// Update an existing contact by [contactId].
  static Future<void> updateContact(EmergencyContact contact) async {
    final uid = _uid;
    if (uid == null) throw Exception('Driver authentication required.');

    final normalizedPhone = normalizePhone(contact.phone);
    validatePhone(normalizedPhone);

    final updated = contact.copyWith(
      phone: normalizedPhone,
      updatedAt: DateTime.now(),
    );

    try {
      await _contactsRef(uid).doc(contact.id).update(updated.toMap());

      // Update local cache
      final list = await getCachedContacts(uid);
      final idx = list.indexWhere((c) => c.id == contact.id);
      if (idx != -1) {
        list[idx] = updated;
        await _saveToCache(uid, list);
      }
    } on FirebaseException catch (e) {
      throw Exception('Could not update contact: ${e.message ?? e.code}');
    }
  }

  /// Toggle enabled/disabled state.
  static Future<void> toggleContact(String contactId, bool enabled) async {
    final uid = _uid;
    if (uid == null) throw Exception('Driver authentication required.');
    final now = DateTime.now();

    try {
      await _contactsRef(uid).doc(contactId).update({
        'isEnabled': enabled,
        'updatedAt': Timestamp.fromDate(now),
      });

      // Update local cache
      final list = await getCachedContacts(uid);
      final idx = list.indexWhere((c) => c.id == contactId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(isEnabled: enabled, updatedAt: now);
        await _saveToCache(uid, list);
      }
    } on FirebaseException catch (e) {
      throw Exception('Could not toggle contact: ${e.message ?? e.code}');
    }
  }

  /// Delete a contact.
  static Future<void> deleteContact(String contactId) async {
    final uid = _uid;
    if (uid == null) throw Exception('Driver authentication required.');

    try {
      await _contactsRef(uid).doc(contactId).delete();

      // Update local cache
      final list = await getCachedContacts(uid);
      list.removeWhere((c) => c.id == contactId);
      await _saveToCache(uid, list);
    } on FirebaseException catch (e) {
      throw Exception('Could not delete contact: ${e.message ?? e.code}');
    }
  }

  // ─── Validation & Formatting ──────────────────────────────────────────────

  /// Normalize phone string into standard E.164-compatible format.
  static String normalizePhone(String raw) {
    String cleaned = raw.replaceAll(RegExp(r'[\s\-().]'), '');
    if (!cleaned.startsWith('+')) {
      if (cleaned.length == 10 && RegExp(r'^[6-9]').hasMatch(cleaned)) {
        cleaned = '+91$cleaned';
      } else {
        cleaned = '+$cleaned';
      }
    }
    return cleaned;
  }

  /// Validate normalized phone string.
  static void validatePhone(String phone) {
    final regex = RegExp(r'^\+[0-9]{7,15}$');
    if (!regex.hasMatch(phone)) {
      throw Exception(
        'Invalid phone number format. Please enter a valid 10-digit number or international format (e.g. +919876543210).',
      );
    }
  }

  static Future<void> _checkDuplicate(String uid, String phone) async {
    try {
      final snap = await _contactsRef(uid).where('phone', isEqualTo: phone).limit(1).get();
      if (snap.docs.isNotEmpty) {
        throw Exception('An emergency contact with this phone number already exists.');
      }
    } catch (_) {
      // Also check local cache for duplicates
      final cached = await getCachedContacts(uid);
      if (cached.any((c) => c.phone == phone)) {
        throw Exception('An emergency contact with this phone number already exists.');
      }
    }
  }
}
