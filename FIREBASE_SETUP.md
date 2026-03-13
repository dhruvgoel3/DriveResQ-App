# Firebase Setup & Deployment Guide for DriveResQ

## 1. Apply Firestore Security Rules (CRITICAL)

This is the **#1 fix** for chat and job completion "permission denied" errors.

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select **driveresq-app** project
3. Go to **Firestore Database** → **Rules** tab
4. Replace ALL rules with the content from [FIREBASE_RULES.md](./FIREBASE_RULES.md)
5. Click **Publish**

---

## 2. Deploy Cloud Functions

```bash
# Install Firebase CLI (one time)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install function dependencies
cd functions
npm install
cd ..

# Deploy
firebase deploy --only functions

# Verify deployment
firebase functions:list
```

### Troubleshooting Deployment

```bash
# View function logs
firebase functions:log --only processNotification

# Live tail logs
firebase functions:log --follow

# Check for errors
firebase functions:log --only processNotification --limit 20
```

> **Note:** Cloud Functions require the **Blaze plan** (pay-as-you-go). First 2M invocations/month are **FREE**.

---

## 3. Test the Notification System

### Step 1: Verify FCM Token Saved
1. Login to the app
2. Open Firebase Console → Firestore → `users` collection
3. Find your user document
4. Confirm `fcmToken` field exists (long string starting with `f` or `d`)

### Step 2: Test Chat Messages
1. Login as **driver** on Device A, create a request
2. Login as **mechanic** on Device B, accept the request
3. Open the chat → Send messages from both sides
4. Messages should appear in real-time

### Step 3: Test Job Completion
1. As mechanic, tap "Complete Job"
2. Enter the 6-digit verification code (visible to driver)
3. Should complete without "permission denied"

### Step 4: Test Notification Bell
1. Open driver or mechanic dashboard
2. Look for 🔔 bell icon in top-right
3. Tap it → Opens notifications screen
4. Unread count badge appears on the bell

### Step 5: Test Push Notifications
1. **Foreground**: Keep app open → Trigger notification → Banner appears
2. **Background**: Press home → Trigger notification → System tray notification
3. **Terminated**: Close app → Trigger notification → Tap opens app

---

## 4. Firebase Console Checklist

- [ ] Firestore Rules published from `FIREBASE_RULES.md`
- [ ] Cloud Functions deployed (`firebase deploy --only functions`)
- [ ] Cloud Messaging enabled (Project Settings → Cloud Messaging)
- [ ] `google-services.json` in `android/app/`
- [ ] `GoogleService-Info.plist` in `ios/Runner/`

---

## 5. iOS Additional Setup (if building for iOS)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target → **Signing & Capabilities**
3. Click **+ Capability** → Add **Push Notifications**
4. Click **+ Capability** → Add **Background Modes**
5. Check **Remote notifications** in Background Modes
