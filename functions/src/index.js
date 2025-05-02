/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp, FieldValue, Filter } from 'firebase-admin/firestore';
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { getMessaging } from "firebase-admin/messaging"; 
import { getAuth } from "firebase-admin/auth";
import { onCall,onRequest, HttpsError } from "firebase-functions/v2/https";
import {onSchedule} from  "firebase-functions/v2/scheduler";

import { https ,logger} from 'firebase-functions';
import { GoogleGenAI, HarmCategory, HarmBlockThreshold } from "@google/genai";

//import { strict as assert } from 'assert';
    
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//     logger.logger.info("Hello logger.logs!", {structuredData: true});
//     response.send("Hello from Firebase!");
// });

// Initialize Firebase Admin if not already initialized
initializeApp();
const auth = getAuth();
const db = getFirestore();
const fcmMessaging = getMessaging();
// Initialize Gemini
const genAI = new GoogleGenAI({apiKey: process.env.GEMINI_API_KEY}); // Get API key from environment variables

export const getFirebaseConfig = onCall((request) => {
        return {
        apiKey: process.env.ACTIONHANDLER_APIKEY,
        authDomain: process.env.ACTIONHANDLER_AUTHDOMAIN, // ... other config values
        appId: process.env.ACTIONHANDLER_APPID,
        // ... the rest of your firebaseConfig
        };
});
export const registerUser = onCall(async (request) => {
    var currentAuth;
    try {
        const data = request.data;
        logger.log('getting data...');
        //logger.logger.info('getting data from logger.logger[${email}]...');
        const { idToken, email,firstName, lastName, role, newWorkplaceName , fcmToken} = data;
        logger.log('registering: %s',email);
        logger.log('Performing auth...');
        var transResult = await db.runTransaction(async (transaction) => {
            // 1. Create Auth User within the transaction
            logger.log(`verifying auth ${idToken}...`);
            const decodedToken  = await auth.verifyIdToken(idToken);
            logger.log('verifying auth ${idToken}...');
            currentAuth = await auth.getUser(decodedToken.uid);
            logger.log(`Returned form auth with: [${currentAuth.uid}] ,checking credentials...`);
            if (!currentAuth) throw new Error('Failed to create user.');
            // 2. (Optional) Create Workplace within the transaction
            logger.log('checking user role...');
            let workplaceId = null;
            if (role === 'admin') {
                logger.log('user is admin , checking if workplace name is supplied ...');
                if (!newWorkplaceName) throw new Error('Workplace name is missing.');
                logger.log('creating workplace for new user...');
                const newWorkplaceRef = db.collection('workplaces').doc();
                transaction.set(newWorkplaceRef, {  // Use transaction.set
                    id: newWorkplaceRef.id,
                    description: newWorkplaceName,
                    adminUserId: currentAuth.uid,
                    createdAt: FieldValue.serverTimestamp(),
                });
                workplaceId = newWorkplaceRef.id; 
                logger.log('sucessfully created new workplace...');

                logger.log('creating workplace settings...');
                const newWorkplaceSettingsRef = db.collection('workplaces').doc(workplaceId).collection('workplaceSettings').doc();
                transaction.set(newWorkplaceSettingsRef, {  // Use transaction.set
                    id: newWorkplaceSettingsRef.id,
                    firstUsePoints: 30,
                    createHazardPoints:  0,
                    createTaskPoints:0,
                    finishTaskPoints:0,
                    createIncidentPoints: 0,
                    miniSessionPoints: 0,
                    quizeGameAnswerPoints: 0,
                    quizeGameLevelPoints: 0,
                });
                logger.log('sucessfully created workplace settings...');
                
                logger.log('creating new user...');
                // console.logger.log('checking workplace if created...');
                // if (!workplaceId) throw new Error('Workplace creation failed.');
                const newAuthUserRef = db.collection('authUsers').doc();
                const newUser = {
                    id: newAuthUserRef.id,
                    uid: currentAuth.uid,
                    provider: 'password',
                    email,
                    firstName,
                    lastName,
                    displayName: currentAuth.displayName|| '',
                    isEmailVerified: currentAuth.emailVerified||false,
                    phoneNumber: currentAuth.phoneNumber|| '',
                    photoURL: currentAuth.photoURL|| '',
                    fcmToken: fcmToken || '',
                    currentWorkplace: workplaceId,
                    currentWorkplaceRole: 'admin',
                    createdAt: FieldValue.serverTimestamp(),
                    updatedAt: FieldValue.serverTimestamp(),
                    isFirstLogin: true
                };
                transaction.set(newAuthUserRef, newUser);
                //const newUserId = await db.collection('authUsers').add(newUser);
                logger.log(`sucessfully created new user...`); // Preferences handling would be different in a Node.js environment.  Consider using Firestore or Realtime Database for user preferences.
                logger.log('creating workplace user data...');
                const newWorkplaceUserRef = db.collection('UserWorkplaces').doc();
                const newWorkplaceUserData = {
                    id: newWorkplaceUserRef.id,
                    createdAt: FieldValue.serverTimestamp(),
                    userId: newUser.id,
                    workpalceId: workplaceId,
                    role:'admin',
                }
                logger.log('user were new organization data were added...');
                transaction.set(newWorkplaceUserRef, newWorkplaceUserData);
                logger.log('creating workplace all location...');
                const newWorkplaceLocationRef = db.collection('workplaces')
                    .doc(workplaceId).collection('WorkplaceLocations').doc();
                transaction.set(newWorkplaceLocationRef, {  // Use transaction.set
                    id: newWorkplaceRef.id,
                    description: 'all',
                    managerId: newAuthUserRef.id,
                });
                logger.log('Success...');
                return { status: 'success', userId: currentAuth.uid, workplaces: workplaceId ? [{ workplaceId, role: 'admin' }] : [] };

                // const newLocalUser = {  // Example, assuming you're storing preferences in Firestore
                //     id: currentAuth.uid,
                //     uid: currentAuth.uid,
                //     provider: 'password',
                //     email: email,
                //     firstName: firstName || '',
                //     lastName: lastName || '',
                //     displayName: currentAuth.displayName || '',
                //     phoneNumber: currentAuth.phoneNumber || '',
                //     photoURL: currentAuth.photoURL || '',
                //     currentWorkplace: workplaceId,
                //     currentWorkplaceRole: 'admin'
                // };
                // //await db.collection('userPreferences').doc(currentAuth.uid).set(newLocalUser); //example
                
                //console.logger.log(`New user created: ${email}`);
                //return { status: 'success', userId: currentAuth.uid , workplaces: [{'workplaceId':workplaceId, 'role': 'admin'}]}; // Return the user ID
            } else if (role === 'newUser') {
                logger.log('creating new user...');
                const newAuthUserRef = db.collection('authUsers').doc();
                const newUser = {
                    id: newAuthUserRef.id,
                    uid: currentAuth.uid,
                    provider: 'password',
                    email,
                    firstName,
                    lastName,
                    displayName: currentAuth.displayName|| '',
                    isEmailVerified: currentAuth.emailVerified||false,
                    phoneNumber: currentAuth.phoneNumber|| '',
                    photoURL: currentAuth.photoURL|| '',
                    fcmToken: fcmToken || '',
                    createdAt: FieldValue.serverTimestamp(),
                    updatedAt: FieldValue.serverTimestamp(),
                    isFirstLogin: true
                };
                transaction.set(newAuthUserRef, newUser);
                logger.log(`New user created: ${email}`);
                return { status: 'success', userId: currentAuth.uid }; // Return the user ID
            } else {
                logger.error('Missing user role.')
                throw new Error('Missing user role.');
            }
        } ).catch(async (error) => {  // Catch the transaction error
            logger.error(`Error during user creation: ${error}`);
            if (currentAuth) { // Check if currentAuth is defined
                try {
                    await auth.deleteUser(currentAuth.uid); // Delete the authenticated user
                    logger.log(`User ${currentAuth.uid} deleted due to transaction failure.`);
                } catch (deleteError) {
                    logger.error(`Failed to delete user after transaction error: ${deleteError}`);
                    // Consider additional error handling or logging. The user might need manual deletion.
                }
            } else {
                logger.error("currentAuth is undefined, cannot delete user.");
            }

            // Re-throw the original error to propagate it to the client
            throw error; 
        });;
        return( { status: transResult.status, userId:transResult.userId? transResult.userId:'', workplaces: transResult.workplaces? transResult.workplaces : []});
        } catch (error) {
            logger.error(`Error during user creation: ${error}`);
            // Important: Re-throw error so the client receives an error message.
            
            throw new HttpsError('internal', error.message); // Or another appropriate error code
        }
});
export const verifyToken = onCall(async (request) => {
    try {
        const data = request.data;
        logger.log('getting token...');
        const idToken = data.token;
        logger.log('verifying token $idToken...');
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        logger.log('token verified...');
        return { uid: decodedToken.uid }; // Return the UID
    } catch (error) {
        console.error("Error verifying ID token:", error);
        throw new functions.https.HttpsError('invalid-argument', 'Invalid ID token.');
    }
});
export const createWorkplaceInvitation = onCall(async (request) => {
        // Get parameters from the client
        logger.log('getting parameters...');    
        const data = request.data;
        const workplaceId = data.workplaceId;
        const invitedUserEmail = data.invitedUserEmail;
        const inviterId = data.inviterId;
        const role = data.role; 
        //const daysValid = data.daysValid || 7 ; // Default 7 days validity
    
        try {
            logger.log('Checking parameters...');    
            if (!workplaceId) {
                logger.error('Missing required parameter: workplaceId.');    
                throw new HttpsError('invalid-argument', 'Missing required parameter: workplaceId.');
            }else if (!invitedUserEmail) {
                logger.error('Missing required parameter: invitedUserEmail.');    
                throw new HttpsError('invalid-argument', 'Missing required parameter: invitedUserEmail.');
            } else if (!role) {
                logger.error('Missing required parameter: role.');    
                throw new HttpsError('invalid-argument', 'Missing required parameter: role.');
            }
            // Create an invitation code (you might use a library like `uuid` for this).
            //logger.log('creating invitation code...');  
            //const invitationCode = require('crypto').randomBytes(6).toString('hex').toUpperCase();
            logger.log('Setting expity date...');  
            const expiryDate = new Date();
            expiryDate.setDate(expiryDate.getDate() + 1);
            logger.log('creating inviation...');  
            const invitationRef = db.collection('workplaceInvitations').doc();
            const invitationData = {
                id:invitationRef.id,
                workplaceId:workplaceId,
                invitedUserEmail: invitedUserEmail,
                inviterId:inviterId,
                createdAt: new Date().toISOString(),
                status: 'pending',
                role:role,
                //expiryDate: expiryDate.toISOString(), // Store as ISO string
            };
            
            await invitationRef.set(invitationData);
            
            // Optionally send an email notification to the invited user.
            // ... code to send email using SendGrid, etc. ...
            // const sgMail = require('@sendgrid/mail'); // Install SendGrid
            // sgMail.setApiKey(process.env.SENDGRID_API_KEY);
            // const msg = {
            // to: adminEmail,
            // from: 'your-email@example.com', 
            // subject: 'New Workplace Created',
            // text: `A new workplace, ${newWorkplace.description}, has been created.`,
            // html: `<strong>A new workplace, ${newWorkplace.description}, has been created.</strong>`,
            // };
            // await sgMail.send(msg);
            logger.log('success , inviation created...');  
            // const messaging = getMessaging(); 
            // const tokens = [adminUser.fcmToken]; // Get the user's FCM token(s) from your user data - you will need to store this somewhere.  Can be an array of tokens.
            // if (tokens && tokens.length > 0) { // Check if FCM token exists before sending
            //     const message = {
            //     tokens: tokens, // Array of tokens or a single token

            //         notification: {
            //             title: 'New Workplace Created!',
            //             body: `The workplace "${newWorkplace.description}" has been created.`,
            //         },
            //         data: {  // You can include any custom data you want here
            //             workplaceId: event.data.id,
            //             workplaceName: newWorkplace.description
            //         },
            //             // You can add other FCM options like Android/iOS specific configurations, etc. here
            //     };
            //     await messaging.sendMulticast(message);
            // }

            return { status:'success', invitationCode: invitationCode };
        } catch (error) {
            logger.error("Error creating invitation:", error);
            throw new HttpsError('internal', 'Error creating invitation.');
        }
});
export const joinWorkplace = onCall(async (request) => {

try {
    const data = request.data;
    logger.log('getting invitation code...');    
    const { invitationCode } = data;
    const userId = request.auth.uid;  // Get the authenticated user's ID
    logger.log('checing if user is authenticated...'); 
    if (!userId) {
        throw new HttpsError('unauthenticated', 'User not authenticated.');
    }
    logger.log(`User ${userId} attempting to join workplace with code ${invitationCode}`);
    var transResult = await db.runTransaction(async (transaction) => {
        const invitationRef = db.collection('workplaceInvitations').where('invitationCode', '==', invitationCode);
        const invitationSnapshot = await invitationRef.get();
        
        if (!invitationSnapshot.exists) {
            logger.error('Invalid invitation code.');
            throw new HttpsError('invalid-argument', 'Invalid invitation code.');
        }
        // else{
        //     snapshot.forEach(doc => {
        //         //console.logger.log(doc.id, '=>', doc.data());

        //     })
        // }

        logger.log(`got invitation,checking expiry ...`);
        const invitation = invitationSnapshot.data();

        const invitationExpiration = new Date(invitation.expiryDate.seconds * 1000); // Convert Firestore timestamp

        if (invitationExpiration < new Date()) {
            await invitationRef.delete(); // Delete expired invitation
            logger.error('Invitation expired.');
            throw new HttpsError('invalid-argument', 'Invitation code expired.');
        }
        logger.log(`not expired, checking if saved mail equals the authorized one ...`);
        const invitedUserEmail = invitation.invitedUserEmail;
        const authUser = await auth.getUser(userId);

        if (authUser.email !== invitedUserEmail) {
            logger.error('permission-denied', 'Email mismatch.  User is not authorized to use this invitation.');
            throw new HttpsError('permission-denied', 'Email mismatch.  User is not authorized to use this invitation.');
        }
        logger.log(`ok , checking if workplace exists ...`);
        const workplaceId = invitation.workplaceId;
        const workplaceRef = db.collection('workplaces').doc(workplaceId);
        const workplaceSnapshot = await workplaceRef.get();

        if (!workplaceSnapshot.exists) {
            logger.error('not-found', 'Workplace not found.');
            throw new HttpsError('not-found', 'Workplace not found.');
        }
        logger.log(`ok , getting user data ...`);
        const userRef = db.collection('authUsers').doc(userId);
        const userSnapshot = await userRef.get();

        if (!userSnapshot.exists) {
            logger.error('not-found', 'User not found.');
            throw new HttpsError('not-found', 'User not found.');
        }
        logger.log(`ok , joining user to workplace ...`);
        //TODO: update this to join mutliple workplaces
        logger.log('adding user data to workplace...');
        const newWorkplaceUserRef = db.collection('UserWorkplaces').doc();
        const newWorkplaceUserData = {
            createdAt: FieldValue.serverTimestamp(),
            userId: userSnapshot.id,
            workpalceId: invitation.workplaceId,
            role:invitation.role,
            invitationCode: invitation.invitationCode,
        }
        transaction.set(newWorkplaceUserRef, newWorkplaceUserData);
        logger.log('new user organization data were added...');

        logger.log(`user joined successfully , deleting invitation ...`);
        const otherInvitationsQuery = db.collection('workplaceInvitations').where('invitedUserEmail', '==', invitedUserEmail);
        const otherInvitationsSnapshot = await otherInvitationsQuery.get();
        if (otherInvitationsSnapshot.size > 0) {
            const batch = db.batch();
            otherInvitationsSnapshot.forEach(doc => {
                batch.delete(doc.ref);
            });
            await batch.commit(); // Delete all other invitations in a single batch operation
            console.logger.log(`Deleted ${otherInvitationsSnapshot.size} other invitations for user ${invitedUserEmail}.`);

        }
        logger.log(`User ${userId} successfully joined workplace ${workplaceId}`);
        return { status: 'success', userId: userSnapshot.id ,workpalceId  : invitation.workplaceId , role: invitation.role};
    });
    
    return { status: transResult.status, workplaceId: transResult.workpalceId, role: transResult.role,invitationCode: transResult.invitationCode};
} catch (error) {
    logger.error("Error joining workplace:", error);
    if (error instanceof HttpsError) {
    throw error; // Re-throw HttpsErrors for client-side handling
    } else {
    throw new HttpsError('internal', 'An unexpected error occurred.');
    }
}

});
export const sendPasswordReset = onCall(async (request) => {
    try {
        const data = request.data;
        logger.log('getting email...');    
        const { email } = data;    
        await auth.sendPasswordResetEmail(email);
    
        return { success: true };
        } catch (error) {
        // Handle errors (e.g., invalid email, user not found)
        logger.error("Error sending password reset email:", error);
        if (error instanceof HttpsError) {
                throw error; 
            } else {
                throw new HttpsError('internal', 'An unexpected error occurred.');
            }    
        }
});
export const sendFCMTokenMessageToUid = onCall(async (request) => {
    try {
        logger.log('getting FCM data...');    
        const { uid, title, body,notificationPriority, notificationData} = request.data;
        const userToSend = db.collection('authUsers').doc(uid);
        if (!userToSend.fcmToken) {
            throw new HttpsError('no-fcm', 'User has no fcmToken registered!');
        }
        logger.log('got fcmToken:', userToSend.fcmToken);
        const message = {
            notification: {title: title,body: body},
            priority: notificationPriority,
            data: notificationData, // Example: { key1: 'value1', key2: 'value2' }
            token: userToSend.fcmToken
            };
        const response = await fcmMessaging.send(message);
        logger.log('Successfully sent message:', response);
        return { status: 'success' };
            
    }catch (error) {
        logger.error("Error sending FCM message:", error);
        if (error instanceof HttpsError) {
        throw error; // Re-throw HttpsErrors for client-side handling
        } else {
        throw new HttpsError('internal', 'An unexpected error occurred.');
        }
    }
});
export const sendFCMTokenMessage = onCall(async (request) => {
    try {
        logger.log('getting FCM data...');    
        const { token, title, body, data} = request.data;
        const message = {
            notification: {
                title: title,
                body: body
            },
            data: data, // Example: { key1: 'value1', key2: 'value2' }
            token: token
            };
        const response = await fcmMessaging.send(message);
        logger.log('Successfully sent message:', response);
        return { status: 'success' };
            
    }catch (error) {
        logger.error("Error sending FCM message:", error);
        if (error instanceof HttpsError) {
        throw error; // Re-throw HttpsErrors for client-side handling
        } else {
        throw new HttpsError('internal', 'An unexpected error occurred.');
        }
    }
});
export const sendFCMTopicMessage = onCall(async (request) => {
    try {
        logger.log('getting FCM data...');    
        const { topic, title, body, data } = request.data;
        const message = {
            notification: {
                title: title,
                body: body
            },
            data: data, // Example: { key1: 'value1', key2: 'value2' }
            topic: topic 
            };
        const response = await fcmMessaging.send(message);
        logger.log('Successfully sent message:', response);
        return { status: 'success' };
            
    }catch (error) {
        logger.error("Error sending FCM message:", error);
        if (error instanceof HttpsError) {
        throw error; // Re-throw HttpsErrors for client-side handling
        } else {
        throw new HttpsError('internal', 'An unexpected error occurred.');
        }
    }
});

