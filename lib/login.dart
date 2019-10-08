import 'package:flutter/material.dart';
import 'package:classroom/stateful_textfield.dart';
import 'package:classroom/stateful_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:classroom/courses_route.dart';
import 'package:classroom/nav.dart';
import 'package:classroom/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:classroom/notify.dart';
import 'dart:io';

class Login extends StatefulWidget {
  const Login();

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin{
  FocusNode _passwordFocusNode;
  bool _register, _logging, _actuallyLogged;
  int _logged;
  TextEditingController _usernameController, _passwordController, _nameController, _passwordRepeatController;
  AnimationController _slideController;
  Animation<Offset> _registerOffsetFloat, _loginOffsetFloat;
  SharedPreferences prefs;


  @override
  void initState() {
    super.initState();
    _register = false;
    _actuallyLogged = false;
    _passwordFocusNode = FocusNode();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordRepeatController = TextEditingController();

    _logging = false;

    _initSharedPreferences();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _registerOffsetFloat = Tween<Offset>(
      begin: Offset(2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOut,
      )
    );

    _loginOffsetFloat = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-2, 0),
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOut,
      )
    );
  }

  void _initSharedPreferences() async{
    prefs = await SharedPreferences.getInstance();
    _logged = prefs.getInt('logged');
    if(!_actuallyLogged && prefs.getInt('logged') == 1){
      print("INICIADO");
      validateAndSubmit(prefs.getString('email'), prefs.getString('password'), '');
    }
    String userEmail = prefs.getString('email');
    if(userEmail != null){
      print('USERNAME: $userEmail');
      _usernameController.text = userEmail;
    }
  }

  void _navigateToCourses(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return Nav(
          section: 'courses',
          title: 'CURSOS',
          body: CoursesRoute(),
        );
      }),
    );
  }

  Future<bool> isConnected() async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    } 
    return false;   
  }
  void validateAndSubmit(String email, String password, String name) async {
    if((email == null || email == "") && (password == "" || password == null)){
      showNotification('Debe ingresar el correo y contraseña.');
      _logging = false;
    }else if(password == null || password == ""){
      showNotification('Debe ingresar la contraseña.');     
      _logging = false;
    }else if(email == null || email == ""){
      showNotification('Debe ingresar la dirección de correo.');      
      _logging = false;
    }else{
      email = email.toString().trim().toLowerCase();
      password = password.toString().trim();
      try{ 
        if(_register == true){
          await Auth.createUserWithEmailAndPassword(email,password,name);
          Auth.currentUser(name).then((userId){
            print("user: $userId");
            if(userId == null){
              showNotification('La dirección de correo no se puede registrar, ya ha sido tomada.'); 
              _logging = false;
            }else{
              showNotification('Se ha enviado un correo de confirmación para continuar con el proceso.'); 
              prefs.setInt('logged', 1);
              prefs.setString('email', email);
              prefs.setString('password', password);
              // _navigateToCourses(context);
              _passwordController.text = '';
              _nameController.text = '';
              _passwordRepeatController.text = '';
              _logging = false;
              _actuallyLogged = true;
            }
          });    
        }else{
          String user = await Auth.signInWithEmailAndPassword(email, password);
          print("Login: $user");
          Auth.currentUser("").then((userId){
            print("userId $userId");
            if(user == "-1"){
              showNotification('La dirección de correo no se encuentra, verifique sus datos.');            
              _logging = false;
            }else if(user == "0"){
              showNotification('No se ha confirmado la dirección de correo, porfavor verifique su bandeja de entrada.');   
            }else{
              prefs.setInt('logged', 1);
              prefs.setString('email', email);
              prefs.setString('password', password);
              _navigateToCourses(context);
              _passwordController.text = '';
              _passwordRepeatController.text = '';
              _logging = false;
              _actuallyLogged = true;
            } 
          });
        }
      }catch(e){
        print(e.toString());
        showNotification('La contraseña o dirección de correo que has introducido son incorrectos.');            
        _logging = false;
      }
    }

  } 

  void showNotification(String text){
    Notify.show(
      context: this.context,
      text: text,
      actionText: 'Ok',
      backgroundColor: Colors.red[200],
      textColor: Colors.black,
      actionColor: Colors.black,
      onPressed: (){
        
      }
    );    
  }
  Widget _registerForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        StatefulTextfield(
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
          helper: 'Correo electrónico.',
          label: 'Email',
          type: TextInputType.text,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          controller: _usernameController,
        ),
        StatefulTextfield(
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
          helper: 'Nombre de usuario.',
          label: 'Usuario',
          type: TextInputType.text,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          controller: _nameController,
        ),
        //ELEMENT: Campo para la CONTRASEÑA.
        StatefulTextfield(
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
          helper: 'Contraseña del usuario.',
          label: 'Contraseña',
          type: TextInputType.text,
          isObscure: true,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          controller: _passwordController,
        ),
        StatefulTextfield(
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
          helper: 'Contraseña del usuario.',
          label: 'Contraseña',
          type: TextInputType.text,
          isObscure: true,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          controller: _passwordRepeatController,
        ),
        Container(
          margin: EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              StatefulButton(
                icon: FontAwesomeIcons.arrowLeft,
                text: 'CANCELAR',
                color: Theme.of(context).primaryColor,
                onTap: (){
                  _slideController.reverse();
                  _register = false;
                },
                type: 'a',
                weight: FontWeight.bold,
              ),
              StatefulButton(
                text: 'ACEPTAR',
                color: Colors.white,
                borderColor: Theme.of(context).primaryColor,
                fillColor: Theme.of(context).primaryColor,
                onTap: (){
                  if(!_logging){
                    isConnected().then((internet){
                      if(internet){
                        if(_passwordRepeatController.text == _passwordController.text){
                          if((_passwordController.text).length >= 6){
                            if(_nameController.text == null || _nameController.text == ""){
                              showNotification('La contraseña debe ser de al menos 6 caracteres.');
                            }else{
                              _logging = true;
                              validateAndSubmit(_usernameController.text, _passwordController.text, _nameController.text);                        
                            }
                          }else{
                            showNotification('La contraseña debe ser de al menos 6 caracteres.');
                          }
                        }else{
                          showNotification('Las contraseñas no coinciden.');
                        }
                      }else{
                        showNotification('El dispositivo no tiene conección a internet');
                      }
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loginForm(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 12.0),
          child: RichText(
            text: TextSpan(
              text: 'Classroom',
              style: TextStyle(
                fontFamily: 'Vampiro One',
                color: Colors.white,
                fontSize: 50.0,
                //fontWeight: FontWeight.bold,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 12.0,
                    color: Color.fromARGB(20, 0, 0, 0),
                  ),
                ],
              ),
            ),
            
          ),
        ),
        StatefulTextfield(
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
          helper: 'Correo electrónico.',
          label: 'Email',
          type: TextInputType.text,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          onSubmitted: (String value){
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          controller: _usernameController,
        ),
        //ELEMENT: Campo para la CONTRASEÑA.
        StatefulTextfield(
          focusNode: _passwordFocusNode,
          weight: FontWeight.bold,
          suffix: '',
          color: Colors.redAccent[100],
          helper: 'Contraseña del usuario.',
          label: 'Contraseña',
          type: TextInputType.text,
          isObscure: true,
          onChangedFunction: (String value){
            this.setState(() {   
            });
          },
          onSubmitted: (String value){
            if(!_logging){
              isConnected().then((internet){
                if(internet){
                  _logging = true;
                  validateAndSubmit(_usernameController.text, _passwordController.text,"");
                }else{
                  showNotification('El dispositivo no tiene conección a internet');
                }
              });              
            }
          },
          controller: _passwordController,
        ),
        Container(
          margin: EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              StatefulButton(
                text: 'REGISTRARSE',
                color: Theme.of(context).primaryColor,
                onTap: (){
                  _slideController.forward();
                  _register = true;
                },
                type: 'a',
                weight: FontWeight.bold,
              ),
              StatefulButton(
                text: 'OLVIDE',
                color: Theme.of(context).primaryColor,
                onTap: (){
                  Auth.resetPassword(_usernameController.text);
                  showNotification('Se ha enviado un correo para reestablecer la contraseña.');
                },
                type: 'a',
                weight: FontWeight.bold,
              ),
              StatefulButton(
                text: 'INICIAR',
                color: Colors.white,
                borderColor: Theme.of(context).primaryColor,
                fillColor: Theme.of(context).primaryColor,
                onTap: (){
                  if(!_logging){
                    _logging = true;
                     validateAndSubmit(_usernameController.text, _passwordController.text,"");
                  }
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginWidget = FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: GestureDetector(
        onTap: (){
          print('TAAAAP');
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/images/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.all(25.0),
          alignment: Alignment(0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    SlideTransition(
                      position: _loginOffsetFloat,
                      child: _loginForm()
                    ),
                    SlideTransition(
                      position: _registerOffsetFloat,
                      child: _registerForm()
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Copyright © Diego Alay & Henry Campos',
                  style: TextStyle(
                    fontFamily: 'Roboto Condensed',
                    color: Colors.white,
                    fontSize: 12.0,
                    //fontWeight: FontWeight.bold,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 12.0,
                        color: Color.fromARGB(20, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: loginWidget,
    );
  }
}