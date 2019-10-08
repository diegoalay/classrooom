import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/stateful_textfield.dart';

class AddBar extends StatefulWidget{
  final Function onSubmitted;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint, alertMessage;

  const AddBar({
    this.focusNode,
    this.controller,
    this.onSubmitted,
    this.hint: '',
    this.alertMessage: '',
  });

  _AddBarState createState() => _AddBarState();
}

class _AddBarState extends State<AddBar>{
  Animation<double> _widthFloat;

  @override
  void initState() {
    super.initState();
  }

  Widget _postAlertInAddBar(){
    if(widget.alertMessage == ''){
      return Container();
    }else{
      return SizeTransition(
        sizeFactor: _widthFloat,
        axis: Axis.vertical,
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 1, 0, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 5),
                child: Icon(
                  FontAwesomeIcons.exclamationCircle,
                  color: Theme.of(context).primaryColor,
                  size: 12,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  widget.alertMessage,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StatefulTextfield(
          controller: widget.controller, 
          focusNode: widget.focusNode,
          fillColor: Colors.white,
          suffix: '',
          color: Theme.of(context).accentColor,
          helper: null,
          hint: widget.hint,
          type: TextInputType.text,
          onSubmitted: (val){
            widget.onSubmitted();
          },
        ),
        _postAlertInAddBar(),
      ],
    );
  }
}