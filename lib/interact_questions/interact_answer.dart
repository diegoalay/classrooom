import 'package:classroom/stateful_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InteractAnswer extends StatefulWidget {
  final int code;
  final bool unclickable;
  final Function onTap;

  const InteractAnswer({
    @required this.code,
    this.unclickable: false,
    this.onTap,
  });

  @override
  _InteractAnswerState createState() => _InteractAnswerState();
}

class _InteractAnswerState extends State<InteractAnswer> with SingleTickerProviderStateMixin {
  AnimationController _selectedAnswerIndicatorController;
  Animation _selectedAnswerIndicator;

  @override
  void initState() {
    super.initState();

    _selectedAnswerIndicatorController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _selectedAnswerIndicator = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _selectedAnswerIndicatorController,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  void _handleAnswerTap() {
    if (!widget.unclickable) {
      _selectedAnswerIndicatorController.forward();
    } 
    widget.onTap(widget.code);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          FadeTransition(
            opacity: _selectedAnswerIndicator,
            child: ScaleTransition(
              scale: _selectedAnswerIndicator,
              child: Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Icon(
                  FontAwesomeIcons.chevronDown,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          StatefulButton(
            text: String.fromCharCode(widget.code + 65),
            color: Theme.of(context).accentColor,
            fillColor: Colors.white,
            onTap: _handleAnswerTap,
          ),
        ],
      ),
    );
  }
}