import 'package:rxdart/rxdart.dart';
import 'dart:async';

class TextfieldBloc{
  Sink<String> get updateSuffixIn => _updateSuffixController.sink;
  final _updateSuffixController = StreamController<String>();

  Stream<String> get updateSuffixOut => _updateSuffixSubject.stream;
  final _updateSuffixSubject = BehaviorSubject<String>();

  TextfieldBloc(){
    _updateSuffixController.stream.listen(_handle);
  }

  void _handle(String suffix){
    _updateSuffixSubject.add(suffix);
  }

}