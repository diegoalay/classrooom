import 'package:flutter/material.dart';
import 'package:classroom/textfield_bloc.dart';

class StatefulTextfield extends StatefulWidget {
  final String suffix;
  final Color color, fillColor, borderColor, suffixColor;
  final String helper, label, hint;
  final TextInputType type;
  final TextfieldBloc channel;
  final Function onChangedFunction, onSubmitted;
  final bool isObscure;
  final TextEditingController controller;
  final FontWeight weight;
  final FocusNode focusNode;
  final EdgeInsets margin, padding;
  final double borderRadius;

  const StatefulTextfield({
    @required this.suffix,
    this.color : Colors.black,
    this.margin : const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
    this.padding : const EdgeInsets.all(18),
    this.onSubmitted,
    this.focusNode,
    this.borderColor : Colors.white,
    this.suffixColor : Colors.black,
    this.hint,
    this.label,
    this.helper,
    this.fillColor,
    this.controller,
    this.type,
    this.channel,
    this.onChangedFunction,
    this.isObscure : false,
    this.weight : FontWeight.normal,
    this.borderRadius : 4.0,
  });

  @override
  _StatefulTextfieldState createState() => _StatefulTextfieldState();
}

class _StatefulTextfieldState extends State<StatefulTextfield> {
  String _actualSuffixSelected;
  bool _filled;
  Color _fillColor;

  @override
  void initState() {
    super.initState();
    this._actualSuffixSelected = widget.suffix;

    if(widget.fillColor != null){
      _fillColor = widget.fillColor;
      _filled = true;
    }else{
      _fillColor = Colors.transparent;
      _filled = false;
    }
  }

  Widget baseTextfield(String suffix){
    return Container(
      margin: widget.margin,
      child: TextField(
          onChanged: (val){
            if(widget.onChangedFunction != null){
              widget.onChangedFunction(val);
            }
          },
          focusNode: widget.focusNode,
          onSubmitted: (val){
            if(widget.onSubmitted != null){
              widget.onSubmitted(val);
            }
          },
          controller: widget.controller,
          obscureText: widget.isObscure,
          //textAlign: TextAlign.center,
          keyboardType: widget.type,
          decoration: InputDecoration(
            contentPadding: widget.padding,
            fillColor: _fillColor,
            filled: _filled,
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: widget.suffixColor,
            ),
            labelText: widget.label,
            hintStyle: TextStyle(

              color: Colors.grey,
            ),
            hintText: widget.hint,
            helperText: widget.helper,
            helperStyle: TextStyle(
              color: Colors.white,
            ),
            labelStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: widget.borderColor,
                width: 3.0,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            hasFloatingPlaceholder: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                style: BorderStyle.solid,
              ),
            ),
          ),
          style: TextStyle(
            fontFamily: 'Roboto Condensed',
            fontSize: 18.0,
            //color: Color.fromARGB(255, 0, 11, 43),
            color: widget.color,
            fontWeight: widget.weight,
          ),
          cursorColor: widget.color,
        ),
    );
  }

  Widget build(BuildContext context) {
    if(widget.channel == null){
      return baseTextfield(this._actualSuffixSelected);
    }else{
      return StreamBuilder(
        stream: widget.channel.updateSuffixOut,
        initialData: _actualSuffixSelected,
        builder: (context, snapshot) => baseTextfield(snapshot.data),
      );
    }
  }
}