export const monthlyTargetCheck = onSchedule(
    {
        //schedule: "0 0 1 last day of month", //run every last day of month

        //schedule: "0 0 * * 0", // Run every Sunday at midnight (00:00)
        //schedule: "*/1 * * * *", // Every 1 minutes (for testing)
        schedule: "*/5 * * * * *", // Every 5 seconds (for testing)
        timeZone: "UTC"
    }
    ,async (event) => {
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth(); // Month is 0-indexed (0 = January, 11 = December)
    try {
        // 1. Get the targetHazardIdsPerYear from the settings collection
        const settingsDoc = await db.collection("settings").doc("adminSettings").get();
        if (!settingsDoc.exists) {
            console.error("No admin settings found!");
            return null;
        }
        const settingsData = settingsDoc.data();
        const targetHazardIdsPerYear = settingsData.targetHazardIdsPerYear || 0;
        if (targetHazardIdsPerYear == 0) {
            return null;
        }
        // Calculate the target for the current month
        const targetHazardIdsThisMonth = Math.round(targetHazardIdsPerYear / 12 * (currentMonth + 1));

        // 2. Get the count of hazards created up to this month of this year
        const startOfYear = new Date(currentYear, 0, 1); // January 1st of the current year
        const startOfNextMonth = new Date(currentYear, currentMonth + 1, 1); // First day of next month
        const hazardsSnapshot = await db.collection("hazards")
            .where("createdAt", ">=", db.Timestamp.fromDate(startOfYear))
            .where("createdAt", "<", db.Timestamp.fromDate(startOfNextMonth))
            .get();
        const currentHazardCount = hazardsSnapshot.size;

        // 3. Check if the target is met
        if (currentHazardCount < targetHazardIdsThisMonth) {
            // 4. If not met, calculate the difference
            const difference = targetHazardIdsThisMonth - currentHazardCount;

            // 5. Add a miniSession to authUsers collection
            // Assuming you have a way to get mini sessions and add them
            // Get all mini sessions
            const miniSessionsSnapshot = await db.collection("miniSessions").get();
            const allMiniSessions = miniSessionsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

            // Get all authUsers
            const authUsersSnapshot = await db.collection("authUsers").get();
            const allAuthUsers = authUsersSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

            // Add mini sessions to users, ensuring uniqueness
            let miniSessionsAddedCount = 0;
            for (const user of allAuthUsers) {
                if (miniSessionsAddedCount >= difference) break; // Stop if we've added enough

                // Get the user's current assignedMiniSessions (or an empty array if null)
                const currentAssignedMiniSessions = user.assignedMiniSessions || [];

                // Find a mini session that hasn't been assigned to this user
                const availableMiniSession = allMiniSessions.find(miniSession => !currentAssignedMiniSessions.includes(miniSession.id));

                if (availableMiniSession) {
                    // Update the user's assignedMiniSessions
                    const updatedAssignedMiniSessions = [...currentAssignedMiniSessions, availableMiniSession.id];
                    await db.collection("authUsers").doc(user.id).update({ assignedMiniSessions: updatedAssignedMiniSessions });
                    miniSessionsAddedCount++;
                }
            }

            console.log(`Added ${miniSessionsAddedCount} mini sessions to users for unmet hazard target.`);
            console.log(`Hazard target not met for ${currentYear} up to month ${currentMonth + 1}. Target: ${targetHazardIdsThisMonth}, Current Count: ${currentHazardCount}`);
        } else {
            console.log(`Hazard target met for ${currentYear} up to month ${currentMonth + 1}. Target: ${targetHazardIdsThisMonth}, Current Count: ${currentHazardCount}`);
        }
    } catch (error) {
        console.error("Error in monthlyTargetCheck:", error);
    }
    return null;
});

