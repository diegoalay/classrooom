import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vibration/vibration.dart';

class StatefulNotification extends StatefulWidget{
  final String text, type, author;
  final int index;

  const StatefulNotification({
    @required this.text,
    this.type: 'Pregunta',
    this.author: '',
    this.index: 0,
  });

  _StatefulNotificationState createState() => _StatefulNotificationState();
}

class _StatefulNotificationState extends State<StatefulNotification> with TickerProviderStateMixin{
  AnimationController _notificationPositionController, _notificationHeightController;
  Animation<Offset> _offsetFloat;
  Animation<double> _heightFloat;

  @override
  void initState() {
    super.initState();

    _notificationPositionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _notificationHeightController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );

    _offsetFloat = Tween<Offset>(
      begin: Offset(-1.0, 0.0), 
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _notificationPositionController,
        curve: Curves.easeInOut,
      ),
    );

    _heightFloat = Tween<double>(
      begin: 0, 
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _notificationPositionController,
        curve: Curves.linear,
      ),
    );

    _notificationPositionController.forward().then((val){
      _notificationHeightController.forward();
    });
  }

  @override
  void dispose() {
    _notificationPositionController.dispose(); 
    _notificationHeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetFloat,
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: _notificationHeightController,
        child: Container(
          margin: EdgeInsets.fromLTRB(9, 10, 9, 10),
          padding: EdgeInsets.fromLTRB(9, 0, 0, 0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).accentColor,
                      width: 9,
                    ),
                  ),
                ),
                margin: EdgeInsets.only(right: 40),
                padding: EdgeInsets.only(right: 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 3, top: 9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            widget.author,
                            style:TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            )
                          ),
                          /* Container(
                            margin: EdgeInsets.only(right: 3),
                            child: Icon(
                              FontAwesomeIcons.times,
                              size: 12,
                            ),
                          ), */
                        ],
                      ),
                    ),
                    Container(
                      child: Text(
                        widget.text,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 3, bottom: 9),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.solidCircle,
                            size: 8,
                            color: Colors.grey,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 3),
                            child: Text(
                              widget.type,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: Tooltip(
                  message: 'Eliminar',
                  child: GestureDetector(
                    onTap: (){
                      Vibration.vibrate(duration: 20);
                      
                      _notificationPositionController.reverse().then((f){
                        _notificationHeightController.reverse();
                      });
                    },
                    child: Container(
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.redAccent[100],
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(right: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.trashAlt,
                              color: Theme.of(context).accentColor,
                              size: 17,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}