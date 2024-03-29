import 'package:classroom/database_manager.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/nav.dart';
import 'package:classroom/lessons_route.dart';
import 'package:vibration/vibration.dart';
import 'package:classroom/widget_passer.dart';
import 'notify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Course extends StatefulWidget{
  static WidgetPasser deactivateListener = WidgetPasser();

  final String name, author, courseId, authorId;
  final Color color;
  final int lessonsLength, usersLength;
  final bool owner;

  const Course({
    @required this.name,
    @required this.author,
    @required this.authorId, 
    @required this.lessonsLength,
    @required this.usersLength,
    @required this.courseId,
    this.color,
    this.owner: false,
  });

  @override
  _CourseState createState() => _CourseState();
}

class _CourseState extends State<Course> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  Color _color;
  AnimationController _boxResizeOpacityController, _courseDeleteController;
  Animation<double> _sizeFloat, _opacityFloat;
  Animation<Color> _deleteBackgroundColorFloat, _deleteTextColorFloat;
  bool _disabled;
  String _lessons, _usersLength, _name;
  WidgetPasser _deactivateListener;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if(widget.color == null){
      _color = Color.fromARGB(255, 0, 11, 43);
    }else{
      _color = widget.color;
    }

    _deactivateListener = WidgetPasser();
    _deactivateListener.receiver.listen((msg){
      if(msg != null){
        _disabled = true;
        _courseDeleteController.forward();
      }
    });

    _usersLength = '${widget.usersLength}';
    _lessons = '${widget.lessonsLength}';
    _name = '${widget.name}';

    _disabled = false;

    _courseDeleteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300)
    );

    _boxResizeOpacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _sizeFloat = Tween<double>(
      begin: 0.75, 
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _boxResizeOpacityController,
        curve: Curves.easeInOut,
      ),
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

    Firestore.instance.collection("courses").document(widget.courseId).snapshots().listen((snapshot){
      var value = snapshot.data;
      if(value == null) {
        if(this.mounted) setState(() {
          _deleteCourse();
          if(Nav.sectionId == 'lessons') {
            Nav.sectionId = 'courses';
            Navigator.of(context).pop();
          } else if(Nav.sectionId == 'interact') {
            Nav.sectionId = 'courses';
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
        });         
        DatabaseManager.deleteDocumentInCollection("lessonsPerCourse",widget.courseId);       
      }else{
        if(this.mounted){
          setState(() {
            _name = value['name'];
            _lessons = value['lessonsLength'].toString();
            _usersLength = value['usersLength'].toString();
          });
        } 
      }
    });

    _boxResizeOpacityController.forward();
  }

  @override
  void dispose() {
    _boxResizeOpacityController.dispose();
    super.dispose();
  }

  //TODO: Llamar para eliminar el curso.
  void _deleteCourse(){
    _courseDeleteController.forward();
    if(this.mounted) setState(() {
      _disabled = true;
    });
  }

  Widget _getCourseAuthor(Color textColor){
    if(widget.owner){
      return Container();
    }else{
      return Text(
        widget.author,
        style: TextStyle(
          color: textColor,
        ),
      );
    }
  }

  Widget _getProprietaryLabel(){
    if(false){
      return Text(
        'P',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }else{
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.owner){
      _deleteBackgroundColorFloat = ColorTween(
        begin: _color,
        end: Colors.grey[200],
      ).animate(
        CurvedAnimation(
          parent: _courseDeleteController,
          curve: Curves.easeIn,
        )
      );
    }else{
      _deleteBackgroundColorFloat = ColorTween(
        begin: Theme.of(context).primaryColorLight,
        end: Colors.grey[200],
      ).animate(
        CurvedAnimation(
          parent: _courseDeleteController,
          curve: Curves.easeIn,
        )
      );
    }

    _deleteTextColorFloat = ColorTween(
      begin: widget.owner ? Theme.of(context).primaryColorLight : Theme.of(context).accentColor,
      end: Colors.grey,
    ).animate(
      CurvedAnimation(
        parent: _courseDeleteController,
        curve: Curves.easeIn,
      )
    );

    return InkWell(
      onTap: (){
        if(!_disabled){
          Course.deactivateListener = _deactivateListener;
          Vibration.vibrate(duration: 20);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return Nav(
                owner: widget.owner,
                preferredSize: 65,
                section: 'lessons',
                title: 'LECCIONES',
                subtitle: _name,
                courseId: widget.courseId,
                courseName: widget.name,
                body: LessonsRoute(
                  name: _name,
                  courseId: widget.courseId,
                  author: widget.author,
                  usersLength: widget.usersLength,
                  owner: widget.owner,
                  authorId: widget.authorId
                ),
                id: widget.courseId,
              );
            }),
          );
        }else{
          Notify.show(
            context: context,
            text: 'El curso $_name ya no se encuentra disponible.',
            actionText: 'Ok',
            backgroundColor: Theme.of(context).accentColor,
            textColor: Colors.white,
            actionColor: Colors.white,
            onPressed: (){
              
            }
          ); 
        }
      },
      splashColor: Colors.redAccent[100],
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: FadeTransition(
          opacity: _opacityFloat,
          child: ScaleTransition(
            scale: _sizeFloat,
            child: AnimatedBuilder(
              animation: _deleteBackgroundColorFloat,
              builder: (context, child) {
                return Container(
                  margin: EdgeInsets.all(6),
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _deleteBackgroundColorFloat.value,
                      width: 1,
                    ),
                    color: _deleteBackgroundColorFloat.value,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: Text(
                              _name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _deleteTextColorFloat.value,
                              ),
                            ),
                          ),
                          _getCourseAuthor(_deleteTextColorFloat.value),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            alignment: Alignment(0, 0),
                            height: 20,
                            decoration: BoxDecoration(
                              color: widget.owner ? Colors.transparent : _deleteTextColorFloat.value,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _lessons + ' lecciones',
                              style: TextStyle(
                                color: widget.owner ? Theme.of(context).primaryColorLight : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                          decoration: BoxDecoration(
                            /* border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).accentColor,
                                width: 6,
                              ),
                            ), */
                            //borderRadius: BorderRadius.circular(30),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _getProprietaryLabel(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.male,
                                    size: 16,
                                    color: _deleteTextColorFloat.value,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Text(
                                      _usersLength,
                                      style: TextStyle(
                                        color: _deleteTextColorFloat.value,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }
}