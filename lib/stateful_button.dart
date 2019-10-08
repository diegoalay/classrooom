import 'package:flutter/material.dart';

class StatefulButton extends StatefulWidget{
  final Function onTap;
  final String type, text;
  final Color borderColor, fillColor, color;
  final FontWeight weight;
  final IconData icon;
  final EdgeInsetsGeometry iconMargin;
  final double fontSize;

  const StatefulButton({
    @required this.onTap,
    @required this.text,
    @required this.color,
    this.type,
    this.borderColor,
    this.fillColor,
    this.weight,
    this.icon,
    this.iconMargin,
    this.fontSize: 15,
  });

  @override
  _StatefulButtonState createState() => _StatefulButtonState();
}

class _StatefulButtonState extends State<StatefulButton>{
  EdgeInsetsGeometry _padding, _iconMargin;
  FontWeight _weight;
  Color _fillColor, _borderColor;
  BorderStyle _borderStyle;
  Widget _icon;

  @override
  void initState() {
    super.initState();
    if(widget.type == 'a'){
      _padding = EdgeInsets.fromLTRB(0, 0, 0, 0);
      _borderStyle = BorderStyle.none;
      _fillColor = Colors.transparent;
      _borderColor = Colors.transparent;
    }else{
      _padding = EdgeInsets.fromLTRB(25, 0, 25, 0);
      _borderStyle = BorderStyle.solid;
      if(widget.borderColor != null){
        _borderColor = widget.borderColor;
      }else{
        _borderColor = Colors.white;
      }

      if(widget.fillColor != null){
        _fillColor = widget.fillColor;
      }else{
        _fillColor = Colors.transparent;
      }
    }

    if(widget.weight == null){
      _weight = FontWeight.normal;
    }else{
      _weight = widget.weight;
    }
  }

  Widget build(BuildContext context){
    if(widget.icon == null){
      _icon = Container();
    }else{
      if(widget.iconMargin == null){
        _iconMargin = EdgeInsets.only(right: 10);
      }else{
        _iconMargin = widget.iconMargin;
      }
      _icon = Container(
                margin: _iconMargin,
                child: Icon(
                  widget.icon,
                  color: widget.color,
                ),
              );
    }
    
    return GestureDetector(
      onTap: (){
        widget.onTap();
      },
      child: Container(
        alignment: Alignment(0, 0),
        padding: _padding,
        height: 50,
        decoration: ShapeDecoration(
          color: _fillColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1.0, 
              style: _borderStyle,
              color: _borderColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
        ),
        child: Row(
          children: <Widget>[
            _icon,
            RichText(
              text: TextSpan(
                text: widget.text,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontFamily: 'Roboto Condensed',
                  fontWeight: _weight,
                  color: widget.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}