const INACTIVE_MONTHS_THRESHOLD = 6; // Number of months of inactivity to consider a workplace for deletion
const BATCH_SIZE = 500; // Maximum number of documents to delete in a single batch
export const cleanupInactiveWorkplaces = onSchedule(
    {
        schedule: "0 0 1 * *",
        timeZone: "UTC"
    },
    async (context) => {
    logger.info("Starting cleanup of inactive workplaces...");
  
    try {
      // Calculate the date threshold for inactivity (e.g., 6 months ago)
      const inactivityThreshold = new Date();
      inactivityThreshold.setMonth(inactivityThreshold.getMonth() - INACTIVE_MONTHS_THRESHOLD);
  
      // 1. Find workplaces that have no user activity after the inactivity threshold.
      // We'll check the UserWorkplaces collection for recent activity.
      const inactiveWorkplaces = await getInactiveWorkplaces(inactivityThreshold);
  
      if (inactiveWorkplaces.length === 0) {
        logger.info("No inactive workplaces found.");
        return null;
      }
  
      logger.info(`Found ${inactiveWorkplaces.length} inactive workplaces.`);
  
      // 2. Delete the inactive workplaces in batches.
      await deleteWorkplacesInBatches(inactiveWorkplaces);
  
      logger.info("Cleanup of inactive workplaces completed.");
    } catch (error) {
      logger.error("Error during cleanup of inactive workplaces:", error);
    }
    return null;
});

