/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.cleanUpInvalidTokens = functions.pubsub.schedule("*/2 * * * *").onRun(
    async (context) => {
      // Path to tblStudent
      const tokensRef = admin.database().ref("ProgrammerProdigies/tblStudent");

      const snapshot = await tokensRef.once("value");
      const students = snapshot.val();

      if (!students) {
        console.log("No student records found.");
        return null;
      }

      for (const userId in students) {
        if (Object.prototype.hasOwnProperty.call(students, userId)) {
          const student = students[userId];
          const token = student.FCMToken;

          if (!token) continue; // Skip if there's no FCM token for the user

          try {
            // Attempt to send a silent message to check the token validity
            await admin.messaging().send({
              token,
              android: {priority: "high"},
              data: {check: "true"},
            });
          } catch (error) {
            if (error.code === "messaging/registration-token-not-registered") {
              // Token is invalid; remove it from the database
              try {
                // Remove only the FCMToken field
                await tokensRef.child(userId).child("FCMToken").remove();
                console.log(`Removed invalid token for user ${userId}`);
              } catch (dbError) {
                console.error(`Failed to remove for user ${userId}:`, dbError);
              }
            } else {
              console.error(`Failed to send for user ${userId}:`, error);
            }
          }
        }
      }

      console.log("Token cleanup completed.");
      return null;
    },
);


