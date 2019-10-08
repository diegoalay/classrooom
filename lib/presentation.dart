// import 'package:flutter/material.dart';
// import 'package:native_pdf_view/native_pdf_view.dart';
// import 'package:photo_view/photo_view.dart';
import 'dart:async';
import 'dart:math';
import 'package:classroom/chatbar.dart';
import 'package:classroom/interact_route.dart';
import 'package:flutter/material.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:pinch_zoom_image/pinch_zoom_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:classroom/widget_passer.dart';
import 'package:vibration/vibration.dart';

class Presentation extends StatefulWidget{
  static final WidgetPasser slidePasser = WidgetPasser();
  final String file;

  const Presentation({
    @required this.file,
  });

  _PresentationState createState() => _PresentationState();
}

class _PresentationState extends State<Presentation> with AutomaticKeepAliveClientMixin{
  PDFDocument _document;
  PDFPage _page;
  PDFPageImage _pageImage;
  int _actualPage;
  List<PDFPageImage> _pageImages;
  bool _loading;

  @override
  void initState(){
    super.initState();

    _prepareDocument().then((_){
      _pageImages = List<PDFPageImage>(_document.pagesCount);
      setState((){
      });
    });

    _actualPage = 0;

    _loading = false;

    Presentation.slidePasser.receiver.listen((newSlide) {
      if (newSlide != null && this.mounted) {
        setState(() {
          _actualPage = int.parse(newSlide) - 1;
        });
      }
    });
  }

  @override
  void dispose() {
    Presentation.slidePasser.sender.add(null);
    super.dispose();
  }

  Future<void> _prepareDocument() async{
    _document = await PDFDocument.openFile(widget.file);
  }

  @override
  bool get wantKeepAlive => true;

  void _changeToSlide(int page){
    if(!_loading) setState(() {
      _actualPage = page;
    });
    if(InteractRoute.questionPositionController.isCompleted) InteractRoute.questionController.add((_actualPage + 1).toString());
  }

  void _changeToNextSlide(){
    _changeToSlide((_actualPage + 1) % _document.pagesCount);
  }

  void _changeToPreviousSlide(){
    _changeToSlide((_actualPage - 1) % _document.pagesCount);
  }

  Future<Widget> _construc(BuildContext context) async{
    _loading = true;
    if(_pageImages[_actualPage] == null){
      _page = await _document.getPage(_actualPage + 1);
      _pageImage = await _page.render(width: _page.width, height: _page.height, backgroundColor: 'white');
      _pageImages[_actualPage] = _pageImage;
      await _page.close().then((_){
        _loading = false;
      });
    }else{
      _pageImage = _pageImages[_actualPage];
      _loading = false;
    }
    
    return Future.delayed(const Duration(milliseconds: 0), () => 
      Container(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: EdgeInsets.only(bottom: 58),
                // child: PinchZoomImage(
                //   image: Image(
                //     image: MemoryImage(_pageImage.bytes),
                //   ),
                // ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: _changeToPreviousSlide,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.chevronLeft,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Vibration.hasVibrator().then((_){
                        Vibration.vibrate(duration: 20);
                      });
                      if(InteractRoute.questionPositionController.status == AnimationStatus.dismissed || InteractRoute.questionPositionController.status == AnimationStatus.reverse){
                        InteractRoute.questionController.add((_actualPage + 1).toString());
                        InteractRoute.questionPositionController.forward();
                        ChatBar.mode = ChatBarMode.QUESTION_WITH_POSITION;
                        FocusScope.of(context).requestFocus(ChatBar.chatBarFocusNode);
                      }else{
                        InteractRoute.questionPositionController.reverse();
                        ChatBar.mode = ChatBarMode.QUESTION;
                      }
                      ChatBar.labelPasser.sender.add('Escriba una pregunta');
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 4),
                          child: Transform.rotate(
                            angle: pi/4,
                            child: Icon(
                              FontAwesomeIcons.thumbtack,
                              size: 14,
                            ),
                          ),
                        ),
                        Text(
                          '${_actualPage + 1}/${_document.pagesCount}',
                          style: TextStyle(
                            fontSize: 16,
                            // fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _changeToNextSlide,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.chevronRight,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _construc(context),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.hasData){
          return snapshot.data;
        }else{
          return Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SpinKitRing(
                  color: Theme.of(context).accentColor,
                  size: 30.0,
                  lineWidth: 4,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}