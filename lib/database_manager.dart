
import 'package:classroom/course.dart';
import 'package:classroom/lesson.dart';
import 'package:classroom/question.dart';
import 'package:classroom/auth.dart';
import 'package:classroom/answer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DatabaseManager{
  static StorageReference storageRef = FirebaseStorage.instance.ref();
  static Directory tempDir = Directory.systemTemp;
  static FirebaseMessaging _fcm = FirebaseMessaging();

  static FirebaseMessaging getFcm(){
    return _fcm;
  }

  static saveDeviceToken(uid) async {
    String fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      DocumentReference ref = Firestore.instance.collection('users').document(uid).collection('tokens').document(fcmToken);
      await ref.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
      print(ref.documentID);
    }
  }

  static addCoursesPerUser(String uid, String course){ 
    List<String> list = new List<String>();  
    final DocumentReference reference = Firestore.instance.document('coursesPerUser/' + uid);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(reference);
      if (snapshot.data != null) {
        list = List<String>.from(snapshot.data['courses']);
        list.add(course);
        transaction.update(reference, <String, dynamic>{'courses': list});
      }else{
        list.add(course);
        reference.setData({
          'courses': list,
        });          
      }
    });        
  }

  static Future<void> addLessonPerCourse(String lesson, String course) async{
    List<String> list = new List<String>();  
    DocumentReference reference = Firestore.instance.document('lessonsPerCourse/' + course);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(reference);
      if (snapshot.data != null) {
        list = List<String>.from(snapshot.data['lessons']);
        list.add(lesson);
        transaction.update(reference, <String, dynamic>{'lessons': list});
      }else{
        list.add(lesson);
        reference.setData({
          'lessons': list,
        });          
      }
    });     
  }  

  static Future<void> addUsersPerCourse(String course, String uid) async{
    List<String> list = new List<String>();  
    DocumentReference reference = Firestore.instance.document('usersPerCourse/' + course);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(reference);
      if (snapshot.data != null) {
        list = List<String>.from(snapshot.data['users']);
        list.add(uid);
        transaction.update(reference, <String, dynamic>{'users': list});
      }else{
        list.add(uid);
        reference.setData({
          'users': list,
        });          
      }
    });     
  }  


  static void removeVoteToQuestion(String lessonId, String authorId, String question, String val){
    CollectionReference reference = Firestore.instance.collection('lessons').document(lessonId).collection("questions").document(question).collection("votes");
    Firestore.instance.runTransaction((Transaction transaction) async {
      transaction.set(reference.document(authorId), <String, dynamic>{"voted": false}).then((_){
        updateQuestion(lessonId,question, val, "votes");
      });
    });  
  }

  static void addVoteToQuestion(String lessonId, String authorId, String question, String val){   
    CollectionReference reference = Firestore.instance.collection('lessons').document(lessonId).collection("questions").document(question).collection("votes");
    Firestore.instance.runTransaction((Transaction transaction) async {
      transaction.set(reference.document(authorId), <String, dynamic>{"voted": true}).then((_){
        updateQuestion(lessonId,question, val, "votes");
      });
    });    
  }

  static void removeVoteToAnswer(String lessonId, String authorId, String question, String answer, String val){
    CollectionReference reference = Firestore.instance.collection('lessons').document(lessonId).collection("questions").document(question).collection("answers").document(answer).collection("votes");
    Firestore.instance.runTransaction((Transaction transaction) async {
      transaction.set(reference.document(authorId), <String, dynamic>{"voted": false}).then((_){
        updateAnswer(lessonId,question,answer,val,"votes");
      });
    });
  }

  static void addVoteToAnswer(String lessonId, String authorId, String question, String answer, String val){
    CollectionReference reference = Firestore.instance.collection('lessons').document(lessonId).collection("questions").document(question).collection("answers").document(answer).collection("votes");
    Firestore.instance.runTransaction((Transaction transaction) async {
      transaction.set(reference.document(authorId), <String, dynamic>{"voted": true}).then((_){
        updateAnswer(lessonId,question,answer,val,"votes");
      });
    });  
  }

  static Future<String> addAnswers(String question, String author, String authorId, String lesson, String text, int day, int month, int year, int hours, int minutes) async{
    DocumentReference reference = Firestore.instance.collection('lessons').document(lesson);
    await reference.collection("questions").document(question).collection("answers").document().setData({
      'text': text,
      'author': author,
      'authorId': authorId,
      'day': day,
      'month': month,
      'year': year,
      'hours': hours,
      'minutes': minutes,
      'votes': 0,
    }).then((_){
      updateQuestion(lesson, question, "1", "comments");
    });
    return reference.documentID;
  }

  static Future<String> addQuestions(String author, String authorId, String lesson, String text, int day, int month, int year, int hours, int minutes, {String attachPosition = ''}) async{
    DocumentReference reference = Firestore.instance.collection('lessons').document(lesson);
    reference.collection("questions").document().setData({
      'text': text,
      'author': author,
      'authorId': authorId,
      'day': day,
      'month': month,
      'year': year,
      'hours': hours,
      'minutes': minutes,
      'votes': 0,
      'attachPosition': attachPosition,
    }).then((_){
      updateLesson(lesson,"1","comments","","");
    });
    return reference.documentID;
  }

  static Future<void> deleteDocumentInCollection(String collection,document) async{
    await Firestore.instance.collection(collection).document(document).delete();
  }

  static Future<void> deleteFromArray(collection,document,field,val) async{
    List<dynamic> list = new List<dynamic>();
    DocumentReference reference = Firestore.instance.document(collection + '/' + document);
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(reference);
      list = List<String>.from(snapshot.data[field]);
      await reference.get().then((snapshot){
        list = List<String>.from(snapshot.data[field]);
      });
      list.remove(val);
      transaction.update(reference, <String, dynamic>{field: list});
    });  
  }

  static Future<bool> searchInArray(collection,document,field,compare) async{
    List<dynamic> lista = new List<dynamic>();
    DocumentReference reference = Firestore.instance.collection(collection).document(document);
    await reference.get().then((snapshot){
      if(snapshot.data != null) lista = List<String>.from(snapshot.data[field]);
    });
    return lista.contains(compare);
  }

  static void searchArray(collection,document,field,compare) async{
    CollectionReference reference = Firestore.instance.collection(collection);
    reference.where(field, arrayContains: compare).getDocuments().then((snapshot){
      List<DocumentSnapshot> docs = snapshot.documents;
      for(var doc in docs){
        print("DOC: ${doc.documentID}");  
      }
    });
  }

  static Future<dynamic> getDocumentIDInSearchFieldInCollection(location,collection,field,compare) async{
    var documentId = null;
    DocumentSnapshot doc;
    CollectionReference reference = Firestore.instance.document(location).collection(collection);
    await reference.where(field, isEqualTo: compare).getDocuments().then((snapshot){
      doc = snapshot.documents.first;  
    }).then((_){
      if(doc.exists) documentId = doc.documentID;       
    });
    return documentId;
  }

  static Future<dynamic> getFieldInDocument(location,document,field) async{
    var val;
    DocumentReference reference = Firestore.instance.collection(location).document(document);
    await reference.get().then((snapshot){
      if(snapshot.data != null) val = snapshot[field];     
    });
    if(val == null) return false;
    return val;
  }

  static Future<bool> searchFieldInCollection(location,collection,field,compare) async{
    bool find = false;
    List<DocumentSnapshot> docs = new List<DocumentSnapshot>();
    CollectionReference reference = Firestore.instance.document(location).collection(collection);
    await reference.where(field, isEqualTo: compare).getDocuments().then((snapshot){
      docs = snapshot.documents;
    }).then((_){
      if(docs.isNotEmpty) find = true;       
    });
    return find;
  }

  static Future<void> deleteLesson(String lessonId,String courseId) async{
    await deleteDocumentInCollection("lessons", lessonId).then((_){
      updateCourse(courseId, "-1", "lessons");
      deleteFromArray("lessonsPerCourse", courseId, "lessons", lessonId);
    });
  } 

  static Future<void> deleteCourse(String courseId, String uid) async{
    await deleteDocumentInCollection("courses", courseId).then((_){
      deleteFromArray("coursesPerUser", uid, "courses", courseId);
      // deleteFromArray("coursesPerUser", uid, "courses", courseId);
    });
} 


  static String addZero(int param){
    String paramString = param.toString();
    if(paramString.length > 1) return paramString;
    else return "0"+paramString;
  }

  static Future<String> addLesson(String uid, String name, String description, int day, int month, int year, String course) async{
    String date = (addZero(day)+"/"+addZero(month)+"/"+addZero(year));
    DocumentReference lesson = Firestore.instance.collection('lessons').document();
    lesson.setData({
      'authorId': uid,
      'courseId': course,
      'name': name,
      'fileExists' : false,
      'filePath' : '',
      'fileType' : '',
      'description': description,
      'date': date,
      'comments' : 0
    }).then((_){
      addLessonPerCourse(lesson.documentID,course);
      updateCourse(course,"1","lessons");
    });
    return lesson.documentID;
  }

  static Future<String> addCourse(String authorId, String author, String name) async{
    DocumentReference course = Firestore.instance.collection('courses').document();
    course.setData({
      'name': name,
      'author': author,
      'authorId': authorId,
      'participants': 1,
      'lessons' : 0,
    }).then((_){
      addCoursesPerUser(authorId,course.documentID);
      addUsersPerCourse(course.documentID,authorId);
      updateCourse(course.documentID,course.documentID,"accessCode");
    });
    return course.documentID;
  }

  static Future<void> updateAnswer(String lesson, String question, String answer, String param, String column) async{
    DocumentReference reference = Firestore.instance.document('lessons/' + lesson + "/questions/" + question + "/answers/" + answer);
    await Firestore.instance.runTransaction((Transaction transaction) async {
      switch(column){
        case "votes": {
          transaction.update(reference, <String, dynamic>{'votes': FieldValue.increment(int.parse(param))});      
          break;
        }
        default: {
          transaction.update(reference, <String, dynamic>{column: param});       
          break;
        }
      }           
    });  
  }

  static Future<String> getFiles(String type, String lessonId) async{
    StorageReference ref =  storageRef.child(type).child(lessonId);
    List<int> bytes = await ref.getData(1024*1024*10); 
    File file;
    var directory = await getApplicationDocumentsDirectory();
    file = new File('${directory.path}/$lessonId.pdf');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<String> uploadFiles(String type, String lessonId, String filePath) async{  
    switch(type){
      case "pdf": {
        StorageUploadTask uploadTask = storageRef.child(type).child(lessonId).putFile(
          File(filePath),
          StorageMetadata(
            contentType: type,
          ),
        );
        await updateLesson(lessonId, true, "fileExists", type, filePath);
        break;        
      }
      case "url": {
        await updateLesson(lessonId, true, "fileExists", type, filePath);
      }
    }    
    return filePath;
  }

  static Future<void> updateQuestion(String lesson, String question, String param, String column) async{
    DocumentReference reference = Firestore.instance.document('lessons/' + lesson + "/questions/" + question);
    Firestore.instance.runTransaction((Transaction transaction) async {
      switch(column){
        case "votes": {
          transaction.update(reference, <String, dynamic>{'votes': FieldValue.increment(int.parse(param))});   
          break;
        }
        default: {
          transaction.update(reference, <String, dynamic>{column: param});    
          break;
        }
      }           
    });       
  }

  static Future<void> updateLesson(String code, var param, String column, String type, String filePath) async{
    DocumentReference reference = Firestore.instance.document('lessons/' + code);
    Firestore.instance.runTransaction((Transaction transaction) async {
        switch(column){
          case "comments": {
            transaction.update(reference, <String, dynamic>{'comments': FieldValue.increment(int.parse(param))});      
            break;
          }
          case "fileExists": {
            transaction.update(reference, <String, dynamic>{'fileExists': param, 'fileType': type, 'filePath': filePath});      
            break;
          }          
          default: {;
            transaction.update(reference, <String, dynamic>{column: param});       
            break;
          }
        }           
    });     
  }

  static Future<void> updateCourse(String code, var param, String column) async{
    DocumentReference reference = Firestore.instance.document('courses/' + code);
    Firestore.instance.runTransaction((Transaction transaction) async {
        switch(column){
          case "participants":
          case "lessons": {
            transaction.update(reference, <String, dynamic>{column: FieldValue.increment(int.parse(param))});      
            break;
          }
          case "accessCode": 
          case "name":{
            transaction.update(reference, <String, dynamic>{'accessCode': param});       
            break;
          } 
        }           
    }); 
  }

  static Future<Map> addCourseByAccessCode(String code, String uid) async{
    Map course;
    DocumentReference reference = Firestore.instance.collection('courses').document(code);
    await reference.get().then((snapshot){
      if(snapshot.data != null){
        print("snap: ${snapshot.data}");
        int participants = snapshot.data['participants'];
        updateCourse(code,"1","participants");
        addUsersPerCourse(code,uid);
        addCoursesPerUser(uid,code);
        course = {
          'accessCode': snapshot.data['accessCode'],
          'participants': participants + 1,
          'lessons': snapshot.data['lessons'],
          'name': snapshot.data['name'],
          'author': snapshot.data['author'],
          'authorId': snapshot.data['authorId'],
          'owner': false
        };
      }
    });
    return course;
  }

  static Future<dynamic> getFieldFrom(String collection, String document, String field) async{
    var val;
    DocumentReference reference = Firestore.instance.collection(collection).document(document);
    await reference.get().then((snapshot){
      val = snapshot.data[field];
    });        
    return field;
  }

  static Future<List<Answer>> getAnswersPerQuestionByList(String lessonId, String questionId) async{
    List<Answer> answersList = new List<Answer>(); 
    CollectionReference reference = Firestore.instance.collection('lessons').document(lessonId).collection("questions").document(questionId).collection("answers");
    await reference.orderBy("votes", descending: true).getDocuments().then((snapshot){
      List<DocumentSnapshot> docs = snapshot.documents;
      for(var doc in docs){
        answersList.add(
          Answer( 
            answerId: doc.documentID,
            questionId: questionId,
            text: doc['text'],
            author: doc['author'],
            authorId: doc['authorId'],
            lessonId: lessonId,
            // day: doc['day'],
            // month: doc['month'],
            // year: doc['year'],
            // hours: doc['hours'],
            // minutes: doc['minutes'],                
            votes: doc['votes'],
          )
        );  
      }
    });  
    return answersList;
  } 


  static Future<List<Course>> getCoursesPerUserByList(List<String> listString, String uid) async{
    List<Course> coursesList = List<Course>();
    bool userOwner;
    try{
      for (var eachCourse in listString) {
        await Firestore.instance.collection('courses').document(eachCourse).get().then((snapshot){
          Map<dynamic,dynamic> course = snapshot.data;
          if(course != null){
            if(course['authorId'] == uid) userOwner = true;
            else userOwner = false;
            coursesList.add(
              Course(
                courseId: course['accessCode'],
                participants: course['participants'],
                lessons: course['lessons'],
                name: course['name'],
                author: course['author'],
                authorId: course['authorId'],
                owner: userOwner,
              )
            );    
          }
        }); 
      }
    }catch(e){
      print("error getCoursesPerUserByList: $e");
    } 
    return coursesList;
  } 

static Future<List<Lesson>> getLessonsPerCourseByList(List<String> listString, String uid, String courseId) async{
    List<Lesson> lessonsList = List<Lesson>();
    bool userOwner;
    try{
      for (var eachLesson in listString) {
        await Firestore.instance.collection('lessons').document(eachLesson).get().then((snapshot){
          Map<dynamic,dynamic> lesson = snapshot.data;
          if(lesson != null){
            if(lesson['authorId'] == uid) userOwner = true;
            else userOwner = false;
            String date = (lesson['date']).toString();
            lessonsList.add(
              Lesson(
                lessonId: eachLesson,
                courseId: courseId,
                comments: lesson['comments'],
                date: lesson['date'],
                description: lesson['description'],
                name: lesson['name'],
                fileExists: lesson['fileExists'],
                fileType: lesson['fileType'],
                filePath: lesson['filePath'],
                owner: userOwner,
              )
            );       
          }
        }); 
      }
    }catch(e){
      print("error getLessonsPerCourseByList: $e");
    } 
    return lessonsList;
  } 

  static Future<List<String>> getLessonsPerCourse(String course) async{
    List<String> lessonsList = List<String>();
    try{
      DocumentReference reference = Firestore.instance.collection('lessonsPerCourse').document(course);
      await reference.get().then((snapshot){
        lessonsList = List<String>.from(snapshot.data['lessons']);
      });
    }catch(e){
      print("error getLessonsPerUser: $e");
    } 
    print("lessonList $lessonsList");
    return lessonsList;
  } 

  static Future<List<String>> getCoursesPerUser() async{
    List<String> coursesList = List<String>();
    try{
      DocumentReference reference = Firestore.instance.collection('coursesPerUser').document(Auth.uid);
      await reference.get().then((snapshot){
        coursesList = List<String>.from(snapshot.data['courses']);
      });
    }catch(e){
      print("error getCoursesPerUser: $e");
    }
    return coursesList;
  }    
}