import 'package:classroom/widget_passer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:classroom/nav.dart';
import 'package:classroom/interact_route.dart';
import 'package:classroom/database_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notify.dart';

class Lesson extends StatefulWidget{
  final String name, description, lessonId, date, courseId, fileType, filePath;
  String authorId;
  int lessonsLength;
  final bool owner, fileExists;
  

  Lesson({
    @required this.lessonId,
    @required this.courseId,
    @required this.authorId,
    @required this.name,
    @required this.fileExists,
    this.filePath: '',
    this.fileType: 'pdf',
    this.description: '',
    this.date: '',
    this.lessonsLength: 0,
    this.owner: false,
  });

  _LessonState createState() => _LessonState();
}

class _LessonState extends State<Lesson> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  AnimationController _boxResizeOpacityController, _lessonDeleteController;
  Animation<double> _opacityFloat;
  String _date, _description;
  String _lessonsLength, _name;
  Animation<Color> _deleteBackgroundColorFloat, _deleteTextColorFloat;
  bool _disabled;
  WidgetPasser _addBarModePasser;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    String day = widget.date;

    _lessonsLength = '${widget.lessonsLength}';

    _date = '${widget.date}';
    _name = '${widget.name}';
    _disabled = false;

    _lessonDeleteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300)
    );

    _description = widget.description;

    _addBarModePasser = WidgetPasser();

    _boxResizeOpacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _opacityFloat = Tween<double>(
      begin: 0, 
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _boxResizeOpacityController,
        curve: Curves.easeInOut,
      ),
    );

    _boxResizeOpacityController.forward();

    Firestore.instance.collection("lessons").document(widget.lessonId).snapshots().listen((snapshot){
      if(!snapshot.exists) {
        if(this.mounted) setState(() {
          _deleteLesson();
          print(Nav.sectionId);
          if(Nav.sectionId == 'interact') Navigator.of(context).pop();
        });         
        DatabaseManager.deleteDocumentInCollection("questionsPerLesson",widget.lessonId);
      }else{
        var value = snapshot.data;
        if(this.mounted){
          setState(() {
            _lessonsLength = value['lessonsLength'].toString();
            _description = value['description'];
            _name = value['name'];
            _date = value['date'];
          });
        } 
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _boxResizeOpacityController.dispose();
    super.dispose();
  }

  void _deleteLesson(){
    _lessonDeleteController.forward();
    if(this.mounted) setState(() {
      _disabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _deleteBackgroundColorFloat = ColorTween(
      begin: Theme.of(context).cardColor,
      end: Colors.grey[200],
    ).animate(
      CurvedAnimation(
        parent: _lessonDeleteController,
        curve: Curves.easeIn,
      )
    );

    _deleteTextColorFloat = ColorTween(
      begin: Theme.of(context).accentColor,
      end: Colors.grey,
    ).animate(
      CurvedAnimation(
        parent: _lessonDeleteController,
        curve: Curves.easeIn,
      )
    );

    return FadeTransition(
      opacity: _opacityFloat,
      child: AnimatedBuilder(
        animation: _deleteBackgroundColorFloat,
        builder: (context, child) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            padding: EdgeInsets.fromLTRB(9, 0, 0, 0),
            decoration: BoxDecoration(
              color: _deleteBackgroundColorFloat.value,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 40, 0),
                  padding: EdgeInsets.only(right: 9),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        width: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 9, bottom: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              _name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _deleteTextColorFloat.value,
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 3),
                                  child: Icon(
                                    FontAwesomeIcons.solidCommentAlt,
                                    size: 12,
                                    color: _deleteTextColorFloat.value,
                                  ),
                                ),
                                Text(
                                  _lessonsLength,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _deleteTextColorFloat.value,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _description,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: _deleteTextColorFloat.value,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 3, bottom: 9),
                                  child: Text(
                                    _date,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: _deleteTextColorFloat.value
                                    ),
                                  ),
                                ),
                              ]
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        child: Tooltip(
                          message: 'Acceder',
                          child: GestureDetector(
                            onTap: (){
                              if(!_disabled){
                                Vibration.vibrate(duration: 20);
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (BuildContext context) {
                                    return Nav(
                                      addBarModePasser: _addBarModePasser,
                                      elevation: 0,
                                      color: Colors.transparent,
                                      actionsColor: Theme.of(context).accentColor,
                                      titleColor: Theme.of(context).accentColor,
                                      addBarActive: true,
                                      drawerActive: false,
                                      notificationsActive: false,
                                      section: 'interact',
                                      title: _name,
                                      owner: widget.owner,
                                      courseId: widget.courseId,
                                      lessonId: widget.lessonId,
                                      body: InteractRoute(
                                        addBarModePasser: _addBarModePasser,
                                        authorId: widget.authorId,
                                        lessonId: widget.lessonId,
                                        courseId: widget.courseId,
                                        fileExists: widget.fileExists,
                                        filePath: widget.filePath,
                                        owner: widget.owner,
                                        isVideo: (widget.fileType == "url"),
                                      ),
                                    ); 
                                  })
                                );
                              }else{
                                Notify.show(
                                  context: context,
                                  text: 'La lección $_name ya no se encuentra disponible.',
                                  actionText: 'Ok',
                                  backgroundColor: Theme.of(context).accentColor,
                                  textColor: Colors.white,
                                  actionColor: Colors.white,
                                  onPressed: (){
                                    
                                  }
                                ); 
                              }
                            },
                            child: Container(
                              width: 40,
                              decoration: BoxDecoration(
                                color: _deleteTextColorFloat.value,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(3),
                                  bottomRight: Radius.circular(3),
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.only(right: 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.externalLinkSquareAlt,
                                      color: Colors.white,
                                      size: 17,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
              ],
            ),
          );
        }
      ),
    );
  }
} 