/**
 * Retrieves a list of workplaces that have been inactive since the given threshold.
 *
 * @param {Date} inactivityThreshold - The date threshold for inactivity.
 * @returns {Promise<string[]>} - A promise that resolves to an array of inactive workplace IDs.
 */
async function getInactiveWorkplaces(inactivityThreshold) {
    const inactiveWorkplaceIds = new Set();
    const workplaceIdsWithActivity = new Set();
  
    // Get all userWorkplaces with activity after the threshold
    const userWorkplacesWithActivitySnapshot = await db.collection('UserWorkplaces')
      .where('createdAt', '>', Timestamp.fromDate(inactivityThreshold))
      .get();
  
    userWorkplacesWithActivitySnapshot.forEach(doc => {
      const data = doc.data();
      workplaceIdsWithActivity.add(data.workpalceId);
    });
  
    // Get all workplaces
    const allWorkplacesSnapshot = await db.collection('workplaces').get();
  
    allWorkplacesSnapshot.forEach(doc => {
      const workplaceId = doc.id;
      // If a workplace is not in the active set, it's considered inactive
      if (!workplaceIdsWithActivity.has(workplaceId)) {
        inactiveWorkplaceIds.add(workplaceId);
      }
    });
  
    return Array.from(inactiveWorkplaceIds);
}

