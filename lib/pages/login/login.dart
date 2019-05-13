import 'package:flutter/material.dart';
import 'package:yadda/widgets/primary_button.dart';
import 'package:yadda/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yadda/utils/uidata.dart';
import 'dart:async';
import 'package:yadda/objects/user.dart';
import 'package:yadda/pages/legal/TermsAndConditions.dart';

class Login extends StatefulWidget {
  Login(
      {Key key,
      this.title,
      this.auth,
      this.onSignIn,
      this.currentUser,
      this.messagingToken})
      : super(key: key);
  final String messagingToken;
  final String title;
  final BaseAuth auth;
  final VoidCallback onSignIn;
  final String currentUser;

  @override
  LoginState createState() => new LoginState();
}

enum FormType { login, register, forgotPassword }

class LoginState extends State<Login> {
  static final formKey = new GlobalKey<FormState>();

  final myController = new TextEditingController();

  Firestore firestoreInstance = Firestore.instance;

  String finalUsername;

  String uid;
  String _username;
  String _email;
  String _resetEmail;
  String _password;
  FormType _formType = FormType.login;
  String _authHint = '';

  bool passwordsMatch = false;
  bool usernameAvailable = false;
  bool loading = false;
  bool passwordVisible = false;
  IconData passwordVisibleIcon = Icons.visibility;

  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          title: new Text(
            "Preflop",
            style: new TextStyle(
                color: UIData.blackOrWhite, fontSize: UIData.fontSize24),
          ),
          backgroundColor: UIData.appBarColor,
        ),
        backgroundColor: UIData.darkest,
        body: new Stack(
          children: <Widget>[
            material(),
            circular(),
          ],
        ));
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    setState(() {
      loading = false;
    });
    return false;
  }

  duration() {
    Duration duration = new Duration(
      seconds: 4,
    );

    new Timer(duration, () {
      setState(() {
        _authHint = "";
      });
    });
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          if (!_email.contains("@")) {
            QuerySnapshot qSnap = await firestoreInstance
                .collection("usernames")
                .where("name", isEqualTo: _email)
                .getDocuments();
            if (qSnap.documents.isNotEmpty) {
              _email = qSnap.documents[0].data["email"];
            }
          }
          String userId = await widget.auth.signIn(_email, _password);
          uid = userId;
          widget.onSignIn();
        } else if (usernameAvailable == true &&
            _formType == FormType.register) {
          String userId = await widget.auth.createUser(_email, _password);
          uid = userId;
          widget.onSignIn();
          saveUserData();
        }
      } catch (e) {
        if (!_email.contains("@")) {
          _authHint =
              "There is no user record corresponding to this identifier. The user may have been deleted.";
        } else {
          _authHint = e.details.toString();
        }
        setState(() {
          duration();

          loading = false;
        });
        print(e);
      }
    } else {
      setState(() {
        _authHint = '';
        loading = false;
      });
    }
  }

  void saveUserData() async {
    User user = new User(_email, uid, _username, widget.messagingToken, "",
        true, true, 0, 0, false, null, "EURO", 1.5, null,
        notifications: 0);
    firestoreInstance.document("usernames/$uid").setData({
      "name": _username,
      "email": _email,
    });
    DocumentReference docRef = firestoreInstance.document("users/$uid");
    await docRef.setData(user.toJson());
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = '';
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
    });
  }

  void moveToForgotPassword() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.forgotPassword;
      _authHint = '';
    });
  }

  sendResetEmail() {
    try {
      if (_formType == FormType.forgotPassword) {
        widget.auth.resetPassword(_resetEmail);
        setState(() {
          _authHint = "Check your email";
          duration();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String getFinalUsername() {
    return finalUsername;
  }

  Future<bool> checkUsername() async {
    _username = myController.text.trim().toLowerCase();
    var isAvailable = false;
    QuerySnapshot qSnap = await firestoreInstance
        .collection("usernames")
        .where("name", isEqualTo: _username)
        .getDocuments();
       
      if (qSnap.documents.isEmpty) {
        isAvailable = true;
        setState(() {
          debugPrint("true");
          usernameAvailable = true;
          _authHint = "";
          validateAndSubmit();
          finalUsername = _username;
        });
      } else {
        setState(() {
          _authHint = "Username is taken";
          duration();
          loading = false;
          debugPrint("false");
          usernameAvailable = false;
        });
      }
   return isAvailable;
  }

  List<Widget> usernameAndPassword() {
    switch (_formType)  {
      case FormType.register:
        return [
          new ListTile(
            title: padded(
                child: new TextFormField(
              maxLength: 18,
              maxLengthEnforced: true,
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize18),
              key: new Key('username'),
              decoration: new InputDecoration(
                  // counterStyle:TextStyle(color: Colors.grey) ,
                  border: OutlineInputBorder(),
                  labelText: 'Username (maximum 18 characters)',
                  fillColor: UIData.white,
                  labelStyle: new TextStyle(
                      color: Colors.grey[600], fontSize: UIData.fontSize16)),
              autocorrect: false,
              // focusNode: _focus,
              validator: (val) {
                // bool isAvailable = await checkUsername();
                if (val.isEmpty) {
                  return "Username can't be empty";
                }
                if (val.length > 18) {
                  return "Username is too long";
                } else if (val.contains("@")) {
                  return "Username can't contain @";
                } else {
                  return null;
                }
              },
              // val.isEmpty ? "Username can't be empty" : null,
              onSaved: (val) => _username = val.trim().toLowerCase(),
              controller: myController,
            )),
          ),
          new ListTile(
            title: padded(
                child: new TextFormField(
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize18),
              key: new Key('email'),
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  fillColor: UIData.white,
                  labelStyle: new TextStyle(
                      color: Colors.grey[600], fontSize: UIData.fontSize16)),
              autocorrect: false,
              validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
              onSaved: (val) => _email = val.trim().toLowerCase(),
            )),
          ),
          new ListTile(
            title: padded(
                child: new TextFormField(
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize18),
              key: new Key('password'),
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password (8+ characters)',
                  fillColor: UIData.white,
                  labelStyle: new TextStyle(
                      color: Colors.grey[600], fontSize: UIData.fontSize16)),
              obscureText: passwordVisible,
              autocorrect: false,
              validator: (val) {
                if (val.isEmpty) {
                  return 'Password can\'t be empty.';
                }
                if (val.length < 8) {
                  return "Password is too short";
                } else {
                  return null;
                }
              },
              onSaved: (val) => _password = val,
            )),
            trailing: new IconButton(
              icon: new Icon(
                passwordVisibleIcon,
                color: UIData.blackOrWhite,
              ),
              onPressed: () {
                if (passwordVisible == false) {
                  setState(() {
                    passwordVisible = true;
                    passwordVisibleIcon = Icons.visibility_off;
                  });
                } else {
                  setState(() {
                    passwordVisible = false;
                    passwordVisibleIcon = Icons.visibility;
                  });
                }
              },
            ),
          ),
          ListTile(
            title: new Text(
              "By clicking Create an account you agree to our Terms.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            subtitle: new FlatButton(
                child: new Text(
                  "Terms, Policies And Agreements",
                  style: TextStyle(color: UIData.blackOrWhite),
                ),
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TermsAndConditions()),
                    )),
          ),
        ];
      case FormType.login:
        return [
          new ListTile(
            title: padded(
                child: new TextFormField(
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize18),
              key: new Key('email'),
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email / Username',
                  labelStyle: new TextStyle(color: Colors.grey[600])),
              autocorrect: false,
              validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
              onSaved: (val) => _email = val.trim().toLowerCase(),
            )),
          ),
          new ListTile(
            title: padded(
                child: new TextFormField(
              style: new TextStyle(
                  color: UIData.blackOrWhite, fontSize: UIData.fontSize18),
              key: new Key('password'),
              decoration: new InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  labelStyle: new TextStyle(color: Colors.grey[600])),
              obscureText: true,
              autocorrect: false,
              validator: (val) =>
                  val.isEmpty ? 'Password can\'t be empty.' : null,
              onSaved: (val) => _password = val,
            )),
          ),
        ];
      case FormType.forgotPassword:
        return [
          new ListTile(
            title: padded(
                child: new TextField(
                    style: new TextStyle(
                        color: UIData.blackOrWhite,
                        fontSize: UIData.fontSize18),
                    key: new Key('typelostpassword'),
                    decoration: new InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your email',
                        fillColor: UIData.white,
                        labelStyle: new TextStyle(color: Colors.grey[600])),
                    autocorrect: false,
                    onChanged: (String str) {
                      _resetEmail = str;
                    })),
          ),
        ];
    }
  }

  List<Widget> submitWidgets() {
    switch (_formType) {
      case FormType.login:
        return [
          Padding(
            padding: EdgeInsets.only(top: 8),
          ),
          new PrimaryButton(
              key: new Key('login'),
              text: 'Login',
              color: UIData.yellow,
              onPressed: () {
                setState(() {
                  loading = true;
                });
                validateAndSubmit();
              }),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          ),
          new FlatButton(
            key: new Key('register'),
            child: new Text("Dont have an account? Register",
                style: new TextStyle(color: UIData.blackOrWhite)),
            onPressed: moveToRegister,
          ),
          new FlatButton(
            key: new Key('resetpassword'),
            child: new Text("Forgot password?",
                style: new TextStyle(color: UIData.blackOrWhite)),
            onPressed: moveToForgotPassword,
          ),
        ];
      case FormType.register:
        return [
          new PrimaryButton(
            key: new Key('createaccount'),
            text: 'Create an account',
            color: UIData.yellow,
            onPressed: () {
              setState(() {
                loading = true;
              });
              checkUsername();
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          ),
          new FlatButton(
              key: new Key('need-login'),
              child: new Text(
                "Have an account? Login",
                style: new TextStyle(color: UIData.blackOrWhite),
              ),
              onPressed: moveToLogin),
        ];
      case FormType.forgotPassword:
        return [
          Padding(
            padding: EdgeInsets.only(top: 8),
          ),
          new PrimaryButton(
            key: new Key('reset'),
            text: 'Reset password',
            color: UIData.yellow,
            onPressed: sendResetEmail,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          ),
          new FlatButton(
              key: new Key('movetologin'),
              child: new Text(
                "Move to login",
                style: new TextStyle(color: UIData.blackOrWhite),
              ),
              onPressed: moveToLogin),
        ];
    }
    return null;
  }

  Widget hintText() {
    return new Container(
        //height: 80.0,
        // padding: const EdgeInsets.all(32.0),
        child: new Text(_authHint,
            key: new Key('hint'),
            style: new TextStyle(fontSize: 18.0, color: Colors.grey[600]),
            textAlign: TextAlign.center));
  }

  Widget material() {
    return new SingleChildScrollView(
        child: new Container(
            child: new Column(children: [
      new Container(
          color: UIData.darkest,
          child: new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            new Container(
                padding: const EdgeInsets.all(16.0),
                child: new Form(
                    key: formKey,
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: usernameAndPassword() +
                          [hintText()] +
                          submitWidgets(),
                    ))),
          ])),
    ])));
  }

  Widget circular() {
    if (loading == true) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new Text("");
    }
  }

  Widget padded({Widget child}) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }
}
