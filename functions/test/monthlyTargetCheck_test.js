import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { onSchedule } from "firebase-functions/v2/scheduler";
import { mockConfig } from 'firebase-functions-test';
import { logger } from 'firebase-functions';
import assert from 'assert';
import { cleanupInactiveWorkplaces } from '../src/index'; // Adjust the path if needed
import { monthlyTargetCheck } from '../src/index'; // Adjust the path if needed
import admin from 'firebase-admin';




// Initialize Firebase Admin SDK
initializeApp();
const db = getFirestore();

// Set the environment variable for testing
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
process.env.FUNCTIONS_EMULATOR = 'true';

// Mock the config
mockConfig({
    firebase: {
        projectId: 'hseassist'
    }
});

describe('monthlyTargetCheck', () => {
    beforeEach(async () => {
        // Clear the database before each test
        await clearFirestore();
    });
    after(async () => {
        // Clear the database after all tests
        await clearFirestore();
    });
    it('should assign mini-sessions when the target is not met', async () => {
        // Arrange
        const currentYear = new Date().getFullYear();
        const currentMonth = new Date().getMonth();
        const startOfYear = new Date(currentYear, 0, 1);
        const startOfNextMonth = new Date(currentYear, currentMonth + 1, 1);
        const targetHazardIdsPerYear = 120;
        const targetHazardIdsThisMonth = Math.round(targetHazardIdsPerYear / 12 * (currentMonth + 1));

        // Create settings
        await db.collection('settings').doc('adminSettings').set({ targetHazardIdsPerYear });

        // Create hazards (less than the target)
        await db.collection('hazards').add({ createdAt: Timestamp.fromDate(new Date(currentYear, currentMonth, 1)) });
        await db.collection('hazards').add({ createdAt: Timestamp.fromDate(new Date(currentYear, currentMonth, 15)) });

        // Create mini-sessions
        await db.collection('miniSessions').add({ title: 'Mini Session 1' });
        await db.collection('miniSessions').add({ title: 'Mini Session 2' });

        // Create users
        const user1 = await db.collection('authUsers').add({ email: 'testuser1@example.com', assignedMiniSessions: [] });
        const user2 = await db.collection('authUsers').add({ email: 'testuser2@example.com', assignedMiniSessions: [] });

        // Act
        await monthlyTargetCheck(null);

        // Assert
        const user1Doc = await db.collection('authUsers').doc(user1.id).get();
        const user2Doc = await db.collection('authUsers').doc(user2.id).get();
        const user1Data = user1Doc.data();
        const user2Data = user2Doc.data();
        const currentHazardCount = (await db.collection("hazards")
            .where("createdAt", ">=", Timestamp.fromDate(startOfYear))
            .where("createdAt", "<", Timestamp.fromDate(startOfNextMonth))
            .get()).size;
        const difference = targetHazardIdsThisMonth - currentHazardCount;
        assert.ok(user1Data.assignedMiniSessions.length > 0 || user2Data.assignedMiniSessions.length > 0);
        assert.ok(user1Data.assignedMiniSessions.length + user2Data.assignedMiniSessions.length >= difference);
        logger.log('Test passed: Mini-sessions assigned when target not met.');
    });

    it('should not assign mini-sessions when the target is met', async () => {
        // Arrange
        const currentYear = new Date().getFullYear();
        const currentMonth = new Date().getMonth();
        const startOfYear = new Date(currentYear, 0, 1);
        const startOfNextMonth = new Date(currentYear, currentMonth + 1, 1);
        const targetHazardIdsPerYear = 120;
        const targetHazardIdsThisMonth = Math.round(targetHazardIdsPerYear / 12 * (currentMonth + 1));

        // Create settings
        await db.collection('settings').doc('adminSettings').set({ targetHazardIdsPerYear });

        // Create hazards (more than the target)
        for (let i = 0; i < targetHazardIdsThisMonth + 5; i++) {
            await db.collection('hazards').add({ createdAt: Timestamp.fromDate(new Date(currentYear, currentMonth, 1)) });
        }

        // Create mini-sessions
        await db.collection('miniSessions').add({ title: 'Mini Session 1' });

        // Create users
        const user1 = await db.collection('authUsers').add({ email: 'testuser1@example.com', assignedMiniSessions: [] });

        // Act
        await monthlyTargetCheck(null);

        // Assert
        const user1Doc = await db.collection('authUsers').doc(user1.id).get();
        const user1Data = user1Doc.data();
        assert.strictEqual(user1Data.assignedMiniSessions.length, 0);
        logger.log('Test passed: No mini-sessions assigned when target met.');
    });

    it('should handle missing settings document', async () => {
        // Act
        await monthlyTargetCheck(null);

        // Assert
        // If no error is thrown, the test passes
        logger.log('Test passed: Missing settings document handled.');
    });

    it('should handle targetHazardIdsPerYear equal to 0', async () => {
        // Arrange
        await db.collection('settings').doc('adminSettings').set({ targetHazardIdsPerYear: 0 });

        // Act
        await monthlyTargetCheck(null);

        // Assert
        // If no error is thrown, the test passes
        logger.log('Test passed: targetHazardIdsPerYear equal to 0 handled.');
    });

    it('should handle missing mini-sessions', async () => {
        // Arrange
        const currentYear = new Date().getFullYear();
        const currentMonth = new Date().getMonth();
        const targetHazardIdsPerYear = 120;

        // Create settings
        await db.collection('settings').doc('adminSettings').set({ targetHazardIdsPerYear });

        // Create hazards (less than the target)
        await db.collection('hazards').add({ createdAt: Timestamp.fromDate(new Date(currentYear, currentMonth, 1)) });

        // Create users
        const user1 = await db.collection('authUsers').add({ email: 'testuser1@example.com', assignedMiniSessions: [] });

        // Act
        await monthlyTargetCheck(null);

        // Assert
        // If no error is thrown, the test passes
        logger.log('Test passed: Missing mini-sessions handled.');
    });
});

async function clearFirestore() {
    const collections = await db.listCollections();
    for (const collection of collections) {
        const docs = await collection.get();
        const batch = db.batch();
        docs.forEach(doc => batch.delete(doc.ref));
        await batch.commit();
    }
}