/**
 * Deletes a list of workplaces in batches.
 *
 * @param {string[]} workplaceIds - An array of workplace IDs to delete.
 * @returns {Promise<void>} - A promise that resolves when all workplaces have been deleted.
 */
async function deleteWorkplacesInBatches(workplaceIds) {
    let batch = db.batch();
    let batchCount = 0;
  
    for (const workplaceId of workplaceIds) {
      // Delete the workplace document
      const workplaceRef = db.collection('workplaces').doc(workplaceId);
      batch.delete(workplaceRef);
      batchCount++;
  
      // Delete all subcollections of the workplace
      const subcollections = await workplaceRef.listCollections();
      for (const subcollection of subcollections) {
        const subcollectionDocs = await subcollection.get();
        for (const doc of subcollectionDocs.docs) {
          batch.delete(doc.ref);
          batchCount++;
        }
      }
  
      // Commit the batch if it's full or if it's the last workplace
      if (batchCount >= BATCH_SIZE || workplaceId === workplaceIds[workplaceIds.length - 1]) {
        logger.info(`Deleting batch of ${batchCount} documents...`);
        await batch.commit();
        logger.info(`Batch deleted.`);
        batch = db.batch();
        batchCount = 0;
      }
    }
}

// checking similarity

// async function generateEmbedding(text) {
//     if (!process.env.GEMINI_API_KEY) {
//         logger.error('Gemini API key not set. Skipping embedding generation.');
//         return null;
//     }
//     try {
//         const model = genAI.getGenerativeModel({ model: "embedding-001" });
//         const result = await model.embedContent({
//             model: "embedding-001",
//             content: { role: "user", parts: [{ text }] },
//         });
//         const embedding = result.embedding.values;
//         return embedding;
//     } catch (e) {
//         logger.error('Error generating embedding: ', e);
//         return null;
//     }
// }

