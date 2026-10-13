const functions = require("firebase-functions");
const admin = require("firebase-admin");
// Firebase Functions v4+ natively reads functions/.env at deployment time.
// No dotenv package needed — process.env.OPENAI_API_KEY is available automatically.

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

// ─── RESQ ASSISTANT AI SAFETY CHATBOT ───

// In-memory sliding window rate limiting (15 requests/minute per UID)
const userRateLimits = new Map();

function isRateLimited(uid) {
  const now = Date.now();
  const windowMs = 60 * 1000;
  const maxRequests = 15;

  let timestamps = userRateLimits.get(uid) || [];
  timestamps = timestamps.filter((t) => now - t < windowMs);

  if (timestamps.length >= maxRequests) {
    userRateLimits.set(uid, timestamps);
    return true;
  }

  timestamps.push(now);
  userRateLimits.set(uid, timestamps);

  // Periodically clean up old entries
  if (userRateLimits.size > 2000) {
    for (const [key, list] of userRateLimits.entries()) {
      if (list.length === 0 || now - list[list.length - 1] > windowMs * 2) {
        userRateLimits.delete(key);
      }
    }
  }

  return false;
}

const RESQ_SAFETY_SYSTEM_PROMPT = `You are ResQ Assistant, an AI Roadside Safety Guide for the DriveResQ breakdown app.
Your highest and non-negotiable mission is DRIVER & PASSENGER SAFETY, NOT complex mechanical repairs.
You provide calm, clear, low-risk guidance to stranded motorists while they wait for certified roadside mechanics or emergency services.

STRICT SAFETY GUARDRAILS (HIGHEST PRIORITY):
1. ROADSIDE SAFETY FIRST:
   - First assess whether the user or vehicle is in a hazardous location (highway shoulder, blind curve, live lane, night traffic).
   - Instruct the driver to move to a safe location away from moving traffic if they can do so safely.
   - Instruct turning on hazard lights immediately.
   - On highways, tell the user to stand safely BEHIND a crash barrier or guardrail, up on the embankment, away from the roadway.
   - NEVER instruct the user to stand in front of, behind, or close to moving traffic.
   - Do NOT assume the driver can safely exit in every traffic situation; if moving traffic is hazardous, stay buckled inside until assistance arrives.

2. IMMEDIATE DANGEROUS SITUATIONS (EMERGENCY OVERRIDE):
   - Smoke or Fire: Warn to evacuate all occupants immediately to a safe distance (at least 30-50m away, upwind). STRICTLY FORBID opening the hood (oxygen can cause a fireball). Call emergency services (112 in India / local emergency).
   - Fuel Leak or Strong Petrol/Diesel Smell: Warn to keep distance, avoid all sparks, flames, or smoking. Do not turn the ignition. Call emergency services.
   - Overheating Engine with Steam: STRICTLY FORBID opening the radiator cap or coolant expansion tank. Explain that pressurized boiling coolant causes severe 3rd-degree burns. Advise turning off the engine and waiting for complete cooldown.
   - Brake or Steering Failure: STRICTLY FORBID attempting to continue driving. Advise pulling over safely, applying emergency parking brake, and waiting for flatbed tow.
   - Vehicle Stopped in Live Traffic Lane: Personal survival is top priority. If unsafe to exit due to high-speed traffic, stay buckled with hazard lights and call emergency highway patrol immediately.
   - Electrical / EV High-Voltage Hazard: STRICTLY FORBID touching orange high-voltage cables or damaged battery enclosures. Keep safe distance.
   - Accidents with Injury: Immediately instruct calling emergency services (112). Do NOT provide medical diagnosis.

3. ALLOWED LOW-RISK GUIDANCE:
   - Check dashboard warning symbols and indicator lights.
   - Check if gear selector is firmly in Park (P) or Neutral (N) before starting.
   - Visually inspect tyre inflation from a safe, non-traffic stance.
   - Consult the vehicle owner's manual.
   - Collect vehicle symptoms (make/model, warning lights, strange sounds) to report accurately to the incoming mechanic.
   - Explain what standard inspection steps the mechanic will perform upon arrival.

4. STRICTLY PROHIBITED GUIDANCE (DO NOT INSTRUCT):
   - Never instruct an untrained user to crawl under a vehicle or use makeshift jacks.
   - Never instruct opening a hot cooling system.
   - Never instruct roadside repairs on the side of moving traffic.
   - Never instruct repairing fuel lines or electrical bypasses.
   - Never instruct disabling airbags, brakes, or safety interlocks.
   - Never instruct risky roadside jump-starts without verifying battery condition and absence of explosive hydrogen gas/swelling.
   - Never encourage continuing to drive an unsafe or crippled vehicle.

5. TONE, ROLE & LIMITATIONS:
   - You are NOT a certified mechanic, roadside technician, or emergency dispatcher.
   - Do not claim a mechanic is on the way or has been contacted unless verified in the provided application context.
   - If questions are completely unrelated to automotive/roadside safety, politely decline and steer back to vehicle safety.
   - If a user asks for dangerous DIY shortcuts, firmly refuse and offer the safe, defensive alternative.
   - Format answers cleanly with short sentences, clear bullet points, and bold **WARNING** notices for critical safety steps. Keep guidance readable under stress.`;

