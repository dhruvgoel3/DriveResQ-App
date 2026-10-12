import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/chat_message.dart';

class ResQAssistantException implements Exception {
  final String message;
  const ResQAssistantException(this.message);

  @override
  String toString() => message;
}

class ResQAssistantService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

  ResQAssistantService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    http.Client? httpClient,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _httpClient = httpClient ?? http.Client();

  /// Retrieve OpenAI API Key from local environment
  String get _openAiApiKey {
    return dotenv.env['OPENAI_API_KEY'] ?? '';
  }

  /// Model configured in .env (defaults to gpt-4o-mini)
  String get _openAiModel {
    return dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';
  }

  static const String _safetySystemPrompt = '''
You are ResQ Assistant, an AI Roadside Safety and Guidance Companion embedded inside the DriveResQ mobile application.
Your core mission is to protect human life, keep stranded motorists calm, reduce panic, and provide safe, practical automotive guidance while waiting for roadside assistance or a verified DriveResQ mechanic.

LANGUAGE & HINGLISH COMMUNICATION (CRITICAL):
- You must fluently understand and speak both English and natural everyday conversational HINGLISH (Hindi written in Roman/English script, e.g., "Gaadi start nahi ho rahi", "Engine se dhua aa raha hai", "Tyre puncture ho gaya bhai", "Highway pe fas gaya hu kya karu?").
- If the user writes in Hindi or Hinglish, ALWAYS reply in friendly, clear, reassuring HINGLISH! (e.g., "Aap bilkul ghabraiye mat. Sabse pehle apni gaadi ki Hazard lights on karein aur road ke side safe jagah par chale jayein...").
- If the user writes in English, reply in English.
- If the user mixes Hindi & English, reply in natural conversational Hinglish.
- Keep the language simple, respectful, and easy to understand for any ordinary driver under stress.

STRICT SAFETY GUARDRAILS (HIGHEST PRIORITY):
1. ROADSIDE SAFETY FIRST / SADAK PE SURAKSHA:
   - First assess whether the user or vehicle is in a hazardous location (highway shoulder, blind curve, live lane, night traffic).
   - Instruct turning on hazard lights immediately ("Hazard warning lights turant on karein").
   - Move to a safe location away from moving traffic ("Moving traffic se door safe jagah par jayein").
   - On highways, tell the user to stand safely BEHIND a crash barrier or guardrail ("Highway pe metal crash barrier ya guardrail ke peeche khade rahein").
   - NEVER instruct the user to stand in front of, behind, or close to moving traffic.

2. IMMEDIATE DANGEROUS SITUATIONS (EMERGENCY OVERRIDE):
   - Smoke or Fire (Dhua ya Aag): Warn to evacuate all occupants immediately (at least 30-50m away). STRICTLY FORBID opening the hood ("Bonnet / hood bilkul mat kholna, aag bhadak sakti hai"). Call 112 emergency services immediately.
   - Overheating Engine with Steam: STRICTLY FORBID opening the radiator cap ("Radiator cap galti se bhi mat kholna, ubalta paani/steam jala sakti hai"). Wait for complete cooldown.
   - Fuel Leak or Strong Petrol/Diesel Smell: Warn to keep distance, avoid all sparks/cigarettes. Do not crank the engine.
   - Brake or Steering Failure: STRICTLY FORBID attempting to continue driving. Pull over safely, apply parking handbrake, and wait for flatbed tow.
   - High-Voltage EV Hazard: Never touch orange cables or damaged battery packs.

3. ALLOWED LOW-RISK GUIDANCE:
   - Check dashboard warning symbols and indicator lights.
   - Check if gear selector is firmly in Park (P) or Neutral (N) before starting.
   - Visually inspect tyre inflation from a safe, non-traffic stance.
   - Guide the driver on what symptoms to describe to the incoming mechanic.

4. STRICTLY PROHIBITED GUIDANCE (DO NOT INSTRUCT):
   - Never instruct an untrained user to crawl under a vehicle or use makeshift jacks.
   - Never instruct opening a hot cooling system or radiator cap.
   - Never instruct roadside repairs on the live traffic side.
   - Never encourage continuing to drive an unsafe or crippled vehicle.

5. TONE, ROLE & LIMITATIONS:
   - You are a reassuring roadside safety guide, not a substitute for certified mechanics.
   - Format answers cleanly with short bullet points and bold **WARNING / SAAVDHANI** notices.
''';

  /// Sends the driver's query directly to OpenAI API without requiring any Cloud Function.
  /// Also archives messages in Cloud Firestore under `users/{uid}/resq_chats`.
  Future<String> askAssistant({
    required String message,
    required List<ChatMessage> history,
    Map<String, dynamic>? context,
  }) async {
    final user = _auth.currentUser;
    final userId = user?.uid;

    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      throw const ResQAssistantException('Message cannot be empty.');
    }

    // Save user message to Firestore if authenticated (background, non-blocking)
    if (userId != null) {
      _saveMessageToFirestore(
        userId: userId,
        message: trimmedMessage,
        isUser: true,
      );
    }

    // Check API Key
    final apiKey = _openAiApiKey;
    if (apiKey.isEmpty) {
      // Offline safety fallback if API key is missing
      return _generateOfflineSafetyResponse(trimmedMessage, context);
    }

    // Build payload messages
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _safetySystemPrompt},
    ];

    if (context != null && context.isNotEmpty) {
      final buffer = StringBuffer('CURRENT ROADSIDE BREAKDOWN CONTEXT:');
      if (context['vehicleType'] != null) {
        buffer.write(' Vehicle Type: ${context['vehicleType']}.');
      }
      if (context['breakdownCategory'] != null) {
        buffer.write(' Problem: ${context['breakdownCategory']}.');
      }
      if (context['requestStatus'] != null) {
        buffer.write(' Status: ${context['requestStatus']}.');
      }
      messages.add({'role': 'system', 'content': buffer.toString()});
    }

    // Add recent conversation history (last 6 messages)
    for (final m in history.take(6)) {
      messages.add({
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text.length > 500 ? m.text.substring(0, 500) : m.text,
      });
    }

    // Add current user message
    messages.add({
      'role': 'user',
      'content': trimmedMessage,
    });

    try {
      final response = await _httpClient
          .post(
            Uri.parse('https://api.openai.com/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': _openAiModel,
              'messages': messages,
              'temperature': 0.3,
              'max_tokens': 500,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final replyText = choices[0]['message']?['content']?.toString().trim();
          if (replyText != null && replyText.isNotEmpty) {
            // Save assistant response to Firestore
            if (userId != null) {
              _saveMessageToFirestore(
                userId: userId,
                message: replyText,
                isUser: false,
              );
            }
            return replyText;
          }
        }
        return '⚠️ **Safety First**: Please stay in a safe location away from moving traffic and wait for your mechanic.';
      }

      if (response.statusCode == 429) {
        return _generateOfflineSafetyResponse(
          trimmedMessage,
          context,
          notice: '*(AI service is busy, providing direct roadside safety precautions)*\n\n',
        );
      }

      // If OpenAI returned an error, fallback gracefully to instant safety knowledge
      return _generateOfflineSafetyResponse(trimmedMessage, context);
    } on SocketException {
      return _generateOfflineSafetyResponse(
        trimmedMessage,
        context,
        notice: '*(Offline Mode - Safety Guide)*\n\n',
      );
    } on http.ClientException {
      return _generateOfflineSafetyResponse(trimmedMessage, context);
    } on TimeoutException {
      return _generateOfflineSafetyResponse(
        trimmedMessage,
        context,
        notice: '*(Quick Response Guide)*\n\n',
      );
    } catch (_) {
      return _generateOfflineSafetyResponse(trimmedMessage, context);
    }
  }

  /// Saves chat messages into Cloud Firestore without needing any Cloud Function
  void _saveMessageToFirestore({
    required String userId,
    required String message,
    required bool isUser,
  }) {
    try {
      _firestore
          .collection('users')
          .doc(userId)
          .collection('resq_chats')
          .add({
        'text': message,
        'isUser': isUser,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Non-blocking firestore sync
    }
  }

  /// Instant offline roadside safety responses for common emergencies (English & Hinglish)
  String _generateOfflineSafetyResponse(
    String query,
    Map<String, dynamic>? context, {
    String notice = '',
  }) {
    final lower = query.toLowerCase();

    // Fire / Smoke (English + Hinglish)
    if (lower.contains('smoke') ||
        lower.contains('fire') ||
        lower.contains('burn') ||
        lower.contains('dhuan') ||
        lower.contains('dhua') ||
        lower.contains('aag')) {
      return '$notice🚨 **EMERGENCY / SAAVDHANI: TURANT BAHAR NIKLEIN**\n\n'
          '• **BONNET / HOOD BILKUL MAT KHOLNA**: Hawa milne se aag aur tez bhadak sakti hai.\n'
          '• Sabhi logon ko gaadi se nikaal kar kam se kam **50 meter door** le jayein.\n'
          '• Turant Emergency number (**112**) par call karein.\n'
          '• Gaadi ke andar se saamaan nikaalne ke chakkar me bilkul na padein.';
    }

    // Overheating (English + Hinglish)
    if (lower.contains('overheat') ||
        lower.contains('steam') ||
        lower.contains('coolant') ||
        lower.contains('garam') ||
        lower.contains('heat') ||
        lower.contains('temperature')) {
      return '$notice⚠️ **WARNING: ENGINE OVERHEATING / ENGINE GARAM**\n\n'
          '• **RADIATOR CAP KABHI MAT KHOLNA**: Pressurized ubalta paani aur steam aapka haath aur chehra jala sakti hai.\n'
          '• Gaadi ko side me rokein, Hazard lights on karein, aur engine band karein.\n'
          '• Kam se kam 30-40 minute engine ko thanda hone dein.\n'
          '• DriveResQ mechanic ke aane ka intezar karein, wo cooling system check karenge.';
    }

    // Flat Tyre / Puncture (English + Hinglish)
    if (lower.contains('flat') ||
        lower.contains('tyre') ||
        lower.contains('tire') ||
        lower.contains('puncture') ||
        lower.contains('pahiya') ||
        lower.contains('hawa') ||
        lower.contains('chakka')) {
      return '$notice🚗 **FLAT TYRE / PUNCTURE SURAKSHA TIPS**\n\n'
          '• **Hazard lights on karein** aur gaadi ko plain/solid zameen par lagayein.\n'
          '• Active highway traffic ki taraf khade hokar tyre change karne ki galti na karein.\n'
          '• Agar highway par hain, toh metal guardrail/barrier ke peeche khade rahein.\n'
          '• Verified DriveResQ mechanic proper hydraulic jack aur tools ke sath jaldi pahunchenge.';
    }

    // Starting trouble / Battery (English + Hinglish)
    if (lower.contains('start') ||
        lower.contains('battery') ||
        lower.contains('crank') ||
        lower.contains('dead') ||
        lower.contains('band') ||
        lower.contains('nahi ho rahi') ||
        lower.contains('chalu')) {
      return '$notice🔋 **GAADI START NAHI HO RAHI - QUICK CHECK**\n\n'
          '• Check karein automatic gaadi **Park (P)** ya manual gaadi **Neutral (N)** me clutch/brake ke sath hai.\n'
          '• Headlights ya horn on karke dekhein – agar lights bohot dim hain ya horn halka hai, toh battery discharge ho sakti hai.\n'
          '• Baar-baar lamba self/crank na marein, isse battery aur starter kharab ho sakte hain.\n'
          '• Agar battery phooli hui ya leakage hai, toh jump-start bilkul na karein. Mechanic jump pack ke sath aayenge.';
    }

    // Highway breakdown (English + Hinglish)
    if (lower.contains('highway') ||
        lower.contains('freeway') ||
        lower.contains('expressway') ||
        lower.contains('road') ||
        lower.contains('sadak') ||
        lower.contains('ruk gayi')) {
      return '$notice🛣️ **HIGHWAY BREAKDOWN SAFETY RULES**\n\n'
          '• Turant **Hazard warning lights (double indicators)** on karein.\n'
          '• Gaadi ko extreme left shoulder par lagayein aur Handbrake kheench lein.\n'
          '• **Sabse zaroori**: Left side ke darwaze se bahar nikal kar metal crash barrier ke peeche khade rahein.\n'
          '• Highway pe gaadi ke aage ya peeche khade rehna behad khatarnaak hota hai.\n'
          '• Barrier ke peeche safe rehkar mechanic ka intezar karein.';
    }

    return '$notice🛡️ **ROADSIDE SAFETY GUIDANCE (SAAVDHANI)**\n\n'
        '• Apni gaadi ki **Hazard lights** on rakhein taaki doosri gaadiyon ko door se dikhe.\n'
        '• Sabhi logo ko road/traffic se door kisi surakshit jagah par le jayein.\n'
        '• Phone battery bachayein aur mechanic se update lete rahein.\n'
        '• Dashboard pe jo bhi indicator/warning light aa rahi ho, mechanic ko zaroor batayein.';
  }

  void dispose() {
    _httpClient.close();
  }
}
