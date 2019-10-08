import 'package:rxdart/rxdart.dart';
import 'dart:async';

class WidgetPasser{
  Sink<String> get sender => _sendWidgetController.sink;
  final _sendWidgetController = StreamController<String>();

  Stream<String> get receiver => _recieveWidgetSubject.stream;
  final _recieveWidgetSubject = BehaviorSubject<String>();

  void closeSender() => _sendWidgetController.close();

  void closeReceiver() => _recieveWidgetSubject.close();

  WidgetPasser(){
    _sendWidgetController.stream.listen(_handle);
  }

  void _handle(String suffix){
    _recieveWidgetSubject.add(suffix);
  }

}