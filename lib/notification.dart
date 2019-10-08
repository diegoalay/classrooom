import 'package:flutter/material.dart';

class Notification extends StatefulWidget{
  final String text;
  final String type;
  final String author;

  const Notification({
    @required this.text,
    this.type: 'Pregunta',
    this.author: '',
  });

  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<Notification>{
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        widget.text,
      ),
    );
  }
}