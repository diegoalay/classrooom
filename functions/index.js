const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.lessonNotification = functions.firestore.document('lessons/{lessonId}').onCreate(async snapshot => {
    const ref = snapshot.data();
    console.log('new lesson: ' + snapshot.id);
    const querySnapshot = await admin.firestore()
      .collection('users')
      .doc(ref.authorId)
      .collection('tokens')
      .get();
    const tokens = querySnapshot.docs.map(snap => snap.id);
    console.log(tokens);
    const payload = {
      notification: {
        title: 'Nueva lección disponible',
        body: `${ref.name}`,
        icon: 'your-icon-url',
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };
    return admin.messaging().sendToDevice(tokens, payload);
});
