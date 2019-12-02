import 'package:flutter/material.dart';
import 'package:classroom/course.dart';
import 'package:classroom/widget_passer.dart';
import 'dart:convert';
import 'package:classroom/nav.dart';
import 'package:classroom/database_manager.dart';
import 'package:classroom/auth.dart';
// import 'package:qr_utils/qr_utils.dart';
// import 'package:qrcode_reader/qrcode_reader.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:classroom/notify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoursesRoute extends StatefulWidget{
  static WidgetPasser activateQRPasser = WidgetPasser();

  const CoursesRoute();

  @override
  _CoursesRouteState createState() => _CoursesRouteState();
}

class _CoursesRouteState extends State<CoursesRoute> with TickerProviderStateMixin{
  WidgetPasser _coursePasser;
  List<Course> _coursesList;
  String _contentQR;
  List<String> _coursesIdList;

  void _scanQR() async{
    try{
      _contentQR = await BarcodeScanner.scan();
    }catch(e){
      print(e);
    }
    if(_contentQR != null){
      var path = 'coursesPerUser/${Auth.uid}';
      var data = {
          'obj': {
              'courseId': _contentQR,
          },
          'user': {
              'id': Auth.uid,
              'email': Auth.getEmail(),
              'name': Auth.getName(),
          },
      };
      DatabaseManager.requestAdd(path, data, 'addCourseByAccessCode').then((response){
        if(response['status'] == 1){
          dynamic course = response['course'];
          var text = {
            'id': course['id'],
            'usersLength': course['usersLength'] + 1,
            'lessons': course['lessons'],
            'name': course['name'],
            'author': course['author'],
            'authorId': course['authorId'],
            'owner': false
          };
          String textCourse = json.encode(text);
          _coursePasser.sender.add(textCourse);     
        } else {
          print(response);
        }
      });                                           
    }
  }


  void getCourses(){
    DatabaseManager.getCoursesPerUser().then(
      (List<String> ls) => setState(() {
        _coursesIdList = ls;
        DatabaseManager.getCoursesPerUserByList(_coursesIdList, Auth.uid).then(
          (List<Course> lc) => setState(() {
            _coursesList = lc;
          })
        );         
      })
    );    
  }

  @override
  void initState() {
    super.initState();

    Firestore.instance.collection('coursesPerUser').document(Auth.uid).snapshots().listen((snapshot){
      if(snapshot.exists) {
        var value = snapshot.data;
        List<String> courseList = List<String>.from(value['courses']);
        DatabaseManager.getCoursesPerUserByList(courseList, Auth.uid).then(
          (List<Course> lc) {
            if (this.mounted) {
              setState(() {
                _coursesList = lc;
              });
            }
          } 
        );
      }         
    });

    _coursesList = List<Course>();
    _coursePasser = Nav.coursePasser;
    if(_coursesList.isEmpty){
      // getCourses();
    }

    CoursesRoute.activateQRPasser.receiver.listen((value){
      if(value == 'QR'){
        _scanQR();
      }
    });
    
    _coursePasser.receiver.listen((newCourse){
      if(newCourse != null){
        Map jsonCourse = json.decode(newCourse);
        if (this.mounted){
          setState(() {
            _coursesList.add(
              Course(
                courseId: jsonCourse['id'],
                usersLength: jsonCourse['usersLength'],
                name: jsonCourse['name'],
                author: jsonCourse['author'],
                authorId: jsonCourse['authorId'],
                lessonsLength: jsonCourse['lessonsLength'],
                owner: jsonCourse['owner'],
              )
            );
          });
        }
      }
    });
  }
  

  Widget _getGridView(){
    final List<Course> _actualCoursesList = List.from(_coursesList);
    return OrientationBuilder(
      builder: (context, orientation){
        if(orientation == Orientation.portrait){
          return GridView.count(
            padding: EdgeInsets.all(6),
            crossAxisCount: 2,
            childAspectRatio: 1,
            children: _actualCoursesList,
          );
        }else{
          return GridView.count(
            padding: EdgeInsets.all(6),
            crossAxisCount: 4,
            childAspectRatio: 1,
            children: _actualCoursesList,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    CoursesRoute.activateQRPasser.sender.add(null);
    _coursePasser.sender.add(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _getGridView();
  }
}