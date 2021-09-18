import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/service/Auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inbox/MessagePage.dart';

class RegistrationPage extends StatefulWidget {
  final SharedPreferences prefs;
  RegistrationPage({this.prefs});
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  initState() {
    super.initState();
  }

  Future<void> verifyPhone() async {
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {});
    };
    print(this.phoneNo);
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo, // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent:
              smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (FirebaseAuthException e) {
            print('${e.message}');
          });
    } catch (e) {
      handleError(e);
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS Code'),
            content: Container(
              height: 85,
              child: Column(children: [
                TextField(
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                (errorMessage != ''
                    ? Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      )
                    : Container())
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Done'),
                onPressed: () {
                  signIn();
                  // _auth.currentUser().then((user) async {
                  // });
                },
              )
            ],
          );
        });
  }

  signIn() async {
    try {
      final UserCredential currentUser = await _auth.signInWithEmailAndPassword(
          email: 'new@gmail.com', password: '1234567890');
      assert(currentUser.user.uid == currentUser.user.uid);

      Navigator.of(context).pop();
      phoneNo = '+639950311066';
      DocumentReference mobileRef =
          DatabaseService().userCollection.doc('9uJd3K6rT3cEPmRb6G7xN6NBPCV2');

      await mobileRef.get().then((documentReference) {
        print(documentReference.exists);
        if (!documentReference.exists) {
          mobileRef.set({}).then((documentReference) async {
            await DatabaseService().userCollection.add({
              'name': "No Name",
              'mobile': phoneNo.replaceAll(new RegExp(r'[^\w\s]+'), ''),
              'profile_photo': "",
            }).then((documentReference) {
              widget.prefs.setBool('is_verified', true);
              widget.prefs.setString(
                'mobile',
                phoneNo.replaceAll(new RegExp(r'[^\w\s]+'), ''),
              );
              widget.prefs.setString('uid', documentReference.id);
              widget.prefs.setString('name', "No Name");
              widget.prefs.setString('profile_photo', "");

              mobileRef.set({'uid': documentReference.id}).then(
                  (documentReference) async {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => MessagePage(prefs: widget.prefs)));
              }).catchError((e) {
                print(e);
              });
            }).catchError((e) {
              print(e);
            });
          });
        } else {
          widget.prefs.setString('uid', documentReference["uid"]);
          widget.prefs.setString('name', documentReference["firstName"]);
          widget.prefs
              .setString('profile_photo', documentReference["lastName"]);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MessagePage(prefs: widget.prefs),
            ),
          );
        }
      }).catchError((e) {});
    } catch (e) {
      handleError(e);
    }
  }

  handleError(PlatformException error) {
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {});
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(hintText: '+910000000000'),
                onChanged: (value) {
                  this.phoneNo = value;
                },
              ),
            ),
            (errorMessage != ''
                ? Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  )
                : Container()),
            SizedBox(
              height: 10,
            ),
            RaisedButton(
              onPressed: () {
                signIn();
              },
              child: Text('Verify'),
              textColor: Colors.white,
              elevation: 7,
              color: Colors.blue,
            )
          ],
        ),
      ),
    );
  }
}
