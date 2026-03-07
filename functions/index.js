const functions = require("firebase-functions");
const admin = require("firebase-admin");
const geofire = require("geofire-common");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Triggered on creation of a new document in the 'notifications' collection.
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
      } else if (data.recipientId !== null) {
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
    }
    return null;
  });

async function handleNearbyMechanicBroadcast(notificationId, data) {
  const center = [data.latitude, data.longitude];
  const radiusInM = (data.radius || 20) * 1000;

  // We find mechanics using geofire-common bounds logic if mechanics store geohashes.
  // Alternatively, querying all mechanics and calculating distance or using a simpler approach based on app structure:
  // Assuming a 'users' collection where role == 'mechanic' and status == 'active'
  // For production reliability with geofire, mechanics must register a 'geohash' field on location update.
  
  // Here we do a bounding box query approach via geofire if available, or fallback to all active mechanics
  // To keep it safe and functional based on provided setup: Let's fetch active mechanics and filtering tokens:
  
  const mechanicsSnap = await db.collection("users")
    .where("role", "==", "mechanic")
    .where("isApproved", "==", true)
    .where("isOnline", "==", true) // You might have an online flag
    .get();

  const tokens = [];
  
  mechanicsSnap.forEach(doc => {
      const mechData = doc.data();
      // Calculate distance if coordinates are present
      if (mechData.location && mechData.location.latitude && mechData.location.longitude) {
         const distanceInKm = geofire.distanceBetween(
           [mechData.location.latitude, mechData.location.longitude], 
           center
         );
         
         if (distanceInKm <= (data.radius || 20)) {
           if (mechData.fcmToken) {
             tokens.push(mechData.fcmToken);
           }
         }
      } else {
        // Fallback: If no strict location tracking, just send to active mechanics with tokens
        if (mechData.fcmToken) {
             tokens.push(mechData.fcmToken);
        }
      }
  });

  if (tokens.length === 0) {
    console.log("No nearby mechanics found to notify.");
    return;
  }

  const message = {
    notification: {
      title: data.title,
      body: data.body,
    },
    data: data.data || {},
    tokens: tokens,
  };

  const response = await messaging.sendMulticast(message);
  console.log(`Sent multicast. Success: ${response.successCount}, Failed: ${response.failureCount}`);
  
  await db.collection("notifications").doc(notificationId).update({
      sentCount: response.successCount,
  });
}

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

  const message = {
    notification: {
      title: data.title,
      body: data.body,
    },
    data: data.data || {},
    token: token,
  };

  await messaging.send(message);
  
  await db.collection("notifications").doc(notificationId).update({
      sentCount: 1,
  });
}

async function handleGlobalBroadcast(notificationId, data) {
    const usersSnap = await db.collection("users").get();
    let tokens = [];
    
    usersSnap.forEach(doc => {
       const userToken = doc.data().fcmToken;
       if (userToken) {
           tokens.push(userToken);
       }
    });

    if (tokens.length === 0) return;

    // Firebase Multicast limits to 500 tokens per batch
    const batches = [];
    while (tokens.length > 0) {
        batches.push(tokens.splice(0, 500));
    }

    let successCount = 0;
    
    for (const batch of batches) {
        const message = {
            notification: {
                title: data.title,
                body: data.body,
            },
            data: data.data || {},
            tokens: batch,
        };
        const res = await messaging.sendMulticast(message);
        successCount += res.successCount;
    }

    await db.collection("notifications").doc(notificationId).update({
        sentCount: successCount,
    });
}

/**
 * Cleanup old notifications (older than 30 days)
 * Runs every day at 2:00 AM
 */
exports.cleanupOldNotifications = functions.pubsub.schedule("0 2 * * *").onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const snap = await db.collection("notifications")
      .where("createdAt", "<", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
      .get();
      
    if (snap.empty) {
      console.log("No old notifications to clean up.");
      return null;
    }

    const batch = db.batch();
    snap.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    console.log(`Cleaned up ${snap.size} old notifications.`);
    return null;
});
