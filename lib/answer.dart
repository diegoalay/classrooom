import 'package:flutter/material.dart';
import 'package:classroom/vote.dart';
import 'package:classroom/database_manager.dart';
import 'package:classroom/auth.dart';

class Answer extends StatefulWidget{
  final String author, text, questionId, answerId, authorId, lessonId, questionText;
  bool voted, mine, owner;
  final int votesLength;

  Answer({
    @required this.questionId,
    @required this.answerId,
    @required this.author,
    @required this.authorId,
    @required this.lessonId,
    @required this.text,
    @required this.questionText,
    this.voted: false,
    this.mine: false,
    this.owner: false,
    this.votesLength: 1,
  });

  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<Answer>{

  @override
  void initState() {
    super.initState();
  }

  Color _getTextColor(BuildContext context){
    if(widget.owner) return Colors.white;
    else return Theme.of(context).accentColor;
  }

  Color _getColor(BuildContext context){
    if(widget.owner) return Theme.of(context).accentColor;
    else return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            child: Vote(
              voted: widget.voted,
              votesLength: widget.votesLength,
              showVotes: false,
              small: true,
              onVote: (){
                DatabaseManager.addVoteToAnswer(widget.lessonId, Auth.uid, widget.questionId, widget.answerId, "1");
              },
              onUnvote: (){
                DatabaseManager.removeVoteToAnswer(widget.lessonId, Auth.uid, widget.questionId, widget.answerId, "-1");
              },              
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width - 125,
              margin: EdgeInsets.fromLTRB(48, 6, 12, 6),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getColor(context),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 3),
                    child: Text(
                      widget.author,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(context),
                      )
                    ),
                  ),
                  Text(
                    widget.text,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: _getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}