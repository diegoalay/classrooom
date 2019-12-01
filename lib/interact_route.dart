import 'package:classroom/youtube_video.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:classroom/question.dart';
import 'package:classroom/chatbar.dart';
import 'package:classroom/presentation.dart';
import 'package:classroom/widget_passer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'stateful_button.dart';
import 'package:classroom/auth.dart';
import 'dart:convert';
import 'package:classroom/database_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InteractRoute extends StatefulWidget{
  
  final String lessonId, authorId, courseId;
  static AnimationController questionPositionController, questionOpacityController;
  static List<Question> questions;
  static StreamController<String> questionController;
  static WidgetPasser updateQuestions = WidgetPasser(); 
  static WidgetPasser setQuestionsSort = WidgetPasser();
  static int index = 0;
  final bool owner;
  final WidgetPasser addBarModePasser;
  static String questionId;
  
  InteractRoute({
    @required this.lessonId,
    @required this.authorId,
    @required this.courseId,
    this.owner: false,
    this.addBarModePasser
  });

  _InteractRouteState createState() => _InteractRouteState();
}

class _InteractRouteState extends State<InteractRoute> with TickerProviderStateMixin{
  Stream<String> _questionStream;
  Animation<Offset> _offsetFloat;
  Animation<double> _opacityFloat;
  String _questionToAnswer, _filePath;
  Widget _presentation, _uploadPresentation;
  WidgetPasser _questionPasser, _pathPasser, _setQuestionsSort;
  ScrollController _scrollController;
  bool _isPresentation, _presentationLoaded, _lessonDisabled, _courseDisabled, _fileExists, _sortByPage, _fileStatus;
  int _presentationActualPage;
  bool _isVideo;
  int _fileTime;
  Future<String> getFilePath() async {
    String filePath = "";
    try {
      filePath = await FilePicker.getFilePath(type: FileType.ANY);
      if (filePath == '') {
        return null;
      }
      print("File path: " + filePath);

    }catch (e) {
      print("Error picking the file: " + e.toString());
    }
    return filePath;
  }