function cosineSimilarity(vecA, vecB) {
    if (!vecA || !vecB) return 0;
    let dotProduct = 0;
    let magnitudeA = 0;
    let magnitudeB = 0;
    for (let i = 0; i < vecA.length; i++) {
        dotProduct += vecA[i] * vecB[i];
        magnitudeA += vecA[i] * vecA[i];
        magnitudeB += vecB[i] * vecB[i];
    }
    magnitudeA = Math.sqrt(magnitudeA);
    magnitudeB = Math.sqrt(magnitudeB);
    if (magnitudeA === 0 || magnitudeB === 0) return 0;
    return dotProduct / (magnitudeA * magnitudeB);
}

// New onCall function to check and create hazard
export const checkSimilarHazard = onCall(async (request) => {

    const {workplaceId, embeding} = request.data; // Get hazard data from request
    logger.log(`Checking and creating hazard...`);

    if (!embeding) {
        logger.error('Missing required fields: embeding');
        throw new HttpsError('invalid-argument', 'Missing required fields: embeding');
    }

    try {
        // 1. Generate embedding for the new hazard
        if (!embeding) {
            logger.error(`Failed to generate embedding for new hazard`);
            throw new HttpsError('internal', 'Failed to generate embedding for new hazard');
        }

        // 2. Fetch all existing hazards with their embeddings
        logger.log(`workplace ${workplaceId}`);
        const hazardsSnapshot = await db.collection('workplaces').doc(workplaceId).collection('hseHazards').get();
        const existingHazards = hazardsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        // 3. Compare with existing hazard embeddings
        let isSimilar = false;
        for (const existingHazard of existingHazards) {
            // Check if the existing hazard has an embedding
            if (existingHazard.embeding) {
                const similarity = cosineSimilarity(embeding, existingHazard.embeding);
                logger.log(`Comparing with hazard ${existingHazard.id}: Similarity = ${similarity}`);

                if (similarity > 0.8) { // Adjust this threshold as needed
                    isSimilar = true;
                    break; // Exit the loop if a similar hazard is found
                }
            } else {
                logger.warn(`Hazard ${existingHazard.id} has no embedding.`);
            }
        }

        // 4. Take action based on similarity
        if (isSimilar) {
            logger.warn(`Similar hazard found! Not creating new hazard.`);
            return {similarityResult: 'similar' };
        } else {
            logger.log(`No similar hazard found. Creating new hazard.`);
            return {similarityResult: 'not similar'};
        }
    } catch (error) {
        logger.error('Error checking:', error);
        if (error instanceof HttpsError) {
            throw error; // Re-throw HttpsErrors for client-side handling
        } else {
            throw new HttpsError('internal', 'An unexpected error occurred.');
        }
    }
});

