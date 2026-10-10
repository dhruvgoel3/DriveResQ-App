# Firestore Security Rules for DriveResQ

**Copy the rules below and paste them into:**
Firebase Console → Firestore Database → Rules → Replace all → Publish

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is an admin
    function isAdmin() {
      return request.auth != null &&
        (exists(/databases/$(database)/documents/admin/$(request.auth.uid)) ||
         exists(/databases/$(database)/documents/adminUsers/$(request.auth.uid)));
    }

    // ─── USERS ───
    // Anyone authenticated can read user profiles (needed for chats, names, FCM tokens)
    // Only the owner can write to their own user document, or admin
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && (request.auth.uid == userId || isAdmin());
      allow delete: if false;
    }

    // ─── REQUESTS ───
    // Drivers create requests; both drivers and mechanics can read and update
    match /requests/{requestId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null;
    }

    // ─── COMPLETED JOBS ───
    match /completedJobs/{jobId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if false;
    }

    // ─── CHATS & MESSAGES ───
    match /chats/{chatId} {
      allow create, read, update: if request.auth != null;
      allow delete: if false;

      match /messages/{messageId} {
        allow create, read, update: if request.auth != null;
        allow delete: if false;
      }
    }

    // ─── NOTIFICATIONS ───
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
    match /adminUsers/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /adminSettings/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /adminActions/{document=**} {
      allow read, write: if isAdmin();
    }
    match /mail/{document=**} {
      allow create, read, write: if request.auth != null;
    }

    // ─── MECHANIC APPLICATIONS / ONBOARDING ───
    match /mechanic_applications/{docId} {
      allow create, read, update: if request.auth != null;
      allow delete: if false;
    }
  }
}
```

---

## What to Check in Firebase Console

1. **Firestore Database Rules**:
   - Go to **Firestore Database** → **Rules**
   - Paste the rules above and click **Publish**.

2. **Firestore Indexes**:
   - Go to **Firestore Database** → **Indexes**
   - Composite indexes needed:
     - Collection: `requests`, Fields: `status` (Ascending) + `driverLat` (Ascending)
     - Collection: `notifications`, Fields: `recipientId` (Ascending) + `createdAt` (Descending)
     - Collection: `notifications`, Fields: `recipientId` (Ascending) + `isRead` (Ascending)

3. **Storage Rules**:
   - Go to **Storage** → **Rules**
   - Ensure authenticated users can upload documents and photos:
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
