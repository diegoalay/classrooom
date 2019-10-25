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

  void _scanQR() async{
    try{
      _contentQR = await BarcodeScanner.scan();
    }catch(e){
      print(e);
    }
    if(_contentQR != null){
      DatabaseManager.searchInArray("coursesPerUser", Auth.uid, "courses", _contentQR).then((valid){
        if(!valid){
          DatabaseManager.addCourseByAccessCode(_contentQR,Auth.uid).then((dynamic text){
            if(text == null){  
              setState(() {
                Notify.show(
                  context: context,
                  text: 'El curso no existe.',
                  actionText: 'Ok',
                  backgroundColor: Colors.red[200],
                  textColor: Colors.black,
                  actionColor: Colors.black,
                  onPressed: (){
                    
                  }
                );                                
              });            
            }else{
              String textCourse = json.encode(text);
              print(textCourse);
              _coursePasser.sender.add(textCourse);                              
            }              
          }); 
        }else{
          Notify.show(
            context: context,
            text: 'El curso ya ha sido agregado.',
            actionText: 'Ok',
            backgroundColor: Colors.red[200],
            textColor: Colors.black,
            actionColor: Colors.black,
            onPressed: (){
              
            } 
          );                            
        }
      });                 
    }
  }

  void getCourses(){
    DatabaseManager.getCoursesPerUser().then(
      (List<String> ls) => setState(() {
        List<String> _coursesListString = ls;
        DatabaseManager.getCoursesPerUserByList(_coursesListString, Auth.uid).then(
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
    _coursesList = List<Course>();
    _coursePasser = Nav.coursePasser;
    if(_coursesList.isEmpty){
      getCourses();
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
                participants: jsonCourse['participants'],
                name: jsonCourse['name'],
                author: jsonCourse['author'],
                authorId: jsonCourse['authorId'],
                lessons: jsonCourse['lessons'],
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