/**
 * HTTPS Callable/REST Endpoint: askResQAssistant
 * Authenticated via Firebase ID Token (Bearer token in Authorization header).
 */
exports.askResQAssistant = functions.https.onRequest(async (req, res) => {
  // 1. CORS Headers
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    return res.status(204).send("");
  }

  if (req.method !== "POST") {
    return res.status(405).json({
      success: false,
      error: "Method not allowed. Please use POST.",
    });
  }

  // 2. Authentication Verification
  const authHeader = req.headers.authorization || "";
  if (!authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      error: "Unauthorized: Missing or invalid Firebase authentication token.",
    });
  }

  const idToken = authHeader.split("Bearer ")[1].trim();
  let uid = null;
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    uid = decodedToken.uid;
  } catch (authError) {
    console.warn("Auth verification failed:", authError.message);
    return res.status(401).json({
      success: false,
      error: "Unauthorized: Invalid or expired session. Please sign in again.",
    });
  }

  // 3. Rate Limiting Check
  if (isRateLimited(uid)) {
    return res.status(429).json({
      success: false,
      error: "Rate limit reached. Please wait a moment before sending another message.",
    });
  }

  // 4. Request Body Validation
  const { message, conversationHistory, context } = req.body || {};

  if (!message || typeof message !== "string" || message.trim().length === 0) {
    return res.status(400).json({
      success: false,
      error: "Invalid request: message field cannot be empty.",
    });
  }

  if (message.length > 1000) {
    return res.status(400).json({
      success: false,
      error: "Message exceeds maximum permitted length of 1000 characters.",
    });
  }

  // 5. OpenAI Secret Verification
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey || apiKey.trim().length === 0) {
    console.error("OPENAI_API_KEY is not configured in server environment.");
    return res.status(500).json({
      success: false,
      error: "ResQ Assistant is temporarily unavailable. Server API key is not configured.",
    });
  }

  const model = process.env.OPENAI_MODEL || "gpt-4o-mini";

  // 6. Build Chat Payload with Server-Controlled System Instructions
  const messages = [{ role: "system", content: RESQ_SAFETY_SYSTEM_PROMPT }];

  // Optional contextual metadata
  if (context && typeof context === "object") {
    let ctxString = "CURRENT VERIFIED ROADSIDE CONTEXT:";
    if (context.vehicleType) ctxString += ` Vehicle Type: ${context.vehicleType}.`;
    if (context.breakdownCategory) ctxString += ` Reported Problem: ${context.breakdownCategory}.`;
    if (context.requestStatus) ctxString += ` DriveResQ Status: ${context.requestStatus}.`;
    messages.push({ role: "system", content: ctxString });
  }

  // Sanitize and limit recent conversation history (max 6 messages)
  if (Array.isArray(conversationHistory)) {
    const sanitizedHistory = conversationHistory
      .slice(-6)
      .filter((h) => h && (h.role === "user" || h.role === "assistant") && typeof h.content === "string")
      .map((h) => ({
        role: h.role,
        content: String(h.content).substring(0, 500),
      }));
    messages.push(...sanitizedHistory);
  }

  // Add the current user query
  messages.push({
    role: "user",
    content: message.trim(),
  });

  // 7. Invoke OpenAI API with Timeout Guard
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 20000); // 20s timeout

    const openAiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: model,
        messages: messages,
        temperature: 0.3, // Low temperature for high consistency and strict safety adherence
        max_tokens: 600,
      }),
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    if (!openAiResponse.ok) {
      const errText = await openAiResponse.text();
      console.error(`OpenAI API error [${openAiResponse.status}]:`, errText);

      if (openAiResponse.status === 429) {
        return res.status(429).json({
          success: false,
          error: "AI service is currently busy. Please try again in a few moments.",
        });
      }

      return res.status(502).json({
        success: false,
        error: "ResQ Assistant is temporarily unavailable. Please try again or contact your mechanic directly.",
      });
    }

    const data = await openAiResponse.json();
    const replyText =
      data.choices && data.choices[0] && data.choices[0].message
        ? data.choices[0].message.content
        : "Safety note: Please stay in a safe location away from moving traffic while you wait for your mechanic.";

    return res.status(200).json({
      success: true,
      reply: replyText.trim(),
      timestamp: Date.now(),
    });
  } catch (apiError) {
    console.error("OpenAI invocation failed:", apiError.message);
    if (apiError.name === "AbortError") {
      return res.status(504).json({
        success: false,
        error: "Request timed out. Please check your connection and try again.",
      });
    }
    return res.status(500).json({
      success: false,
      error: "ResQ Assistant is temporarily unavailable. Please contact your mechanic directly.",
    });
  }
});

