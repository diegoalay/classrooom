import 'package:flutter/material.dart';
import 'package:classroom/stateful_notification.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationHub extends StatefulWidget{
  static List<StatefulNotification> notifications;
  final AnimationController notificationHubPositionController;

  const NotificationHub({
    @required this.notificationHubPositionController,
  });

  _NotificationHubState createState() => _NotificationHubState();
}

class _NotificationHubState extends State<NotificationHub> with SingleTickerProviderStateMixin{
  Animation<Offset> _offsetDouble;
  int _count;

  @override
  void initState() {
    super.initState();
    NotificationHub.notifications = List<StatefulNotification>();
    _count = 0;

    NotificationHub.notifications.add(
      StatefulNotification(
        text: 'In this article, well be looking at the Container widget and how it is used ... the Container will attempt to take up the entire width and height of',
        author: 'Henry Campos',
        type: 'Pregunta',
        index: NotificationHub.notifications.length,
      )
    );

    NotificationHub.notifications.add(
      StatefulNotification(
        text: 'Adiooooos',
        author: 'Diego Alay',
        type: 'Pregunta',
        index: NotificationHub.notifications.length,
      )
    );

    NotificationHub.notifications.add(
      StatefulNotification(
        text: 'Holiwis',
        author: 'Henry Campos',
        type: 'Pregunta',
        index: NotificationHub.notifications.length,
      )
    );

    NotificationHub.notifications.add(
      StatefulNotification(
        text: 'Adiooooos',
        author: 'Diego Alay',
        type: 'Pregunta',
        index: NotificationHub.notifications.length,
      )
    );

    NotificationHub.notifications.add(
      StatefulNotification(
        text: 'Holiwis',
        author: 'Henry Campos',
        type: 'Pregunta',
        index: NotificationHub.notifications.length,
      )
    );

    NotificationHub.notifications.add(
      StatefulNotification(
        text: 'Adiooooos',
        author: 'Diego Alay',
        type: 'Pregunta',
        index: NotificationHub.notifications.length,
      )
    );

    //print(NotificationHub.notifications[0].text);

    /* NotificationHub.notificationHubPositionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    ); */

    _offsetDouble = Tween<Offset>(
      begin: Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: widget.notificationHubPositionController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SlideTransition(
      position: _offsetDouble,
      child: Stack(
        children: <Widget>[ 
          FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(9, 12, 9, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor, 
                border: Border(
                  top: BorderSide(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
              ),
              child: ListView.builder(
                itemCount: NotificationHub.notifications.length,
                itemBuilder: (context, index){
                  return NotificationHub.notifications.elementAt(index);
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.only(bottom: 24),
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).accentColor,
                        border: Border.all(
                          color: Theme.of(context).accentColor,
                          width: 6,
                        )
                      ),
                      
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.only(bottom: 3),
                        child: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.timesCircle, 
                            size: 25,
                            color: Theme.of(context).accentColor,
                          ),
                          onPressed: (){
                            widget.notificationHubPositionController.reverse();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}