const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Triggered on creation of a new document in the 'notifications' collection.
 * Every notification now has a recipientId, so we just send to that user.
 */
exports.processNotification = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const notificationId = context.params.notificationId;
    const data = snap.data();

    if (data.processed) {
      console.log(`Notification ${notificationId} already processed.`);
      return null;
    }

    try {
      const recipientId = data.recipientId;

      if (!recipientId) {
        console.log(
          `Notification ${notificationId} has no recipientId, skipping.`
        );
        await snap.ref.update({
          processed: true,
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return null;
      }

      // Look up the recipient's FCM token
      const userDoc = await db.collection("users").doc(recipientId).get();
      if (!userDoc.exists) {
        console.log(`Recipient ${recipientId} does not exist.`);
        await snap.ref.update({
          processed: true,
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return null;
      }

      const userData = userDoc.data();
      const token = userData.fcmToken;

      if (!token) {
        console.log(`Recipient ${recipientId} has no FCM token.`);
        await snap.ref.update({
          processed: true,
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return null;
      }

      // Build the FCM payload
      const fcmData = stringifyData(data.data || {});

      const message = {
        notification: {
          title: data.title || "DriveResQ",
          body: data.body || "",
        },
        data: fcmData,
        token: token,
        android: {
          priority: "high",
          notification: {
            channelId: "driveresq_high_priority",
            priority: "max",
            defaultSound: true,
            defaultVibrateTimings: true,
            notificationCount: 1,
          },
        },
        apns: {
          headers: {
            "apns-priority": "10",
          },
          payload: {
            aps: {
              alert: {
                title: data.title || "DriveResQ",
                body: data.body || "",
              },
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      await messaging.send(message);
      console.log(`Notification sent to ${recipientId} (type: ${data.type})`);

      await snap.ref.update({
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        sentCount: 1,
      });
    } catch (error) {
      console.error(
        `Error processing notification ${notificationId}:`,
        error
      );

      // Clean up invalid tokens
      if (
        error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
      ) {
        const recipientId = data.recipientId;
        if (recipientId) {
          console.log(`Clearing invalid FCM token for ${recipientId}`);
          await db.collection("users").doc(recipientId).update({
            fcmToken: admin.firestore.FieldValue.delete(),
          });
        }
      }

      await snap.ref.update({
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        error: error.message || "Unknown error",
      });
    }

    return null;
  });

/**
 * Cleanup old notifications (older than 30 days).
 * Runs every day at 2:00 AM IST.
 */
exports.cleanupOldNotifications = functions.pubsub
  .schedule("0 2 * * *")
  .timeZone("Asia/Kolkata")
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const snap = await db
      .collection("notifications")
      .where(
        "createdAt",
        "<",
        admin.firestore.Timestamp.fromDate(thirtyDaysAgo)
      )
      .get();

    if (snap.empty) {
      console.log("No old notifications to clean up.");
      return null;
    }

    const docs = snap.docs;
    const batchSize = 500;
    for (let i = 0; i < docs.length; i += batchSize) {
      const batch = db.batch();
      const chunk = docs.slice(i, i + batchSize);
      chunk.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    }

    console.log(`Cleaned up ${snap.size} old notifications.`);
    return null;
  });

// ─── UTILITY ───

/**
 * Convert all values in a data object to strings (FCM requirement).
 */
function stringifyData(obj) {
  const result = {};
  for (const [key, value] of Object.entries(obj)) {
    if (value === null || value === undefined) {
      result[key] = "";
    } else if (typeof value === "object") {
      result[key] = JSON.stringify(value);
    } else {
      result[key] = String(value);
    }
  }
  return result;
}
