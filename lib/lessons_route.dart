import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/lesson.dart';
import 'package:classroom/widget_passer.dart';
import 'package:classroom/nav.dart';
import 'package:classroom/database_manager.dart';
import 'package:classroom/auth.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:classroom/notify.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LessonsRoute extends StatefulWidget{
  final String author, name, courseId, authorId;
  final int usersLength;
  final bool owner;

  const LessonsRoute({
    @required this.authorId,
    @required this.author,
    @required this.name,
    @required this.courseId,
    this.usersLength: 1,
    this.owner: false,
  });

  _LessonsRouteState createState() => _LessonsRouteState();
}

class _LessonsRouteState extends State<LessonsRoute> with SingleTickerProviderStateMixin{
  WidgetPasser _lessonPasser;
  ScrollController _scrollController;
  AnimationController _qrHeightController;
  Animation<Offset> _qrOffsetFloat;
  String _usersLength, _name;
  bool _disabled;

  List<Lesson> _lessons;

  @override
  void initState() {
    super.initState();

    _disabled = false;

    _qrHeightController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _qrOffsetFloat = Tween<Offset>(
      end: Offset.zero,
      begin: Offset(0, 0.8425),
    ).animate(
      CurvedAnimation(
        parent: _qrHeightController,
        curve: Curves.easeInOutQuart,
      )
    );

    _lessonPasser = Nav.lessonPasser;
    _usersLength = '${widget.usersLength}';
    _name = '${widget.name}';
    _scrollController = ScrollController();

    _lessons = List<Lesson>();

    Firestore.instance.collection("courses").document(widget.courseId).snapshots().listen((snapshot){
      var value = snapshot.data;
      if(value != null) {
        if(this.mounted){
          setState(() {
            _name = value['name'];
            _usersLength = value['usersLength'].toString();
          });
        } 
      }
    });

    if(widget.authorId == Auth.uid){
      Firestore.instance.collection("lessons").where('courseId', isEqualTo: widget.courseId).snapshots().listen((snapshot){
        List<DocumentChange> docs = snapshot.documentChanges;
        if(docs != null){
          for(var doc in docs){
            if(doc.type == DocumentChangeType.added){
              if(this.mounted){
                setState(() {
                  _lessons.add(Lesson(
                      key: Key('lesson-${doc.document.documentID}'),
                      lessonId: doc.document.documentID,
                      name : doc.document['name'],
                      date : doc.document['date'],
                      lessonsLength: doc.document['lessonsLength'],
                      owner: widget.owner,
                      authorId: widget.authorId,
                      courseId: widget.courseId,
                      fileType: doc.document['fileType'],
                      fileExists: doc.document['fileExists'],
                      status: doc.document['status'],
                      filePath: doc.document['filePath'],                    
                      description: doc.document['description'],
                      onLessonDelete: _handleLessonDelete,
                    )
                  );
                });
              }      
            }else if(doc.type == DocumentChangeType.removed){
              print('change');      
            }else if(doc.type == DocumentChangeType.removed){
              print('delete');
            }
          }
        }
      });      
    } else {
      Firestore.instance.collection("lessons").where('courseId', isEqualTo: widget.courseId).where('status', isEqualTo: true).snapshots().listen((snapshot){
        List<DocumentChange> docs = snapshot.documentChanges;
        if(docs != null){
          for(var doc in docs){
            if(doc.type == DocumentChangeType.added){
              if(this.mounted){
                setState(() {
                  _lessons.add(Lesson(
                      key: Key('lesson-${doc.document.documentID}'),
                      lessonId: doc.document.documentID,
                      name : doc.document['name'],
                      date : doc.document['date'],
                      lessonsLength: doc.document['lessonsLength'],
                      owner: widget.owner,
                      authorId: widget.authorId,
                      courseId: widget.courseId,
                      fileType: doc.document['fileType'],
                      fileExists: doc.document['fileExists'],
                      status: doc.document['status'],
                      filePath: doc.document['filePath'],                    
                      description: doc.document['description'],
                      onLessonDelete: _handleLessonDelete,
                    )
                  );
                });
              }      
            }else if(doc.type == DocumentChangeType.removed){
              print('change');      
            }else if(doc.type == DocumentChangeType.removed){
              print('delete');
            }
          }
        }
      });
    }

    _lessonPasser.receiver.listen((newLesson){
      if(newLesson != null){
        Map jsonLesson = json.decode(newLesson);
        if(this.mounted){
          setState(() {
            _lessons.add(
              Lesson(
                key: Key('lesson-${jsonLesson['lessonId']}'),
                fileExists: jsonLesson['fileExists'],
                status: jsonLesson['status'],
                lessonId: jsonLesson['lessonId'],
                courseId: jsonLesson['courseId'],
                name: jsonLesson['name'],
                date: jsonLesson['date'],
                description: jsonLesson['description'],
                lessonsLength: jsonLesson['lessonsLength'],
                owner: widget.owner,
                authorId: widget.authorId,
                onLessonDelete: _handleLessonDelete,
              )
            );
          });
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(
              milliseconds: 500,
            ),  
            curve: Curves.ease,
          );
        }
      }
    });    
  }

  void _handleLessonDelete(String lessonId) {
    print('ESTO SE EJECUTA');
    this.setState(() {
      _lessons = _lessons.where((lesson) => lesson.lessonId != lessonId).toList();
    });
  }

  @override
  void dispose() {
    _lessonPasser.sender.add(null);
    super.dispose();
  }

  Widget _getCourseAuthor(BuildContext context){
    if(widget.owner) return Container();
    else return Row(
      children: <Widget>[
        Text(
          widget.author,
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 16,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 6, right: 3),
          child: Icon(
            FontAwesomeIcons.solidCircle,
            size: 3,
            color: Theme.of(context).accentColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if(!_disabled) return Container(
      padding: EdgeInsets.only(top: 12),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:Color.fromARGB(10, 0, 0, 0),
                  width: 3,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          _name,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        _getCourseAuthor(context),
                        Icon(
                          FontAwesomeIcons.male,
                          size: 16,
                          color: Theme.of(context).accentColor,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            _usersLength,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  child: ListView.builder(
                    controller: _scrollController,
                    // physics: ScrollPhysics(
                    //   parent: BouncingScrollPhysics(),
                    // ),
                    padding: EdgeInsets.only(top: 10, bottom: 65),
                    itemCount: _lessons.length,
                    itemBuilder: (context, index){
                      return _lessons.elementAt(index);
                    },
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SlideTransition(
                    position: _qrOffsetFloat,
                    child: Container(
                      padding: EdgeInsets.only(top: 6, bottom: 6),
                      height: 400, //65
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color:Color.fromARGB(10, 0, 0, 0),
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: (){
                              final AnimationStatus status = _qrHeightController.status;
                              if(status == AnimationStatus.completed || status == AnimationStatus.forward) _qrHeightController.reverse();
                              else if(status == AnimationStatus.dismissed || status == AnimationStatus.reverse) _qrHeightController.forward();
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Agrega nuevos miembros:',
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                                GestureDetector(
                                  child: Text(
                                    widget.courseId,
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onLongPress: () {
                                    Clipboard.setData(new ClipboardData(text: widget.courseId));
                                    Vibration.vibrate(duration: 40);
                                    Notify.show(
                                      context: context,
                                      text: 'El código ha sido copiado.',
                                      actionText: 'Ok',
                                      backgroundColor: Theme.of(context).accentColor,
                                      textColor: Colors.white,
                                      actionColor: Colors.white,
                                      onPressed: (){
                                        
                                      }
                                    ); 
                                  },
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(bottom: 65),
                                        child: QrImage(
                                          data: widget.courseId,
                                          size: 200.0,
                                          version: 2,
                                          foregroundColor: Theme.of(context).accentColor,
                                          errorCorrectionLevel: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          
        ],
      ),
    );
    else return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'El curso ha sido eliminado.',
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}