  @override
  void initState() {
    super.initState();
    _filePath = '';
    _fileExists = false;
    _isVideo = false;
    _isPresentation = false;
    _presentationLoaded = false;
    _lessonDisabled = false;
    _courseDisabled = false;
    _sortByPage = false;
    _fileStatus = false;
    _questionToAnswer = '';
    _fileTime = 0;

    _presentationActualPage = 0;

    _scrollController = ScrollController();

    _questionPasser = ChatBar.questionPasser;
    _pathPasser = WidgetPasser();

    _setQuestionsSort = InteractRoute.setQuestionsSort;

    _setQuestionsSort.receiver.listen((text) {
      if (text != null) {
        print(text);
        if(this.mounted){
          setState(() {
            _sortByPage = !_sortByPage;
          });
        }
      }
    });

    InteractRoute.questionOpacityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 0),
    );

    _opacityFloat = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: InteractRoute.questionOpacityController,
        curve: Curves.easeInOut,
      ),
    );

    Firestore.instance.collection("lessons").document(widget.lessonId).snapshots().listen((snapshot){
      if(snapshot.exists) {
        var value = snapshot.data;
        if(this.mounted){
          if(value['fileType'] == 'url') setState(() { _isVideo = true; });
          else setState(() { _isVideo = false; });
          if(value['fileType'] == 'pdf') setState(() { _isPresentation = true; });
          else setState(() { _isPresentation = false; });          
          if(_fileTime != value['fileTime']  || value['fileStatus'] != _fileStatus) showFile(value['fileType'],value['fileStatus']);
          if(value['fileExists']) {
            setState(() {
              _fileExists = value['fileExists'];
              _filePath = value['filePath'];
              _fileTime = value['fileTime'];
              _fileStatus = value['fileStatus'];
            });
          }
        } 
      }
    });
    
    if(widget.owner){
      _uploadPresentation = Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 24),
            child: StatefulButton(
              text: 'CARGAR\nPRESENTACIÓN',
              fontSize: 13,
              color: Colors.grey,
              borderColor: Colors.transparent,
              icon: FontAwesomeIcons.arrowAltCircleUp,
              onTap: (){
                getFilePath().then((filePath){
                  setState((){
                    if(filePath.isNotEmpty){
                      DatabaseManager.uploadFiles("pdf", widget.lessonId, filePath).then((path){
                        setState(() {
                          print('PATH: $path');
                          _presentation = Presentation(
                            file: path,
                            onPageChange: this._handlePresentationPageChange,
                          );
                        });
                      });
                    }
                  });
                });
              },
            ),
          ),
          Container(
            child: StatefulButton(
              text: 'CARGAR VIDEO',
              fontSize: 13,
              color: Colors.grey,
              borderColor: Colors.transparent,
              icon: FontAwesomeIcons.youtube,
              onTap: (){
                print('TAP TAP');
                if (widget.addBarModePasser != null) {
                  print('Se envia');
                  widget.addBarModePasser.sender.add('4');
                }               
              },
            ),
          ),
        ],
      );
    }else{
      _uploadPresentation = Text(
        'No hay archivo cargado.',
        style: TextStyle(
          color: Colors.grey,
        ),
      ); 
    }

    InteractRoute.questionController = StreamController<String>();
    _questionStream = InteractRoute.questionController.stream;
    InteractRoute.questions = List<Question>();

    InteractRoute.questionPositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetFloat = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: InteractRoute.questionPositionController,
        curve: Curves.easeInOut,
      ),
    );

    Firestore.instance.collection("lessons").document(widget.lessonId).collection("questions").orderBy("votesLength", descending: true).snapshots().listen((snapshot) async{
      InteractRoute.index = 0;
      List<DocumentChange> docs = snapshot.documentChanges;
      Question question;
      
      for(var doc in docs){
        if (doc.type == DocumentChangeType.added){
          question = new Question(
            lessonId: widget.lessonId,
            questionId: doc.document.documentID,
            courseId: doc.document.data['courseId'],
            text: doc.document.data['text'],
            author: doc.document.data['author'],
            authorId: doc.document.data['authorId'],
            day: doc.document.data['day'],
            month: doc.document.data['month'],
            year: doc.document.data['year'],
            hours: doc.document.data['hours'],
            minutes: doc.document.data['minutes'],                
            votesLength: doc.document.data['votesLength'],
            attachment: '${doc.document.data['attachment']}',
            isVideo: _isVideo,
            index: InteractRoute.index++,
          );
          if(question.authorId == Auth.uid) question.mine = true;
          List<String> lista = List<String>.from(doc.document['votes']); 
          if(lista.contains(Auth.uid)) question.voted = true;  
          question.courseAuthorId = widget.authorId;
          if(this.mounted){
            setState(() {
              InteractRoute.questions.add(question);
            });
          }
        }else if (doc.type == DocumentChangeType.modified){
          print("document change");
        }
      }      
    });

    _questionStream.listen((text) {
      if(text != null){
        setState(() {
          _questionToAnswer = text;
        });
      }
    });

    _questionPasser.receiver.listen((newQuestion){
      if(newQuestion != null){
        Map jsonQuestion = json.decode(newQuestion);
        if(this.mounted){
          setState(() {
            InteractRoute.questions.add(
              Question(
                lessonId: widget.lessonId,
                authorId: jsonQuestion['authorId'],
                courseId: jsonQuestion['courseId'],
                questionId: jsonQuestion['questionId'],
                courseAuthorId: jsonQuestion['courseAuthorId'],
                text: jsonQuestion['text'],
                author: jsonQuestion['author'],
                day: jsonQuestion['day'],
                month: jsonQuestion['month'],
                year: jsonQuestion['year'],
                hours: jsonQuestion['hours'],
                minutes: jsonQuestion['minutes'],
                owner: jsonQuestion['owner'],
                mine: jsonQuestion['mine'],
                index: InteractRoute.index++,
                isVideo: _isVideo,
              )
            );
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(
                milliseconds: 500,
              ),  
              curve: Curves.ease,
            );
          });
        }
      }
    });

    _pathPasser.receiver.listen((path) {
      if (path != null) {
        setState(() {
          _presentation = Presentation(
            file: path,
            onPageChange: this._handlePresentationPageChange,
          );
        });
      }
    });
  }

  void _handlePresentationPageChange(int page) {
    print('PAGE: $page');
    setState(() {
      _presentationActualPage = page;
    });
  }

  @override
  void dispose() {
    _questionPasser.sender.add(null);
    _pathPasser.sender.add(null);
    _setQuestionsSort.sender.add(null);
    widget.addBarModePasser.sender.add(null);
    InteractRoute.updateQuestions.sender.add(null);
    InteractRoute.index = 0;
    super.dispose();
  }

  Widget _getPresentation(BuildContext context){
    if(_isVideo && _presentationLoaded){
      return YouTubeVideo(
        videoId: _filePath,
      );
    }if(!_isPresentation && _presentationLoaded || !_fileStatus){
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _uploadPresentation,
              ],
            ),
          ],
        ),
      );
    }else if(!_fileExists){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SpinKitRing(
              color: Theme.of(context).accentColor,
              size: 30.0,
              lineWidth: 4,
            ),
          ],
        ),
      );
    }else{
      return _presentation;
    }
  }

  Widget _getListView(double width, double height, BuildContext context){
    final List<Question> _actualQuestions = List.from(InteractRoute.questions);
    return ListView.builder(
      reverse: false,
      controller: _scrollController,
      // physics: ScrollPhysics(
      //   parent: BouncingScrollPhysics(),
      // ),
      padding: EdgeInsets.only(top: 0, bottom: 12),
      itemCount: _actualQuestions.length + 1,
      itemBuilder: (context, index){
        if(index == 0){
          if(_isVideo){
            return Container(
                key: Key('video'),
                child: _getPresentation(context),
              );
          }else{
            return Container(
              key: Key('presentation'),
              padding: EdgeInsets.symmetric(horizontal: 12),
              width: width,
              height: height + 68,
              child: _getPresentation(context),
            );
          }
        }else{
          Question _question = _actualQuestions.elementAt(index - 1);
          
          if (_sortByPage) {
            return _question.attachment == '${this._presentationActualPage + 1}' ? _question : Container();
          } else {
            return _question;
          }
        }
      },
    );
  }

  String _getDisabledText(){
    if(_lessonDisabled) return 'La lección ha sido eliminada.';
    else return 'El curso ha sido eliminado.';
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = (_width/4)*3;
    if(!_lessonDisabled && !_courseDisabled) return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(bottom: 68),
                  child: _getListView(_width, _height, context),
                ),
              )
            ],
          ),
          Positioned(
            bottom: 68,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _opacityFloat,
              child: SlideTransition(
                position: _offsetFloat,
                child: Container(
                  color: Theme.of(context).accentColor,
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: FractionallySizedBox(
                    widthFactor: 1,
                      child: Text(
                      _questionToAnswer,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ChatBar(
            courseId: widget.courseId,
            lessonId: widget.lessonId,
            owner: widget.owner,
            questionToAnswer: _questionToAnswer,
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
                _getDisabledText(),
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

  void showFile(fileType,fileStatus){
    print('entra');
    print(fileStatus);
    if(fileStatus){ 
      if(fileType == "pdf") {
        DatabaseManager.getFiles("pdf", widget.lessonId).then((path){
          print("ARCHIVO:  $path");
          if(path != 'EXCEPTION'){
            if(this.mounted) setState(() {
              _presentation = Presentation(
                file: path,
                onPageChange: this._handlePresentationPageChange,
              );
              _presentationLoaded = true;
            });
          }else{
            if(this.mounted) setState(() {
              _presentation = Text(
                'EXCEPCION :c',
              );
              _presentationLoaded = true;
            });
          }
        });
      }else{
        setState(() {
          _presentationLoaded = true;
        });
      }
    } else {
      setState(() {
         _presentationLoaded = false;
        _uploadPresentation = Text(
          'No hay archivo disponible.',
          style: TextStyle(
            color: Colors.grey,
          ),
        );   
      });      
    }
  }
}