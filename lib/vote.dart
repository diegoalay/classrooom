import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';

class Vote extends StatefulWidget{
  final bool voted, showVotes, small;
  final int votesLength, index;
  final Function onVote, onUnvote;

  const Vote({
    this.voted : false,
    this.votesLength : 0,
    this.index : 0,
    this.onVote,
    this.onUnvote,
    this.showVotes: true,
    this.small: false,
  });

  _VoteState createState() => _VoteState();
}

class _VoteState extends State<Vote> with SingleTickerProviderStateMixin{
  Color _emptyColor, _solidColor;
  Widget _voteWidget;
  bool _voted;
  AnimationController _scaleController;
  Animation<double> _scaleFloat;
  int _votes;
  double _iconSize;

  @override
  void initState() {
    super.initState();

    _votes = widget.votesLength;

    if(widget.small) _iconSize = 16;
    else _iconSize = 20;

    _voteWidget = Container();
    _voted = widget.voted;

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleFloat = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _construcVoteWidget(bool solid, bool animate){
    setState(() {
      if(animate) _scaleController.reset();
      if(!solid){
        _voteWidget = ScaleTransition(
          scale: _scaleFloat,
          child: IconButton(
            tooltip: 'Votar',
            splashColor: Theme.of(context).cardColor,
            icon: Icon(
              FontAwesomeIcons.star,
              size: _iconSize,
              color: _emptyColor,
            ),
            onPressed: (){
              Vibration.vibrate(duration: 20);
              if(widget.onVote != null){
                widget.onVote();
              }
              _voted = true;
              if(widget.voted){
                _votes = widget.votesLength;
              }else{
                _votes = widget.votesLength + 1;
              }
              _construcVoteWidget(true, true);
            },
          ),
        );
      }else{
        _voteWidget = ScaleTransition(
          scale: _scaleFloat,
          child: IconButton(
            tooltip: 'Eliminar voto',
            splashColor: Theme.of(context).cardColor,
            icon: Icon(
              FontAwesomeIcons.solidStar,
              size: _iconSize,
              color: _solidColor,
            ),
            onPressed: (){
              Vibration.vibrate(duration: 20);
              if(widget.onUnvote != null){
                widget.onUnvote();
              }
              _voted = false;
              if(widget.voted){
                _votes = widget.votesLength - 1;
              }else{
                _votes = widget.votesLength;
              }
              _construcVoteWidget(false, true);
            },
          ),
        );
      }
      if(animate){
        _scaleController.forward();
      }
    });
  }

  _construcVotesWidget(BuildContext context){
    if(widget.showVotes){
      return Container(
        margin: EdgeInsets.only(bottom: 10, right: 14, left: 14),
        child: Text(
          '$_votes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).accentColor,
          ),
        ),
      );
    }else{
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      _emptyColor = Theme.of(context).accentColor;
      _solidColor = Theme.of(context).accentColor;
    });

    _construcVoteWidget(_voted, false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _voteWidget,
        _construcVotesWidget(context),
      ],
    );
  }
}