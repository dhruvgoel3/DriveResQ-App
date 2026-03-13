const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Triggered on creation of a new document in the 'notifications' collection.
 * Routes to appropriate handler based on notification type.
 */
exports.processNotification = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const notificationId = context.params.notificationId;
    const data = snap.data();

    if (data.processed) {
      console.log(`Notification ${notificationId} is already processed.`);
      return null;
    }

    try {
      if (data.type === "new_request" && data.recipientId === null) {
        // Location-based broadcast to nearby mechanics
        await handleNearbyMechanicBroadcast(notificationId, data);
      } else if (data.type === "promotional" && data.recipientId === null) {
        // Broadcast to everyone
        await handleGlobalBroadcast(notificationId, data);
      } else if (data.recipientId) {
        // Send to targeted user
        await handleDirectNotification(notificationId, data);
      }

      // Mark as processed
      await snap.ref.update({
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Successfully processed notification ${notificationId}`);
    } catch (error) {
      console.error(`Error processing notification ${notificationId}:`, error);
      // Mark as processed even on error to prevent infinite retries
      await snap.ref.update({
        processed: true,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
        error: error.message || "Unknown error",
      });
    }
    return null;
  });

/**
 * Send FCM to nearby mechanics based on location.
 */
async function handleNearbyMechanicBroadcast(notificationId, data) {
  const centerLat = data.latitude;
  const centerLng = data.longitude;
  const radiusKm = data.radius || 20;

  // Query all approved mechanics
  const mechanicsSnap = await db
    .collection("users")
    .where("role", "==", "mechanic")
    .where("isApproved", "==", true)
    .get();

  const tokens = [];

  mechanicsSnap.forEach((doc) => {
    const mechData = doc.data();
    if (!mechData.fcmToken) return;

    // If mechanic has location, filter by distance
    if (
      mechData.location &&
      mechData.location.latitude &&
      mechData.location.longitude
    ) {
      const distanceKm = haversineDistance(
        centerLat,
        centerLng,
        mechData.location.latitude,
        mechData.location.longitude
      );
      if (distanceKm <= radiusKm) {
        tokens.push(mechData.fcmToken);
      }
    } else {
      // Fallback: send to all active mechanics with tokens
      tokens.push(mechData.fcmToken);
    }
  });

  if (tokens.length === 0) {
    console.log("No nearby mechanics found to notify.");
    return;
  }

  // FCM data values MUST all be strings
  const fcmData = stringifyData(data.data || {});

  const message = {
    notification: {
      title: data.title || "New Request",
      body: data.body || "A driver needs help nearby",
    },
    data: fcmData,
    android: {
      priority: "high",
      notification: {
        channelId: "driveresq_high_priority",
        priority: "max",
        defaultSound: true,
        defaultVibrateTimings: true,
      },
    },
    apns: {
      payload: {
        aps: {
          alert: {
            title: data.title || "New Request",
            body: data.body || "A driver needs help nearby",
          },
          sound: "default",
          badge: 1,
        },
      },
    },
  };

  // Send to all tokens (batched, max 500 per call)
  let successCount = 0;
  const batches = [];
  const tokensCopy = [...tokens];
  while (tokensCopy.length > 0) {
    batches.push(tokensCopy.splice(0, 500));
  }

  for (const batch of batches) {
    try {
      const response = await messaging.sendEachForMulticast({
        ...message,
        tokens: batch,
      });
      successCount += response.successCount;
      console.log(
        `Batch sent. Success: ${response.successCount}, Failed: ${response.failureCount}`
      );

      // Clean up invalid tokens
      response.responses.forEach((resp, idx) => {
        if (resp.error) {
          const errorCode = resp.error.code;
          if (
            errorCode === "messaging/invalid-registration-token" ||
            errorCode === "messaging/registration-token-not-registered"
          ) {
            console.log(`Removing invalid token for batch index ${idx}`);
          }
        }
      });
    } catch (err) {
      console.error("Multicast send error:", err);
    }
  }

  await db.collection("notifications").doc(notificationId).update({
    sentCount: successCount,
    totalTargets: tokens.length,
  });

  console.log(
    `Sent to ${successCount}/${tokens.length} mechanics for notification ${notificationId}`
  );
}

/**
 * Send FCM to a specific user by recipientId.
 */
async function handleDirectNotification(notificationId, data) {
  const userDoc = await db.collection("users").doc(data.recipientId).get();

  if (!userDoc.exists) {
    console.log(`Recipient ${data.recipientId} does not exist.`);
    return;
  }

  const userData = userDoc.data();
  const token = userData.fcmToken;

  if (!token) {
    console.log(`Recipient ${data.recipientId} has no FCM token.`);
    return;
  }

  // FCM data values MUST all be strings
  const fcmData = stringifyData(data.data || {});

  const message = {
    notification: {
      title: data.title || "Notification",
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
      },
    },
    apns: {
      payload: {
        aps: {
          alert: {
            title: data.title || "Notification",
            body: data.body || "",
          },
          sound: "default",
          badge: 1,
        },
      },
    },
  };

  try {
    await messaging.send(message);
    console.log(`Notification sent to user ${data.recipientId}`);

    await db.collection("notifications").doc(notificationId).update({
      sentCount: 1,
    });
  } catch (err) {
    console.error(`Failed to send to ${data.recipientId}:`, err);

    // Remove invalid tokens
    if (
      err.code === "messaging/invalid-registration-token" ||
      err.code === "messaging/registration-token-not-registered"
    ) {
      console.log(`Clearing invalid FCM token for user ${data.recipientId}`);
      await db.collection("users").doc(data.recipientId).update({
        fcmToken: admin.firestore.FieldValue.delete(),
      });
    }
  }
}

/**
 * Broadcast to all users with FCM tokens.
 */
async function handleGlobalBroadcast(notificationId, data) {
  const usersSnap = await db.collection("users").get();
  let tokens = [];

  usersSnap.forEach((doc) => {
    const userToken = doc.data().fcmToken;
    if (userToken) {
      tokens.push(userToken);
    }
  });

  if (tokens.length === 0) return;

  const fcmData = stringifyData(data.data || {});

  const batches = [];
  while (tokens.length > 0) {
    batches.push(tokens.splice(0, 500));
  }

  let successCount = 0;

  for (const batch of batches) {
    try {
      const response = await messaging.sendEachForMulticast({
        notification: {
          title: data.title,
          body: data.body,
        },
        data: fcmData,
        tokens: batch,
      });
      successCount += response.successCount;
    } catch (err) {
      console.error("Global broadcast error:", err);
    }
  }

  await db.collection("notifications").doc(notificationId).update({
    sentCount: successCount,
  });
}

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

    // Batch delete (max 500 per batch)
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

// ─── UTILITY FUNCTIONS ───

/**
 * Haversine formula to calculate distance between two lat/lng points in km.
 */
function haversineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth's radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

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