// =============================================================================
// 💰 PLATFORM DUES & RAZORPAY SETTLEMENT FUNCTIONS
// =============================================================================
const Razorpay = require("razorpay");
const crypto = require("crypto");

/**
 * 1. Cloud Function Trigger: onCompletedJobCreateDue
 * Triggered whenever a job is completed and recorded in 'completedJobs/{jobId}'.
 * Calculates platform commission on LABOR CHARGES ONLY (not parts or travel).
 * Creates platformDues/{jobId} document and marks mechanic as suspended until cleared.
 */
/**
 * Core processor for completed job platform dues.
 * Idempotent: doc ID is jobId.
 */
async function processDueForJob(jobId, data, snapRef) {
  if (!data) return false;

  const mechanicId = data.mechanicId;
  const laborCharges = Number(data.laborCharges) || 0;
  // Allow true or undefined (for legacy completed cash jobs where cash was settled directly)
  const cashCollected = data.cashCollected !== false;
  const paymentMethod = data.paymentMethod || "";
  const invoiceNumber = data.invoiceNumber || "";

  // Dues only apply to Cash settled jobs with collected cash and labor charges > 0
  const isCash =
    paymentMethod.toLowerCase().includes("cash") ||
    paymentMethod.toLowerCase().includes("settled directly");
  if (!isCash || !cashCollected || laborCharges <= 0 || !mechanicId) {
    console.log(
      `[processDueForJob] Job ${jobId}: No commission due (cash: ${isCash}, collected: ${cashCollected}, labor: ${laborCharges})`
    );
    return false;
  }

  // Idempotency: verify if platformDues/{jobId} already exists
  const dueDocRef = db.collection("platformDues").doc(jobId);
  const existingDue = await dueDocRef.get();
  if (existingDue.exists) {
    console.log(`[processDueForJob] Due doc for job ${jobId} already exists. Skipping.`);
    return false;
  }

  const percent = Number(
    process.env.PLATFORM_COMMISSION_PERCENT ||
      (functions.config().dues && functions.config().dues.percent) ||
      10
  );
  const rawAmount = (laborCharges * percent) / 100;
  const amount = Math.round(rawAmount * 100) / 100;
  const amountPaise = Math.round(amount * 100);

  console.log(
    `[processDueForJob] Job ${jobId}: Labor ₹${laborCharges}, Rate: ${percent}%, Commission: ₹${amount} (${amountPaise} paise)`
  );

  // Minimum transaction handling: Razorpay minimum is ₹1 (100 paise)
  if (amountPaise > 0 && amountPaise < 100) {
    await dueDocRef.set({
      id: jobId,
      mechanicId,
      jobId,
      invoiceNumber,
      laborCharges,
      commissionPercent: percent,
      amount,
      amountPaise,
      currency: "INR",
      status: "paid",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
      note: "Auto-cleared below minimum ₹1 Razorpay threshold",
    });

    if (snapRef) {
      await snapRef.set(
        {
          platformCommissionPercent: percent,
          platformCommissionAmount: amount,
          platformDueStatus: "paid",
        },
        { merge: true }
      );
    }
    return true;
  }

  // Create platformDues/{jobId}
  await dueDocRef.set({
    id: jobId,
    mechanicId,
    jobId,
    invoiceNumber,
    laborCharges,
    commissionPercent: percent,
    amount,
    amountPaise,
    currency: "INR",
    status: "unpaid",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Update user transactionally
  await db.runTransaction(async (t) => {
    const userRef = db.collection("users").doc(mechanicId);
    const userSnap = await t.get(userRef);
    if (!userSnap.exists) return;

    const currentOutstanding = Number(userSnap.data().platformDueOutstanding || 0);
    const newOutstanding = Math.round((currentOutstanding + amount) * 100) / 100;

    t.update(userRef, {
      platformDueOutstanding: newOutstanding,
      accountStatus: newOutstanding > 0 ? "suspended" : "active",
      suspendedReason: newOutstanding > 0 ? "unpaid_dues" : null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  // Merge financial ledger details onto completedJobs/{jobId}
  if (snapRef) {
    await snapRef.set(
      {
        platformCommissionPercent: percent,
        platformCommissionAmount: amount,
        platformDueStatus: "unpaid",
      },
      { merge: true }
    );
  }

  console.log(`[processDueForJob] Successfully created due and updated mechanic ${mechanicId}`);
  return true;
}

/**
 * 1. Firestore Trigger: completedJobs/{jobId}.onCreate
 */
exports.onCompletedJobCreateDue = functions.firestore
  .document("completedJobs/{jobId}")
  .onCreate(async (snap, context) => {
    const jobId = context.params.jobId;
    const data = snap.data();
    await processDueForJob(jobId, data, snap.ref);
    return null;
  });

/**
 * Sync / Backfill Callable: syncPendingDues
 * Processes any completed jobs for the caller that have no platform dues ledger entry
 * and reconciles the outstanding balance with the users collection.
 */
exports.syncPendingDues = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated."
    );
  }

  const uid = context.auth.uid;
  const jobsSnap = await db
    .collection("completedJobs")
    .where("mechanicId", "==", uid)
    .get();

  let count = 0;
  for (const doc of jobsSnap.docs) {
    const jobData = doc.data();
    if (!jobData.platformDueStatus) {
      const created = await processDueForJob(doc.id, jobData, doc.ref);
      if (created) count++;
    }
  }

  // Reconcile user profile balance with actual unpaid dues
  const unpaidSnaps = await db
    .collection("platformDues")
    .where("mechanicId", "==", uid)
    .where("status", "==", "unpaid")
    .get();

  let totalOutstanding = 0;
  unpaidSnaps.forEach((d) => {
    totalOutstanding += Number(d.data().amount || 0);
  });
  totalOutstanding = Math.round(totalOutstanding * 100) / 100;

  await db.collection("users").doc(uid).update({
    platformDueOutstanding: totalOutstanding,
    accountStatus: totalOutstanding > 0 ? "suspended" : "active",
    suspendedReason: totalOutstanding > 0 ? "unpaid_dues" : null,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, count, outstanding: totalOutstanding };
});

/**
 * Helper to initialize Razorpay SDK
 */
function getRazorpayInstance() {
  const key_id =
    process.env.RAZORPAY_KEY_ID ||
    (functions.config().razorpay && functions.config().razorpay.key_id);
  const key_secret =
    process.env.RAZORPAY_KEY_SECRET ||
    (functions.config().razorpay && functions.config().razorpay.key_secret);

  if (!key_id || !key_secret) {
    return {
      error:
        "Razorpay credentials not configured in environment (RAZORPAY_KEY_ID / RAZORPAY_KEY_SECRET).",
    };
  }

  return {
    client: new Razorpay({ key_id, key_secret }),
    key_id,
    key_secret,
  };
}

/**
 * 2. HTTPS Callable: createDuesOrder
 * Sums unpaid platformDues for authenticated mechanic and creates Razorpay Order.
 */
exports.createDuesOrder = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to create order."
    );
  }

  const uid = context.auth.uid;
  let unpaidSnaps = await db
    .collection("platformDues")
    .where("mechanicId", "==", uid)
    .where("status", "==", "unpaid")
    .get();

  // If no unpaid dues exist in platformDues collection, check user profile & completed jobs!
  if (unpaidSnaps.empty) {
    const jobsSnap = await db
      .collection("completedJobs")
      .where("mechanicId", "==", uid)
      .get();
    for (const doc of jobsSnap.docs) {
      const jobData = doc.data();
      if (!jobData.platformDueStatus) {
        await processDueForJob(doc.id, jobData, doc.ref);
      }
    }

    // Re-check after sync
    unpaidSnaps = await db
      .collection("platformDues")
      .where("mechanicId", "==", uid)
      .where("status", "==", "unpaid")
      .get();
  }

  // If still empty: check user profile platformDueOutstanding!
  if (unpaidSnaps.empty) {
    const userDoc = await db.collection("users").doc(uid).get();
    const userData = userDoc.data() || {};
    const outstanding = Number(userData.platformDueOutstanding) || 0;

    if (outstanding >= 1) {
      // Create a consolidated due record so the mechanic is NOT blocked from paying
      const dueId = `due_${uid.slice(0, 6)}_${Date.now()}`;
      const amountPaise = Math.round(outstanding * 100);
      await db.collection("platformDues").doc(dueId).set({
        id: dueId,
        mechanicId: uid,
        jobId: "consolidated_balance",
        invoiceNumber: "ADJUSTMENT",
        laborCharges: outstanding * 10,
        commissionPercent: 10,
        amount: outstanding,
        amountPaise,
        currency: "INR",
        status: "unpaid",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        note: "Consolidated outstanding dues balance",
      });

      unpaidSnaps = await db
        .collection("platformDues")
        .where("mechanicId", "==", uid)
        .where("status", "==", "unpaid")
        .get();
    } else {
      // No dues at all! If account was erroneously marked suspended, activate it!
      if (userData.accountStatus === "suspended" || outstanding <= 0) {
        await db.collection("users").doc(uid).update({
          platformDueOutstanding: 0,
          accountStatus: "active",
          suspendedReason: null,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      throw new functions.https.HttpsError(
        "failed-precondition",
        "No unpaid platform dues found for this mechanic. Your account is clear."
      );
    }
  }

  let totalPaise = 0;
  const dueIds = [];
  unpaidSnaps.forEach((doc) => {
    const d = doc.data();
    const paise = d.amountPaise || Math.round((d.amount || 0) * 100);
    totalPaise += paise;
    dueIds.push(doc.id);
  });

  if (totalPaise < 100) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Total outstanding amount is below ₹1 minimum payable limit."
    );
  }

  const rzp = getRazorpayInstance();
  if (rzp.error) {
    throw new functions.https.HttpsError("unavailable", rzp.error);
  }

  try {
    const options = {
      amount: totalPaise,
      currency: "INR",
      receipt: `due_${uid.substring(0, 6)}_${Date.now().toString().slice(-6)}`,
      notes: {
        mechanicId: uid,
        dueIds: dueIds.slice(0, 20).join(","),
      },
    };

    const order = await rzp.client.orders.create(options);
    console.log(
      `[createDuesOrder] Created order ${order.id} for ₹${totalPaise / 100} (Mechanic: ${uid})`
    );

    return {
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      keyId: rzp.key_id,
    };
  } catch (err) {
    console.error("[createDuesOrder] Error creating Razorpay order:", err);
    throw new functions.https.HttpsError(
      "internal",
      err.message || "Failed to create Razorpay order."
    );
  }
});

