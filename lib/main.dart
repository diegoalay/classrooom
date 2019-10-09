import 'package:flutter/material.dart';
import 'package:classroom/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:io';

void main() => runApp(new Classroom());

class Classroom extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Classroom> {
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    var android = new AndroidInitializationSettings('mipmap/launcher_icon');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        showNotification(msg);
        print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) {
        showNotification(msg);
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) {
        showNotification(msg);
        print(" onMessage called ${(msg)}");
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    firebaseMessaging.getToken().then((token) {
      print('token here: $token');
    });
  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
      'sdffds dsffds',
      "CHANNLE NAME",
      "channelDescription",
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, msg['notification']['title'], msg['notification']['body'], platform);
  }

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

// class Classroom extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Classroom',
//       theme: ThemeData(
//         fontFamily: 'Roboto Condensed', 
//         primaryColor: Color.fromARGB(255, 255, 96, 64), 
//         primaryColorLight: Color.fromARGB(255, 255, 235, 231),
//         accentColor: Color.fromARGB(255, 0, 11, 43),
//         cardColor: Color.fromARGB(255, 233, 238, 255),
//         sliderTheme: SliderThemeData(
//           thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
//           // overlayShape: SliderComponentShape.noOverlay
//         ),
//       ),
//       home: Scaffold(
//         resizeToAvoidBottomPadding: false,
//         body: Login()
//       ),
//     );
//   }
// }