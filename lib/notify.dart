import 'package:flutter/material.dart';

class Notify{
  const Notify();

  static void show({
    @required BuildContext context,
    @required String text,
    @required String actionText,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    Color actionColor = Colors.black,
    Function onPressed,
  }){
    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      content: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontFamily: 'Roboto Condensed'
        ),
      ),
      action: SnackBarAction(
        textColor: actionColor,
        label: actionText,
        onPressed: () {
          onPressed();
        },
      ),
    );

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

/* Notify.show(
  context: context,
  text: 'El usuario no se ha encontrado.',
  actionText: 'Ok',
  backgroundColor: Colors.red[200],
  textColor: Colors.black,
  actionColor: Colors.black,
  onPressed: (){
    
  }
); */