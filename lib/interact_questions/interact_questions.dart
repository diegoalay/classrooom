import 'package:classroom/interact_questions/interact_question.dart';
import 'package:classroom/stateful_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../database_manager.dart';
// import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';

class InteractQuestions extends StatefulWidget {
  final Function onReject;
  final String courseId;

  const InteractQuestions({
    this.onReject,
    this.courseId,
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
  void _setStatusBarColor() async {
  }

  @override
  void initState() {
    super.initState();

    _setStatusBarColor();
    _interactQuestionsList  = new List<InteractQuestion>();
    DatabaseManager.requestGet('questionnaires', {"courseId": widget.courseId}, 'getQuestionnaires').then((result){     
      print(result); 
      result.forEach((obj) {
        print(obj);
        var id = obj['id'];
        DatabaseManager.requestGet('questionnaires/$id/questions', '', 'getQuestionnaireQuestions').then((questions){
          int i = 1;
          questions.forEach((questionObj) {
            _interactQuestionsList.add(InteractQuestion(
                questionnarieId: questionObj['id'],
                question: questionObj['question'],
                timeToAnswer: questionObj['time'],
                index: i,
                totalOfQuestions: 2,
                onTimeout: _handleTimeout,
                totalOfAnswers: questionObj['answersCount'],
                correctAnswer: questionObj['correctAnswer'],
              )
            );
            i = i + 1;
          });
        });          
      });        
    });

    //TODO: Setear esto a true cuando todavía no se haya pasado a la siguiente pregunta
    _isWaiting = false;
    
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
              ) :  _status == STATUS.ACCEPTED ? _interactQuestionsList.first : Container(),
            ],
          ),
        ),
      ),
    );
  }
}