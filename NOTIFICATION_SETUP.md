# FCM Notification Setup Guide

This guide explains how to properly set up Firebase Cloud Messaging (FCM) for the DriveResQ app so that the recently integrated Cloud Functions and Push Notifications work smoothly.

## 1. Firebase Project Configuration

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Select the `DriveResQ` project.
3. Navigate to **Project Settings > Cloud Messaging**.
4. Ensure **Firebase Cloud Messaging API (V1)** is enabled.

## 2. Cloud Functions Initialization

For Cloud Functions to interact with your Firebase project and send FCM messages securely, you need to set up the correct permissions and run the deploy commands.

1. Navigate to the `functions` directory in your terminal:
   ```bash
   cd functions
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Authenticate with Firebase CLI:
   ```bash
   firebase login
   ```
4. Map the functions to your project:
   ```bash
   firebase use --add
   ```
   Select your DriveResQ project.

5. Deploy the Cloud Functions:
   ```bash
   firebase deploy --only functions
   ```

## 3. iOS Configuration Setup (APNs)

If you intend to build this app for iOS devices:

1. Go to the Apple Developer Portal.
2. Create an **APNs Authentication Key** (`.p8` file).
3. Go back to your Firebase Console > Project Settings > Cloud Messaging.
4. Upload your APNs Authentication Key under the **Apple app configuration** section.
5. In Xcode, ensure that **Background Modes** (Remote notifications) and **Push Notifications** capabilities are enabled for your app.

## 4. Testing End-to-End

Once deployed, the `processNotification` trigger will actively listen for new documents in the `notifications` Firestore collection. 

When you test the app (see `NOTIFICATION_TESTING.md` for steps), the Flutter app will log the device token to `users/{uid}/fcmToken`.
The functions will use `firebase-admin` to fetch this token and dispatch the actual push delivery.

**Important Note**: Cloud functions run on the `Pay as you go (Blaze)` plan in Firebase. Ensure your project is upgraded to Blaze to support Cloud Functions deployment and external network requests to FCM servers.
