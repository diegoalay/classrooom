import 'package:flutter/material.dart';
import 'package:classroom/login.dart';

void main() {
  runApp(Classroom());
}

class Classroom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Classroom',
      theme: ThemeData(
        fontFamily: 'Roboto Condensed', 
        primaryColor: Color.fromARGB(255, 255, 96, 64), 
        primaryColorLight: Color.fromARGB(255, 255, 235, 231),
        accentColor: Color.fromARGB(255, 0, 11, 43),
        cardColor: Color.fromARGB(255, 233, 238, 255),
        sliderTheme: SliderThemeData(
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
          // overlayShape: SliderComponentShape.noOverlay
        ),
      ),
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Login()
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// void main() => runApp(new MyApp());

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String textValue = 'Hello World !';
//   FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       new FlutterLocalNotificationsPlugin();

//   @override
//   void initState() {
//     super.initState();

//     var android = new AndroidInitializationSettings('mipmap/ic_launcher');
//     var ios = new IOSInitializationSettings();
//     var platform = new InitializationSettings(android, ios);
//     flutterLocalNotificationsPlugin.initialize(platform);

//     firebaseMessaging.configure(
//       onLaunch: (Map<String, dynamic> msg) {
//         showNotification(msg);
//         print(" onLaunch called ${(msg)}");
//       },
//       onResume: (Map<String, dynamic> msg) {
//         showNotification(msg);
//         print(" onResume called ${(msg)}");
//       },
//       onMessage: (Map<String, dynamic> msg) {
//         showNotification(msg);
//         print(" onMessage called ${(msg)}");
//       },
//     );
//     firebaseMessaging.requestNotificationPermissions(
//         const IosNotificationSettings(sound: true, alert: true, badge: true));
//     firebaseMessaging.onIosSettingsRegistered
//         .listen((IosNotificationSettings setting) {
//       print('IOS Setting Registed');
//     });
//     firebaseMessaging.getToken().then((token) {
//       print('token here: $token');
//     });
//   }

//   showNotification(Map<String, dynamic> msg) async {
//     var android = new AndroidNotificationDetails(
//       'sdffds dsffds',
//       "CHANNLE NAME",
//       "channelDescription",
//     );
//     var iOS = new IOSNotificationDetails();
//     var platform = new NotificationDetails(android, iOS);
//     await flutterLocalNotificationsPlugin.show(
//         0, "This is title", "this is demo", platform);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       home: new Scaffold(
//         appBar: new AppBar(
//           title: new Text('Push Notification'),
//         ),
//         body: new Center(
//           child: new Column(
//             children: <Widget>[
//               new Text(
//                 textValue,
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