// drafts

//trigger to send email 
//Retrieve FCM Token: The code now assumes you're storing the user's FCM token (adminUser.fcmToken)
// in your user document. You'll need to implement the logger.logic to obtain and store the user's 
//FCM registration token. This typically happens on the client-side when the user logger.logs in. 
//You then store this token in Firestore along with the user's other data.

//TODO: check this AI genearated function
// trigger to send email
// exports.onWorkplaceCreated = onDocumentCreated(
//     'workplaces', // The Firestore collection to monitor for new documents
//     async (event) => {
//       const newWorkplace = event.data.data();  // Data of the newly created workplace

//         //  logger.logic to send your notification.  How you implement this will depend on what
//         // type of notification you want to send (e.g., Firebase Cloud Messaging, email, etc.)

//         // Example (using Firebase Admin SDK to get the admin's user details):
//         try {
//             const adminUser = await auth.getUser(newWorkplace.adminUserId); // Assuming you store the admin's UID in the workplace document
//             const adminEmail = adminUser.email;
//             // Then use a suitable notification service to send a notification to adminEmail.
//             console.logger.log(`New workplace ${event.data.id} created by ${adminEmail}.`);
//              // ... code to send notification using your preferred method (e.g. email, FCM, etc)
//              // Example using SendGrid:
//                 //  const sgMail = require('@sendgrid/mail'); // Install SendGrid
//                 // sgMail.setApiKey(process.env.SENDGRID_API_KEY);
//                 // const msg = {
//                 // to: adminEmail,
//                 // from: 'your-email@example.com', 
//                 // subject: 'New Workplace Created',
//                 // text: `A new workplace, ${newWorkplace.description}, has been created.`,
//                 // html: `<strong>A new workplace, ${newWorkplace.description}, has been created.</strong>`,
//                 // };
//                 // await sgMail.send(msg);
//         } catch (error) {
//             console.error('Error sending notification or getting admin user:', error);
//              // Handle the error gracefully, e.g., logger.log it. Don't re-throw it here, as it will crash your Cloud Function.
//         }
//         return null; // Returning null is important in Firestore event functions
//     }
// );
//TODO: check this AI genearated function
//trigger to send push notification
// exports.onWorkplaceCreated = onDocumentCreated(
//     'workplaces', 
//     async (event) => {
//         const newWorkplace = event.data.data(); 
//         try {
//             const adminUser = await getAuth().getUser(newWorkplace.adminUserId);
//             const adminEmail = adminUser.email;
//             // ***FCM Integration***
//             const messaging = getMessaging(); // Get the FCM instance

