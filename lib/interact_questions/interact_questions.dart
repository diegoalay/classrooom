import 'package:classroom/interact_questions/interact_question.dart';
import 'package:classroom/interact_questions/types/questionnaire.dart';
import 'package:classroom/stateful_button.dart';
import 'package:classroom/utils/questionnaire_status.dart';
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
  Questionnaire _questionnaire;

  void _setStatusBarColor() async {
  }

  @override
  void initState() {
    super.initState();


    _setStatusBarColor();
    _interactQuestionsList  = new List<InteractQuestion>();
    _isWaiting = false;
    Firestore.instance.collection("questionnaires").document(widget.questionnaireId).snapshots().listen((snapshot){
        var questionnaire = snapshot.data;
        setState(() {
          _questionnaireIndex = questionnaire['index'];
          _questionnaireStatus = questionnaire['status'];
        });
        if(this.mounted){
          print('change');
          print(questionnaire['status']);
          if(questionnaire['status'] == QUESTIONNAIRE_STATUS.IDLE.index || questionnaire['status'] == QUESTIONNAIRE_STATUS.WAITTING.index) {
            setState(() {
              _isWaiting = true;
            });
          } else if(questionnaire['status'] == QUESTIONNAIRE_STATUS.ASKING.index) {
            setState(() {
              _isWaiting = false;
            });
          }
        } 
    });
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
    DatabaseManager.updateQuestionnaire(widget.questionnaire['questionnaireId'], '${Auth.uid}-${Auth.getEmail()}-${Auth.getName()}', 'users');
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
    Firestore.instance.document('questionnaires/${widget.questionnaire['questionnaireId']}').snapshots().listen((doc){
      List<QuestionnaireQuestion> questionnaireQuestionList = new List<QuestionnaireQuestion>();
        if(doc.exists){
          List<QuestionnaireQuestionAnswer> questionnaireAnswersList = new List<QuestionnaireQuestionAnswer>(); 
          for(var question in doc.data['questions']){
            print(question['answers']);
            for(var answer in question['answers']) {
              questionnaireAnswersList.add(
                QuestionnaireQuestionAnswer(
                  answer['id'],
                  answer['answer'],
                )
              );
            }
            questionnaireQuestionList.add(
              QuestionnaireQuestion(
                doc.documentID,
                question['question'],
                question['time'],
                question['index'] + 1,
                question['correctAnswer'],
                questionnaireAnswersList,
              )
            );
          }
        }

        if (this.mounted) {
          this.setState(() {
            _questionnaire = new Questionnaire (
              widget.questionnaire['questionnaireId'],
              widget.questionnaire['courseId'],
              widget.questionnaire['name'],
              widget.questionnaire['questionsLength'],
              0,
              questionnaireQuestionList,
            );
          });
        }
    });
  }

  Widget renderQuestion() {
    QuestionnaireQuestion question = _questionnaire.questions[_questionnaire.questionIndex];
    print(question);
    return InteractQuestion(
      id: question.id,
      questionnarieId: _questionnaire.id,
      question: question.question,
      timeToAnswer: question.time,
      index: question.questionIndex,
      questionsLength: _questionnaire.questionsLength,
      onTimeout: _handleTimeout,
      totalOfAnswers: question.answers.length,
      correctAnswer: question.correctAnswer,
    );
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
                  _questionnaire != null ? _questionnaire.name : '',
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
               ) :  _status == STATUS.ACCEPTED ? renderQuestion() : Container(),
            ],
          ),
        ),
      ),
    );
  }
}