/**
 * 3. HTTPS Callable: verifyDuesPayment
 * Verifies Razorpay payment signature HMAC SHA256 and clears platform dues upon validity.
 * Includes direct Razorpay API check fallback for maximum reliability.
 */
exports.verifyDuesPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to verify payment."
    );
  }

  const uid = context.auth.uid;
  const { orderId, paymentId, signature } = data || {};

  if (!orderId || !paymentId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing orderId or paymentId."
    );
  }

  const rzp = getRazorpayInstance();
  if (rzp.error) {
    throw new functions.https.HttpsError("unavailable", rzp.error);
  }

  let verified = false;

  // 1. Signature verification via HMAC SHA-256
  if (signature) {
    const expectedSignature = crypto
      .createHmac("sha256", rzp.key_secret)
      .update(`${orderId}|${paymentId}`)
      .digest("hex");

    if (expectedSignature === signature) {
      verified = true;
    } else {
      console.warn(
        `[verifyDuesPayment] HMAC mismatch. Expected: ${expectedSignature}, Got: ${signature}. Falling back to Razorpay API verification.`
      );
    }
  }

  // 2. Direct Razorpay API verification fallback
  if (!verified) {
    try {
      const payment = await rzp.client.payments.fetch(paymentId);
      console.log(
        `[verifyDuesPayment] Razorpay API payment ${paymentId}: status=${payment.status}, order_id=${payment.order_id}`
      );
      if (
        payment &&
        payment.order_id === orderId &&
        (payment.status === "captured" || payment.status === "authorized")
      ) {
        verified = true;
      }
    } catch (apiErr) {
      console.error("[verifyDuesPayment] Razorpay payments.fetch failed:", apiErr.message);
    }
  }

  if (!verified) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Payment verification failed: could not confirm payment authenticity."
    );
  }

  // 3. Clear dues and reactivate account
  try {
    const unpaidSnaps = await db
      .collection("platformDues")
      .where("mechanicId", "==", uid)
      .where("status", "==", "unpaid")
      .get();

    const batch = db.batch();

    unpaidSnaps.forEach((doc) => {
      batch.update(doc.ref, {
        status: "paid",
        paidAt: admin.firestore.FieldValue.serverTimestamp(),
        razorpayOrderId: orderId,
        razorpayPaymentId: paymentId,
        razorpaySignature: signature || "api_verified",
      });
    });

    // Reset mechanic profile outstanding and reactivate account
    const userRef = db.collection("users").doc(uid);
    batch.update(userRef, {
      platformDueOutstanding: 0,
      accountStatus: "active",
      suspendedReason: null,
      lastPaymentAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Record payment receipt log
    const receiptRef = db.collection("dues_payments").doc(paymentId);
    batch.set(receiptRef, {
      mechanicId: uid,
      orderId,
      paymentId,
      signature,
      clearedDueCount: unpaidSnaps.size,
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await batch.commit();

    console.log(
      `[verifyDuesPayment] Payment ${paymentId} verified. Cleared ${unpaidSnaps.size} dues for mechanic ${uid}`
    );

    return {
      success: true,
      clearedCount: unpaidSnaps.size,
      message: "Payment successfully verified. Your account is active!",
    };
  } catch (err) {
    console.error("[verifyDuesPayment] Error updating dues on payment:", err);
    throw new functions.https.HttpsError(
      "internal",
      err.message || "Failed to update dues ledger."
    );
  }
});

/**
 * 4. Webhook: razorpayWebhook
 * Handles server-to-server Razorpay webhooks as backup or asynchronous validation.
 */
exports.razorpayWebhook = functions.https.onRequest(async (req, res) => {
  const webhookSecret =
    process.env.RAZORPAY_WEBHOOK_SECRET ||
    (functions.config().razorpay && functions.config().razorpay.webhook_secret);

  if (webhookSecret) {
    const signature = req.headers["x-razorpay-signature"];
    const shasum = crypto.createHmac("sha256", webhookSecret);
    shasum.update(
      typeof req.rawBody !== "undefined" ? req.rawBody : JSON.stringify(req.body)
    );
    const digest = shasum.digest("hex");

    if (digest !== signature) {
      console.error("[razorpayWebhook] Invalid signature");
      return res.status(400).send("Invalid webhook signature");
    }
  }

  const event = req.body.event;
  console.log(`[razorpayWebhook] Received event: ${event}`);

  if (event === "payment.captured" || event === "order.paid") {
    try {
      const paymentEntity =
        req.body.payload &&
        req.body.payload.payment &&
        req.body.payload.payment.entity;
      const mechanicId =
        paymentEntity && paymentEntity.notes && paymentEntity.notes.mechanicId;

      if (mechanicId) {
        const unpaidSnaps = await db
          .collection("platformDues")
          .where("mechanicId", "==", mechanicId)
          .where("status", "==", "unpaid")
          .get();

        if (!unpaidSnaps.empty) {
          const batch = db.batch();
          unpaidSnaps.forEach((doc) => {
            batch.update(doc.ref, {
              status: "paid",
              paidAt: admin.firestore.FieldValue.serverTimestamp(),
              razorpayPaymentId: paymentEntity.id,
              razorpayOrderId: paymentEntity.order_id,
            });
          });

          const userRef = db.collection("users").doc(mechanicId);
          batch.update(userRef, {
            platformDueOutstanding: 0,
            accountStatus: "active",
            suspendedReason: null,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          await batch.commit();
          console.log(`[razorpayWebhook] Cleared dues for mechanic ${mechanicId}`);
        }
      }
    } catch (e) {
      console.error("[razorpayWebhook] Error processing payment webhook:", e);
    }
  }

  return res.status(200).json({ status: "ok" });
});