//             const tokens = [adminUser.fcmToken]; // Get the user's FCM token(s) from your user data - you will need to store this somewhere.  Can be an array of tokens.
//                 if (tokens && tokens.length > 0) { // Check if FCM token exists before sending

//                 const message = {
//                 tokens: tokens, // Array of tokens or a single token

//                     notification: {
//                         title: 'New Workplace Created!',
//                         body: `The workplace "${newWorkplace.description}" has been created.`,
//                     },
//                     data: {  // You can include any custom data you want here
//                         workplaceId: event.data.id,
//                         workplaceName: newWorkplace.description
//                     },
//                      // You can add other FCM options like Android/iOS specific configurations, etc. here
//                 };


//                 await messaging.sendMulticast(message);
//                 console.logger.log('Successfully sent FCM notification for new workplace.');

//                 } else {
//                     console.logger.log('No FCM token found for the user. Notification not sent.');
//                 }

//             console.logger.log(`New workplace ${event.data.id} created by ${adminEmail}.`);

//         } catch (error) {
//             console.error('Error sending notification or getting admin user:', error);
//         }
//         return null; 
//     }
// );

// Database Triggers: Cloud Functions can be triggered by changes in your Firestore database. 
//For example, you could use a function to:

// Send a notification when a new workplace is created.
// Update a counter whenever a new user joins a workplace.
// Perform data cleanup or transformations when documents are updated.
// Scheduled Tasks (Cron Jobs): Cloud Functions can be scheduled to run periodically. 
// This could be useful for tasks like:

// Sending daily or weekly summary emails to users.
// Deleting expired invitations from the database.
// Generating reports or performing other batch operations.
// HTTP Endpoints (Callable Functions): You are already using callable functions, 

//but they are helpful for many other purposes:
// Implementing custom server-side logger.logic that is not easily done client-side.
// Integrating with third-party APIs.
// Performing complex calculations or data processing.
// Sending Emails/Notifications: You can use Cloud Functions to send emails using services like SendGrid, 
//or send push notifications via Firebase Cloud Messaging.

// Backend for Mobile Apps: 
//While not strictly necessary if you only interact with Firestore, 
//Cloud Functions serve as a powerful serverless backend that provides flexibility and scalability for 
//growing mobile applications.