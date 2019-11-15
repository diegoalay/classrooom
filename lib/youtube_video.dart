import 'dart:math';

import 'package:classroom/widget_passer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:youtube_player/youtube_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'package:classroom/interact_route.dart';
import 'chatbar.dart';

class YouTubeVideo extends StatefulWidget {
  static final WidgetPasser videoSeekToPasser = new WidgetPasser();

  final String videoId;

  const YouTubeVideo({
    @required this.videoId
  });

  @override
  _YouTubeVideoState createState() => _YouTubeVideoState();
}

class _YouTubeVideoState extends State<YouTubeVideo> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin{
  Animation<double> _videoPlayButtonFloat, _videoUIOpacityFloat, _videoSeekUIOpacityFloat;
  AnimationController _videoPlayButtonController, _videoUIOpacityController, _videoSeekUIOpacityController;
  String _videoPosition, _videoDuration;
  bool _videoInitialized, _activeSlider;
  YoutubePlayerController _videoController = YoutubePlayerController();
  double _videoDurationBarWidth, _videoForwardOpacity, _videoBackwardOpacity, _sliderValue;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    _videoInitialized = false;
    _activeSlider = false;

    _videoDurationBarWidth = 0;
    _videoForwardOpacity = 0;
    _videoBackwardOpacity = 0;
    _sliderValue = 0;

    _videoDuration = '';
    _videoPosition = '';

