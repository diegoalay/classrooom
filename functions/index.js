const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.answersNotifications = functions.firestore.document('lessons/{lessonId}/questions/{questionId}/answers/{answerId}').onCreate(async snapshot => {
  const ref = snapshot.data();
  console.log(`new answer ${ref}`);
  if(ref.authorId !== ref.createdById){
    var tokensRef = await admin.firestore().collection('users').where('uid', '==', ref.createdById).get();
    if (tokensRef.empty) {
      console.log('no tokens found');
    } else {  
      var tokens = [];
      tokensRef.forEach(function(token) {
        var data = token.data();
        tokens.push(data.token);
      });    
      console.log(`tokens ${tokens}`);
      const payload = {
        notification: {
          title: 'Nueva respuesta disponible',
          body: `${ref.author} te ha respondido "${ref.text}" a la pregunta ${ref.questionText}.`,
          icon: 'your-icon-url',
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
      };
      return admin.messaging().sendToDevice(tokens, payload); 
    }
  }
});

exports.lessonNotifications = functions.firestore.document('lessons/{lessonId}').onCreate(async snapshot => {
  const ref = snapshot.data();
  console.log(ref);
  const usersRef = await admin.firestore().collection('usersPerCourse').doc(ref.courseId).get();
  var users = (usersRef.data())['users'];
  var tokensRef = admin.firestore().collection('users');
  console.log(`users ${users}`);
  if(!(users.empty)){
    users.forEach(function(user){
      if(user !== ref.authorId) tokensRef = tokensRef.where('uid', '=-', user);
    });
    tokensRef = await tokensRef.get();
    if (tokensRef.empty) {
      console.log('no tokens found');
    } else {
      var tokens = [];
      tokensRef.forEach(function(token) {
        var data = token.data();
        tokens.push(data.token);
      });    
      console.log(`tokens ${tokens}`);
      const payload = {
        notification: {
          title: `Nueva lección disponible`,
          body: `Se ha agregado la lección ${ref.name} al curso ${ref.courseName}.`,
          icon: 'your-icon-url',
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
        }
      };
      return admin.messaging().sendToDevice(tokens, payload);            
    }          
  }      
});