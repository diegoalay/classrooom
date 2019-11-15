import 'package:classroom/interact_questions/interact_question.dart';
import 'package:classroom/interact_questions/types/questionnaire.dart';
import 'package:classroom/stateful_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:classroom/database_manager.dart';
import 'package:classroom/auth.dart';
// import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';

class InteractQuestions extends StatefulWidget {
  final Function onReject;
  final Map<dynamic,dynamic> questionnaire;
  final String questionnaireId;

  const InteractQuestions({
    this.onReject,
    this.questionnaire,
    this.questionnaireId, 
  });

  @override
  _InteractQuestionsState createState() => _InteractQuestionsState();
}

enum STATUS {
  REJECTED,
  ACCEPTED
}

class _InteractQuestionsState extends State<InteractQuestions> with TickerProviderStateMixin {
  AnimationController _widgetOpacityController;
  Animation<double> _widgetOpacity;
  STATUS _status;
  bool _isWaiting;
  List<InteractQuestion> _interactQuestionsList;
  int _questionnaireIndex;
  int _questionnaireStatus;

  void _setStatusBarColor() async {
  }

  @override
  void initState() {
    super.initState();


    _setStatusBarColor();
    _interactQuestionsList  = new List<InteractQuestion>();

    //HENRY
    Firestore.instance.collection("questionnair").document(widget.questionnaireId).snapshots().listen((snapshot){
      var value = snapshot.data;
      if(this.mounted){
        setState(() {
          _questionnaireIndex = value['index'];
          _questionnaireStatus = value['status'];
        });
      } 
    });

    //TODO: Setear esto a true cuando todavía no se haya pasado a la siguiente pregunta
    _isWaiting = false;
    handleGetQuestions();
    _widgetOpacityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _widgetOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _widgetOpacityController,
        curve: Curves.easeIn,
      )
    );

    _widgetOpacityController.forward();
  }


  void _handleAcceptTap() {
    // DatabaseManager.updateQuestionnaire(widget.questionnaire['questionnaireId'], Auth.uid, 'users');
    setState(() {
      _status = STATUS.ACCEPTED;
    });
  }

  void _handleRejectTap() {
    //TODO: Deberíamos de guardar que el estudiante rechazó el cuestionario
    setState(() { 
      _status = STATUS.REJECTED;
    });
    widget.onReject();
  }

  void _handleTimeout() {
  }

  void handleGetQuestions(){
    // HENRY: ESTRUCTURA
    print(widget.questionnaire['questionnaireId']);
    Firestore.instance.collection('questionnaires/${widget.questionnaire['questionnaireId']}/questions').snapshots().listen((snapshot){
      List<DocumentChange> docs = snapshot.documentChanges;
      if(docs != null){
        List<QuestionnaireQuestion> questionnaireQuestionList = new List<QuestionnaireQuestion>();
        for(var doc in docs){
          print(doc.document.data);
          if(doc.type == DocumentChangeType.added || doc.type == DocumentChangeType.modified){
            List<QuestionnaireQuestionAnswer> questionnaireAnswersList = new List<QuestionnaireQuestionAnswer>(); 
            print(doc.document.data['answers']);
            for(var answer in doc.document.data['answers']) {
              questionnaireAnswersList.add(
                QuestionnaireQuestionAnswer(
                  answer['id'],
                  answer['answer'],
                  answer['correct'],
                )
              );
            }
            questionnaireQuestionList.add(
              QuestionnaireQuestion(
                doc.document.documentID,
                doc.document['question'],
                doc.document['time'],
                questionnaireAnswersList,
              )
            );
          }
        }
        Questionnaire questionnaire = new Questionnaire (
            widget.questionnaire['questionnaireId'],
            widget.questionnaire['courseId'],
            widget.questionnaire['name'],
            widget.questionnaire['questionsLength'],
            questionnaireQuestionList,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _widgetOpacity,
      child: Container(
        color: Theme.of(context).accentColor,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _status == null ? Container(
                margin: EdgeInsets.only(bottom: 12),
                child: Text(
                  '¡Nuevo Cuestionario!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ) : Container(),
              _status == null ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(8),
                    child: StatefulButton(
                      text: 'Rechazar',
                      color: Colors.white,
                      borderColor: Colors.white,
                      onTap: _handleRejectTap,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    child: StatefulButton(
                      text: 'Aceptar',
                      color: Theme.of(context).accentColor,
                      fillColor: Colors.white,
                      borderColor: Colors.white,
                      onTap: _handleAcceptTap,
                    ),
                  ),
                ],
              ) : Container(),
              _isWaiting && _status == STATUS.ACCEPTED ?  SpinKitRing(
                size: 35,
                lineWidth: 5,
                color: Colors.white,
               ) :  _status == STATUS.ACCEPTED ? InteractQuestion(
                questionnarieId: widget.questionnaire['questionnaireId'],
                question: '¿Cuál es la definición correcta de thread?',
                timeToAnswer: 3,
                index: 2,
                questionsLength: widget.questionnaire['questionsLength'],
                onTimeout: _handleTimeout,
                totalOfAnswers: 4,
                correctAnswer: 2,
              ) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}