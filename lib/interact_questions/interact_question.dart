import 'package:classroom/database_manager.dart';
import 'package:classroom/interact_questions/interact_answer.dart';
import 'package:classroom/interact_questions/page_indicator.dart';
import 'package:flutter/material.dart';

class InteractQuestion extends StatefulWidget {
  final String question, questionnarieId;
  final int timeToAnswer, index, totalOfQuestions, totalOfAnswers, correctAnswer;
  final Function onTimeout;

  const InteractQuestion({
    @required this.question,
    @required this.index,
    @required this.totalOfQuestions,
    @required this.totalOfAnswers,
    @required this.correctAnswer,
    @required this.questionnarieId,
    this.timeToAnswer: 0,
    this.onTimeout,
  });

  @override
  _InteractQuestionState createState() => _InteractQuestionState();
}

class _InteractQuestionState extends State<InteractQuestion> with TickerProviderStateMixin {
  AnimationController _timerBarWidthController, _falseAnswersOpacityController;
  Animation _timerBarWidth, _falseAnswersOpacity;
  bool _timeout, _answerSelected;
  List<InteractQuestion> _interactQuestionsList;
  
  @override
  void initState() {
    _interactQuestionsList = new List<InteractQuestion>();
    // DatabaseManager.requestGet('questionnaires/${widget.questionnarieId}', '', 'getQuestionnairesQuestions').then((result){
    //   result.forEach((obj) {
    //     DatabaseManager.requestGet('questionnaires/${widget.questionnarieId}/questions/${obj['id']}/answers', '', 'getQuestionnairesQuestionAnswers').then((result){
    //       _interactQuestionsList.add(InteractQuestion(
              
    //           question: obj['name'],
    //           timeToAnswer: int.parse(obj['time']),
    //           index: 1,
    //           totalOfQuestions: int.parse(obj['questions']),
    //           onTimeout: _handleTimeout,
    //           totalOfAnswers: 4,
    //           correctAnswer: 2,
    //         )
    //       );
    //     });
    //   });        
    // });
    
    super.initState();

    _timeout = false;
    _answerSelected = false;

    _timerBarWidthController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timeToAnswer),
    );

    _timerBarWidth = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _timerBarWidthController,
        curve: Curves.linear,
      )
    );

    _falseAnswersOpacityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _falseAnswersOpacity = Tween(
      begin: 1.0,
      end: 0.4,
    ).animate(
      CurvedAnimation(
        parent: _falseAnswersOpacityController,
        curve: Curves.linear,
      )
    );

    _timerBarWidthController.forward().then((_){
      _falseAnswersOpacityController.forward();
      widget.onTimeout();
      setState(() {
        _timeout = true;
      });
    });
  }

  @override
  void dispose() {
    _timerBarWidthController.dispose();
    _falseAnswersOpacityController.dispose();
    super.dispose();
  }

  void _handleAnswerTap(int answerCode) {
    print('presiono: $answerCode');
    print(answerCode);
    setState(() {
      _answerSelected = true;
    });
  }

  List<Widget> _renderAnswers() {
    bool unclickable = _timeout || _answerSelected;
    List<Widget> answers = List<Widget>();
    for (int i = 0; i < widget.totalOfAnswers; i++) {
      if (widget.correctAnswer == i) {
        answers.add(
          InteractAnswer(
            code: i,
            unclickable: unclickable,
            onTap: _handleAnswerTap,
          )
        );
      } else {
        answers.add(
          FadeTransition(
            opacity: _falseAnswersOpacity,
            child: InteractAnswer(
              code: i,
              unclickable: unclickable,
              onTap: _handleAnswerTap,
            ),
          ),
        );
      }
    }
    return answers;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.question,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _renderAnswers(),
                  ),
                  widget.timeToAnswer > 0 ? Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 20),
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Stack(
                            children: <Widget>[
                              AnimatedBuilder(
                                animation: _timerBarWidth,
                                builder: (context, child) => FractionallySizedBox(
                                  heightFactor: 1,
                                  widthFactor: _timerBarWidth.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ) : Container(),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Text(
                      'Una vez seleccionada una opción debes esperar a que acabe el tiempo o que el catedrático cierre la pregunta.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(
                    'Pregunta ${widget.index} de ${widget.totalOfQuestions}',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                  PageIndicator(
                    index: widget.index,
                    totalOfPages: widget.totalOfQuestions,
                    context: context,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}