# Push Notifications Testing Guide

Follow these steps to manually verify push notifications end-to-end between the driver and mechanic.

## Prerequisites

1. Two physical devices or emulators (e.g. Android Emulator & iOS Simulator). Note: iOS simulator requires iOS 16.4+ for push support natively.
2. Ensure you have deployed the Cloud Functions via `firebase deploy --only functions`.
3. Install the DriveResQ app on both devices.

---

## 🚙 Scenario 1: New Breakdown Request

1. **Setup**:
   - Device A logs in as a `mechanic`. Ensure Location is enabled and the app is backgrounded.
   - Device B logs in as a `driver`.
2. **Action**:
   - Driver (Device B) creates a new breakdown request simulating an emergency.
3. **Expected Result**:
   - A `new_request` notification document will be added to Firestore.
   - The Cloud Function (`processNotification`) will execute and calculate all active mechanics within 20km.
   - Device A will receive an FCM push alert: `"🚨 New Breakdown Request Nearby!"`.
   - Tapping it should route Device A to the active requests screen.

---

## 🛠️ Scenario 2: Mechanic Accepts Request

1. **Setup**:
   - Driver (Device B) keeps the app backgrounded.
2. **Action**:
   - Mechanic (Device A) taps **Accept Request** on the home dashboard.
3. **Expected Result**:
   - A `request_accepted` notification document will be added.
   - Driver (Device B) will receive a Push Alert: `"✅ Help is on the way!"`.
   - Driver will see the mechanic's name and distance routing him to the Active Track screen.

---

## 💬 Scenario 3: Realtime Chat Messages

1. **Setup**:
   - Device A creates a Chat Message to Device B.
   - Device B should have the app running in the background.
2. **Action**:
   - Mechanic (Device A) taps "Send Chat".
3. **Expected Result**:
   - The hook placed in `ChatService` will trigger `verifyChatMessage`.
   - Driver (Device B) receives a push with the chat message body.
   - Tapping it will open the Chat Screen immediately.

---

## 🎉 Scenario 4: Job Completed (Payment / Review)

1. **Setup**:
   - Active job is in progress. Driver app in background.
2. **Action**:
   - Mechanic (Device A) opens the Complete Job screen, fills in labor charges/payment, and marks Job Completed.
3. **Expected Result**:
   - A `job_completed` push is sent.
   - Driver (Device B) receives: `"🎉 Job Completed! Please review the work and rate your Mechanic."`.
4. **Action**:
   - Driver opens app and rates the mechanic (5 stars).
   - Mechanic receives push: `"⭐ New Rating! You received a new review."`

---

## 🔧 Troubleshooting Tips

- **No Push Notification Showing**:
  Verify the Device FCM token stored inside `users/{user_id}/fcmToken`. Check if the `flutter_local_notifications` channel was created.

- **Cloud Function Errors**:
  Go to Firebase Console -> **Functions** -> **Logs** to observe any execution failures, permission errors, or unbound project structures. Make sure you are on the **Blaze** plan for outgoing requests.

- **App Background State**:
  By default, `FirebaseMessaging.onMessage` fires while the app is foregrounded and displays a UI SnackBar or `flutter_local_notifications`. `FirebaseMessaging.onBackgroundMessage` runs a headless task. If developing on iOS, ensure background push capability is verified in Xcode.
