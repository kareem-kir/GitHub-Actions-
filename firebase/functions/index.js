const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Initialize Firestore
const db = admin.firestore();

// Cloud Function to handle user creation
exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
  try {
    const userProfile = {
      phone: user.phoneNumber || '',
      email: user.email || '',
      displayName: user.displayName || 'مستخدم جديد',
      status: 'free',
      subscriptionExpiry: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      lastActive: admin.firestore.FieldValue.serverTimestamp(),
      downloadedTracks: [],
      totalDownloads: 0,
    };

    await db.collection('users').doc(user.uid).set(userProfile);
    console.log('User profile created for:', user.uid);
  } catch (error) {
    console.error('Error creating user profile:', error);
  }
});

// Cloud Function to clean up user data on deletion
exports.deleteUserData = functions.auth.user().onDelete(async (user) => {
  try {
    await db.collection('users').doc(user.uid).delete();
    console.log('User data deleted for:', user.uid);
  } catch (error) {
    console.error('Error deleting user data:', error);
  }
});

// Cloud Function to update user last active timestamp
exports.updateLastActive = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const newData = change.after.data();
    const oldData = change.before.data();

    // Only update if it's not already a lastActive update
    if (newData.lastActive === oldData.lastActive) {
      try {
        await change.after.ref.update({
          lastActive: admin.firestore.FieldValue.serverTimestamp()
        });
      } catch (error) {
        console.error('Error updating last active:', error);
      }
    }
  });

// Cloud Function to send notifications (for future use)
exports.sendNotification = functions.https.onCall(async (data, context) => {
  // Check if user is admin
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const adminDoc = await db.collection('admins').doc(context.auth.uid).get();
  if (!adminDoc.exists || !adminDoc.data().isActive) {
    throw new functions.https.HttpsError('permission-denied', 'User must be an admin');
  }

  const { title, body, userIds } = data;

  try {
    // Get user tokens (you would need to store FCM tokens in user documents)
    const userDocs = await db.collection('users')
      .where(admin.firestore.FieldPath.documentId(), 'in', userIds)
      .get();

    const tokens = [];
    userDocs.forEach(doc => {
      const userData = doc.data();
      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
      }
    });

    if (tokens.length > 0) {
      const message = {
        notification: {
          title: title,
          body: body,
        },
        tokens: tokens,
      };

      const response = await admin.messaging().sendMulticast(message);
      console.log('Notifications sent:', response.successCount);
      
      return { success: true, sent: response.successCount };
    }

    return { success: false, message: 'No valid tokens found' };
  } catch (error) {
    console.error('Error sending notification:', error);
    throw new functions.https.HttpsError('internal', 'Error sending notification');
  }
});

// Cloud Function to generate analytics data
exports.generateAnalytics = functions.https.onCall(async (data, context) => {
  // Check if user is admin
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const adminDoc = await db.collection('admins').doc(context.auth.uid).get();
  if (!adminDoc.exists || !adminDoc.data().isActive) {
    throw new functions.https.HttpsError('permission-denied', 'User must be an admin');
  }

  try {
    // Get user statistics
    const usersSnapshot = await db.collection('users').get();
    const totalUsers = usersSnapshot.size;
    
    let freeUsers = 0;
    let weeklyUsers = 0;
    let monthlyUsers = 0;
    let yearlyUsers = 0;
    let activeSubscriptions = 0;

    const now = new Date();
    
    usersSnapshot.forEach(doc => {
      const userData = doc.data();
      const status = userData.status;
      
      switch (status) {
        case 'free':
          freeUsers++;
          break;
        case 'weekly':
          weeklyUsers++;
          break;
        case 'monthly':
          monthlyUsers++;
          break;
        case 'yearly':
          yearlyUsers++;
          break;
      }

      // Check if subscription is active
      if (status !== 'free' && userData.subscriptionExpiry) {
        const expiryDate = userData.subscriptionExpiry.toDate();
        if (expiryDate > now) {
          activeSubscriptions++;
        }
      }
    });

    // Get categories count
    const categoriesSnapshot = await db.collection('categories')
      .where('isActive', '==', true)
      .get();
    const totalCategories = categoriesSnapshot.size;

    // Get tracks count
    const tracksSnapshot = await db.collection('tracks')
      .where('isActive', '==', true)
      .get();
    const totalTracks = tracksSnapshot.size;

    return {
      users: {
        total: totalUsers,
        free: freeUsers,
        weekly: weeklyUsers,
        monthly: monthlyUsers,
        yearly: yearlyUsers,
        activeSubscriptions: activeSubscriptions,
      },
      content: {
        categories: totalCategories,
        tracks: totalTracks,
      },
      generatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
  } catch (error) {
    console.error('Error generating analytics:', error);
    throw new functions.https.HttpsError('internal', 'Error generating analytics');
  }
});

// Cloud Function to cleanup expired subscriptions
exports.cleanupExpiredSubscriptions = functions.pubsub
  .schedule('0 2 * * *') // Run daily at 2 AM
  .onRun(async (context) => {
    try {
      const now = new Date();
      const usersSnapshot = await db.collection('users')
        .where('subscriptionExpiry', '<', now)
        .where('status', '!=', 'free')
        .get();

      const batch = db.batch();
      let updateCount = 0;

      usersSnapshot.forEach(doc => {
        batch.update(doc.ref, {
          status: 'free',
          subscriptionExpiry: null,
        });
        updateCount++;
      });

      if (updateCount > 0) {
        await batch.commit();
        console.log(`Updated ${updateCount} expired subscriptions`);
      }

      return null;
    } catch (error) {
      console.error('Error cleaning up expired subscriptions:', error);
    }
  });
