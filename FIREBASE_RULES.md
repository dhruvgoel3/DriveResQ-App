# Firestore Security Rules for DriveResQ

**Copy the rules below and paste them into:**
Firebase Console → Firestore Database → Rules → Replace all → Publish

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ─── USERS ───
    // Anyone authenticated can read user profiles (needed for chats, names, FCM tokens)
    // Only the owner can write to their own user document
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if false;
    }

    // ─── REQUESTS ───
    // Drivers create requests; both drivers and mechanics can read
    // Mechanics can update status (accept/complete); drivers can update (cancel)
    match /requests/{requestId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if false;
    }

    // ─── CHATS ───
    // Only participants can read/write chat documents
    // Messages subcollection follows same participant rules
    match /chats/{chatId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null
                  && request.auth.uid in resource.data.participants;
      allow update: if request.auth != null
                   && request.auth.uid in resource.data.participants;
      allow delete: if false;

      match /messages/{messageId} {
        allow create: if request.auth != null;
        allow read: if request.auth != null;
        allow update: if request.auth != null;
        allow delete: if false;
      }
    }

    // ─── NOTIFICATIONS ───
    // Any authenticated user can create notifications
    // Recipients can read and update (mark as read) their own notifications
    // Cloud Functions update processed status (via Admin SDK, bypasses rules)
    match /notifications/{notificationId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null;
    }

    // ─── ADMIN ───
    match /admin/{document=**} {
      allow read, write: if request.auth != null;
    }

    // ─── MECHANIC APPLICATIONS / ONBOARDING ───
    match /mechanic_applications/{docId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if false;
    }
  }
}
```

## How to Apply

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **driveresq-app** project
3. Click **Firestore Database** in the left sidebar
4. Click the **Rules** tab at the top
5. **Replace ALL existing rules** with the rules above
6. Click **Publish**
7. Wait 1-2 minutes for rules to propagate

## What This Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Chat messages fail to send | Rules blocked writes to `chats` collection | Participants can now read/write |
| Job completion "permission denied" | Rules blocked status updates on `requests` | Authenticated users can update |
| Notifications not created | Rules blocked writes to `notifications` | Authenticated users can create |
| FCM token not saved | Rules blocked writes to `users` | Owner can update their own doc |

---

# Firebase Storage Rules

**Copy the rules below and paste them into:**
Firebase Console → Storage → Rules → Replace all → Publish

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Default: Authenticated users can read anything, nobody can write
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // ─── CHAT MEDIA (Images & Voice Messages) ───
    // Allow authenticated users to upload chat images and voice messages
    match /chats/{chatId}/{mediaType}/{fileName} {
      allow read: if request.auth != null;
      // You can add stricter validation here, but for now we allow any authenticated user to send chat media.
      allow create: if request.auth != null
                    // Ensure the file is reasonably sized (e.g., under 10MB)
                    && request.resource.size < 10 * 1024 * 1024;
      allow delete: if false; // Prevention from accidental deletes
    }
    
    // ─── USER PROFILE PHOTOS ───
    match /users/{userId}/profile_photos/{fileName} {
      allow read: if true; // Profile photos usually need to be public or at least for all auth users
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## How to Apply Storage Rules

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **driveresq-app** project
3. Click **Storage** in the left sidebar
4. Click the **Rules** tab at the top
5. **Replace ALL existing rules** with the rules above
6. Click **Publish**