    _videoPlayButtonController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _videoPlayButtonFloat = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        curve: Curves.linear,
        parent: _videoPlayButtonController,
      )
    );

    _videoUIOpacityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _videoUIOpacityFloat = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeInOut,
        parent: _videoUIOpacityController,
      ),
    );

    _videoSeekUIOpacityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _videoSeekUIOpacityFloat = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeInOut,
        parent: _videoSeekUIOpacityController,
      ),
    );

    YouTubeVideo.videoSeekToPasser.receiver.listen((position) {
      if (position != null && _videoController.value.duration != null) {
        List<String> splittedPosition = position.split(':');
        Duration newPosition = Duration(seconds: int.parse(splittedPosition[0]) * 60 + int.parse(splittedPosition[1]));
        _videoController.seekTo(newPosition);
      }
    });
  }

  void _updateVideoUI(){
    // double width = MediaQuery.of(context).size.width;
    YoutubePlayerValue value = _videoController.value;
    if(!_videoInitialized && value.duration != null){
      _videoUIOpacityController.forward();
      _videoInitialized = true;
    } 

    if(value.duration != null){
      setState(() {
        if(!_activeSlider){
          _videoDurationBarWidth = value.position.inSeconds/value.duration.inSeconds;
          print(_videoDurationBarWidth);
          _sliderValue = _videoDurationBarWidth.isNaN ? 0 : _videoDurationBarWidth;
          // _videoDurationBarWidth = value.position.inSeconds/value.duration.inSeconds + 10/width;
          // _sliderValue = _videoDurationBarWidth * width - 10;
          // if(_sliderValue + 20 > width) _sliderValue = width - 20;
          // if(_sliderValue < 0) _sliderValue = 0;
        }
        int positionSeconds = value.position.inSeconds % 60;
        String positionSecondsString = (positionSeconds < 10)? '0$positionSeconds':'$positionSeconds'; 
        int durationSeconds = value.duration.inSeconds % 60;
        String durationSecondsString = (durationSeconds < 10)? '0$durationSeconds':'$durationSeconds'; 
        _videoPosition = '${value.position.inMinutes}:$positionSecondsString';
        _videoDuration = '${value.duration.inMinutes}:$durationSecondsString';
        if(InteractRoute.questionPositionController.isCompleted) InteractRoute.questionController.add(_videoPosition);
      });
    }
  }

  void _playButtonFunctions(){
    if(_videoInitialized){
      if(_videoUIOpacityController.status == AnimationStatus.forward || _videoUIOpacityController.status == AnimationStatus.completed){
        if(_videoPlayButtonController.status == AnimationStatus.dismissed || _videoPlayButtonController.status == AnimationStatus.reverse){
          _videoPlayButtonController.forward();
          _videoController.play();
          Timer(Duration(milliseconds: 0), (){
            _videoUIOpacityController.reverse();
          });
        } 
        else{
          _videoPlayButtonController.reverse();
          _videoController.pause();
        }
      }else{
        _videoUIOpacityController.forward();
      }
    }
  }

  @override
  void dispose() {
    YouTubeVideo.videoSeekToPasser.sender.add(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: EdgeInsets.only(bottom: 18),
      child: Stack(
          children: <Widget>[
            YoutubePlayer(
              context: context,
              videoId: widget.videoId,
              flags: YoutubePlayerFlags(
                mute: false,
                autoPlay: false,
                forceHideAnnotation: true,
                showVideoProgressIndicator: true,
                disableDragSeek: false,
                hideControls: true,
              ),
              videoProgressIndicatorColor: Color(0xFFFF0000),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20.0,
                  ),
                  onPressed: () {},
                ),
                Text(
                  'Hello! This is a test title.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 25.0,
                  ),
                  onPressed: () {},
                ),
              ],              
              progressColors: ProgressColors(
                playedColor: Color(0xFFFF0000),
                handleColor: Color(0xFFFF4433),
              ),
              onPlayerInitialized: (controller) {
                _videoController = controller;
              _videoController.addListener((){
                _updateVideoUI();
              });
              },
            ),
            SizedBox(
              height: 10.0,
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: FadeTransition(
              opacity: _videoSeekUIOpacityFloat,
              child: Container(
                color: Color.fromARGB(90, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Opacity(
                      opacity: _videoBackwardOpacity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Icon(
                              FontAwesomeIcons.backward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Text(
                            '10 segundos',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: _videoForwardOpacity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Icon(
                              FontAwesomeIcons.forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Text(
                            '10 segundos',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 0,
            child: FadeTransition(
              opacity: _videoUIOpacityFloat,
              child: GestureDetector(
                onTap: (){
                  if(_videoUIOpacityController.status == AnimationStatus.forward || _videoUIOpacityController.status == AnimationStatus.completed){
                    _videoUIOpacityController.reverse();
                  }else{
                    _videoUIOpacityController.forward().then((_){
                      // print(_videoPlayButtonController.status);
                      // if(_videoPlayButtonController.isCompleted) Timer(Duration(milliseconds: 1500), (){
                      //   if(!_videoPlayButtonController.isDismissed && !(_videoPlayButtonController.status == AnimationStatus.reverse)) _videoUIOpacityController.reverse();
                      // });
                    });
                  }
                },
                child: Container(
                  color: Color.fromARGB(90, 0, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Tooltip(
                            message: 'Preguntar en minuto $_videoPosition',
                            child: GestureDetector(
                              onTap: (){
                                if(_videoUIOpacityController.isCompleted){
                                  Vibration.hasVibrator().then((_){
                                    Vibration.vibrate(duration: 20);
                                  });
                                  if(InteractRoute.questionPositionController.status == AnimationStatus.dismissed || InteractRoute.questionPositionController.status == AnimationStatus.reverse){
                                    InteractRoute.questionController.add(_videoPosition);
                                    InteractRoute.questionPositionController.forward();
                                    ChatBar.mode = ChatBarMode.QUESTION_WITH_POSITION;
                                    FocusScope.of(context).requestFocus(ChatBar.chatBarFocusNode);
                                    // ChatBar.labelPasser.sendWidget.add('Escriba una pregunta');
                                  }else{
                                    InteractRoute.questionPositionController.reverse();
                                    ChatBar.mode = ChatBarMode.QUESTION;
                                    // ChatBar.labelPasser.sendWidget.add('Escriba una pregunta');
                                  }
                                }else{
                                  _videoUIOpacityController.forward();
                                }
                              },
                              child: Container(
                                // padding: EdgeInsets.fromLTRB(12,12,12,12),
                                height: 45,
                                width: 45,
                                color: Colors.white.withAlpha(0),
                                child: Transform.rotate(
                                  angle: pi/4,
                                  child: Icon(
                                    FontAwesomeIcons.thumbtack,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        top: 0,
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          heightFactor: 1,
                                          widthFactor: 0.5,
                                          child: Opacity(
                                            opacity: 0,
                                            child: GestureDetector(
                                              onDoubleTap: (){
                                                bool isForwardNeeded = false;
                                                if(_videoUIOpacityController.status == AnimationStatus.completed){
                                                  _videoUIOpacityController.reverse();
                                                  isForwardNeeded = true;
                                                }
                                                _videoController.seekTo(Duration(seconds: _videoController.value.position.inSeconds - 10));
                                                setState(() {
                                                  _videoBackwardOpacity = 1;
                                                  _videoForwardOpacity = 0;
                                                });
                                                _videoSeekUIOpacityController.forward().then((_){
                                                  _videoSeekUIOpacityController.reverse();
                                                  if(isForwardNeeded) _videoUIOpacityController.forward();
                                                });
                                              },
                                              child: Container(
                                                color: Colors.pink,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        top: 0,
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerRight,
                                          heightFactor: 1,
                                          widthFactor: 0.5,
                                          child: Opacity(
                                            opacity: 0,
                                            child: GestureDetector(
                                              onDoubleTap: (){
                                                bool isForwardNeeded = false;
                                                if(_videoUIOpacityController.status == AnimationStatus.completed){
                                                  _videoUIOpacityController.reverse();
                                                  isForwardNeeded = true;
                                                }
                                                _videoController.seekTo(Duration(seconds: _videoController.value.position.inSeconds + 10));
                                                setState(() {
                                                  _videoBackwardOpacity = 0;
                                                  _videoForwardOpacity = 1;
                                                });
                                                _videoSeekUIOpacityController.forward().then((_){
                                                  _videoSeekUIOpacityController.reverse();
                                                  if(isForwardNeeded) _videoUIOpacityController.forward();
                                                });
                                                
                                              },
                                              child: Container(
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: GestureDetector(
                                          onTap: (){
                                            _playButtonFunctions();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(24),
                                            child: AnimatedIcon(
                                              icon: AnimatedIcons.play_pause,
                                              progress: _videoPlayButtonFloat,
                                              size: 58,
                                              color: Colors.white,
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
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(12, 0, 0, 18),
                            child: Text(
                              _videoPosition,
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                          ),
                          // Container(
                          //   padding: EdgeInsets.fromLTRB(0, 0, 12, 18),
                          //   child: Text(
                          //     _videoSeekTo,
                          //     style: TextStyle(
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 12, 18),
                            child: Text(
                              _videoDuration,
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),            
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 4,
                    color: Color.fromARGB(50, 255, 255, 255),
                    child: Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            heightFactor: 1,
                            widthFactor: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(30, 255, 96, 64), 
                                borderRadius: BorderRadius.circular(20)
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            heightFactor: 1,
                            widthFactor: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20)
                              ),
                            ),
                          ),
                        ),
                        // Positioned(
                        //   left: _sliderValue,
                        //   bottom: -8,
                        //   child: Container(
                        //     child: Draggable(
                        //       affinity: Axis.horizontal,
                        //       maxSimultaneousDrags: 1,
                        //       onDragStarted: (){
                        //         _activeSlider = true;
                        //         Vibration.hasVibrator().then((val){
                        //           if(val){
                        //             Vibration.vibrate(duration: 40);
                        //           }
                        //         });
                        //       },
                        //       onDraggableCanceled: (velocity, offset){
                        //         double width = MediaQuery.of(context).size.width;
                        //         YoutubePlayerValue value = _videoController.value;
                        //         double position = offset.dx/width;
                        //         int seekToSeconds = (value.duration.inSeconds * position).round() % 60;
                        //         String seekToSecondsString = (seekToSeconds < 10)? '0$seekToSeconds':'$seekToSeconds';
                        //         setState(() {
                        //           _sliderValue = offset.dx;
                        //           print('slider $_sliderValue');
                        //           // _videoDurationBarWidth = position; 
                        //           _videoPosition = '${(value.duration.inSeconds * position / 60).truncate()}:$seekToSecondsString';
                        //         });
                        //         _activeSlider = false;
                        //         _videoController.seekTo(Duration(milliseconds: (_videoController.value.duration.inMilliseconds * position).round()));
                        //       },
                        //       childWhenDragging: Container(),
                        //       axis: Axis.horizontal,
                        //       child: ScaleTransition(
                        //         scale: _videoUIOpacityFloat,
                        //         child: Container(
                        //           height: 20,
                        //           width: 20,
                        //           decoration: BoxDecoration(
                        //             color: Theme.of(context).primaryColor,
                        //             shape: BoxShape.circle
                        //           ),
                        //         ),
                        //       ),
                        //       feedback: Container(
                        //         height: 20,
                        //         width: 20,
                        //         decoration: BoxDecoration(
                        //           color: Theme.of(context).primaryColor,
                        //           shape: BoxShape.circle
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        FadeTransition(
                          opacity: _videoUIOpacityFloat,
                          child: Container(
                            child: Slider(
                              activeColor: Theme.of(context).primaryColor,
                              inactiveColor: Colors.transparent,
                              value: _sliderValue,
                              onChangeStart: (position){
                                _activeSlider = true;
                                Vibration.hasVibrator().then((val){
                                  if(val){
                                    Vibration.vibrate(duration: 20);
                                  }
                                });
                              },
                              onChanged: (position){
                                YoutubePlayerValue value = _videoController.value;
                                int seekToSeconds = (value.duration.inSeconds * position).round() % 60;
                                String seekToSecondsString = (seekToSeconds < 10)? '0$seekToSeconds':'$seekToSeconds'; 
                                setState(() {
                                  _videoPosition = '${(value.duration.inSeconds * position / 60).truncate()}:$seekToSecondsString';
                                  _sliderValue = position;
                                  _videoDurationBarWidth = position;
                                });
                              },
                              onChangeEnd: (position){
                                _activeSlider = false;
                                _videoController.seekTo(Duration(seconds: (_videoController.value.duration.inSeconds * position).round()));
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
                ),
              ],
            ),
          ),          
        ],
      ),
    );
  }
}