import 'package:flutter/material.dart';
import 'package:classroom/stateful_textfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/widget_passer.dart';
import 'package:classroom/question.dart';
import 'package:classroom/interact_route.dart';
import 'dart:convert';
import 'package:classroom/database_manager.dart';
import 'package:classroom/auth.dart';

enum ChatBarMode {
  QUESTION,
  ANSWER,
  QUESTION_WITH_POSITION,
}

class ChatBar extends StatefulWidget{
  static AnimationController chatBarOffsetController;
  static WidgetPasser questionPasser = WidgetPasser(), answerPasser = WidgetPasser(), labelPasser = WidgetPasser();
  static FocusNode chatBarFocusNode = FocusNode();
  static ChatBarMode mode;
  static String createdById, createdByName, questionText;

  final bool owner;
  final String lessonId, questionToAnswer;
  
  const ChatBar({
    @required this.lessonId,
    this.owner: false,
    this.questionToAnswer: '',
  });

  _ChatBarState createState() => _ChatBarState();
}

class _ChatBarState extends State<ChatBar> with SingleTickerProviderStateMixin{
  TextEditingController _chatBarTextfieldController;
  String _chatBarLabel;
  Animation<Offset> _offsetFloat;

  @override
  void initState() {
    super.initState();
    ChatBar.mode = ChatBarMode.QUESTION;

    ChatBar.chatBarOffsetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetFloat = Tween<Offset>(
      end: Offset(0, 1), 
      begin: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: ChatBar.chatBarOffsetController,
        curve: Curves.easeInOut,
      ),
    );

    _chatBarLabel = 'Escribe una pregunta';

    _chatBarTextfieldController = TextEditingController();

    ChatBar.labelPasser.receiver.listen((label){
      if(label != null && this.mounted){
        setState(() {
          _chatBarLabel = label;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    ChatBar.labelPasser.sender.add(null);

    ChatBar.mode = ChatBarMode.QUESTION;
  }

  void _onSubmittedFunction(String val){
    if(val.trim() != ''){
      //print(val);
      var nowDate = DateTime.now();
      int day = nowDate.day;
      int month = nowDate.month;
      int year = nowDate.year;
      int hours = nowDate.hour;
      int minutes = nowDate.minute;
      String authorId = Auth.uid;
      String author = Auth.getName();
      if(ChatBar.mode == ChatBarMode.QUESTION){
        print("atach: ${widget.questionToAnswer}");
        DatabaseManager.addQuestions(author, authorId, widget.lessonId, val, day, month, year, hours, minutes).then((id){
          // Map text = {
          //   'text': val,
          //   'author': author,
          //   'authorId': authorId,
          //   'owner': widget.owner,
          //   'day': day,
          //   'month': month,
          //   'year': year,
          //   'hours': hours,
          //   'minutes': minutes,
          //   'questionId': id,
          // };
          // String textQuestion = json.encode(text);
          // ChatBar.questionPasser.sendWidget.add(textQuestion);          
        });
      }else if(ChatBar.mode == ChatBarMode.ANSWER){
        String questionId = Question.globalQuestionId;
        DatabaseManager.addAnswers(questionId, author, authorId, widget.lessonId, val, day, month, year, hours, minutes, ChatBar.createdById, ChatBar.createdByName, ChatBar.questionText).then((id){
          Map text = {
            'answerId': id,
            'text': val,
            'author': author,
            'questionId': questionId,
            'authorId': authorId,
            'owner': widget.owner,
            'day': day,
            'month': month,
            'year': year,
            'hours': hours,
            'minutes': minutes,
          };
          String textAnswer = json.encode(text);
          Question.answerPasser.sender.add(textAnswer);
          if(widget.owner) Question.answeredPasser.sender.add('1');
          InteractRoute.questionPositionController.reverse();
          ChatBar.labelPasser.sender.add('Escriba una pregunta');
          ChatBar.mode = ChatBarMode.QUESTION;          
        });        
      }else if(ChatBar.mode == ChatBarMode.QUESTION_WITH_POSITION){
        print("atach: ${widget.questionToAnswer}");
        DatabaseManager.addQuestions(author, authorId, widget.lessonId, val, day, month, year, hours, minutes, attachPosition: widget.questionToAnswer).then((id){ 
          InteractRoute.questionPositionController.reverse();      
        });
      }
        _chatBarTextfieldController.text = '';
    }
    ChatBar.chatBarFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offsetFloat,
        child: Container(
          color: Theme.of(context).accentColor,
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: StatefulTextfield(
                      focusNode: ChatBar.chatBarFocusNode,
                      controller: _chatBarTextfieldController,
                      color: Theme.of(context).accentColor,
                      fillColor: Colors.white,
                      suffix: '',
                      hint: _chatBarLabel,
                      borderRadius: 30,
                      padding: EdgeInsets.fromLTRB(15, 15, 45, 15),
                      onSubmitted: (val){
                        _onSubmittedFunction(val);
                      },
                    ),
                  ),
                  // Container(
                  //   width: 48,
                  //   height: 48,
                  //   margin: EdgeInsets.only(left: 12),
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     color: Colors.white,
                  //   ),
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: <Widget>[
                  //       IconButton(
                  //         icon: Icon(
                  //           FontAwesomeIcons.paperclip,
                  //           size: 18,
                  //         ),
                  //         onPressed: (){},
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.check,
                        size: 18,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: (){
                        _onSubmittedFunction(_chatBarTextfieldController.text);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}