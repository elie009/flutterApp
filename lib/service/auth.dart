import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/model/UserObj.dart';
import 'package:flutter_app/pages/authentication/SignInPage.dart';
import 'package:flutter_app/database/Database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on FirebaseUser
  UserBase _userFromFirebaseUser(User user) {
    return user != null ? UserBase.auth(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<UserBase> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in anonymously
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with smartphonoe
  Future signInWithSmartPhone(String verificationId, String smsCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      UserCredential result = await _auth.signInWithCredential(credential);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email & password
  Future registerWithEmailAndPassword(String email, String password,
      String provideFname, String provideLname) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;

      UserBase usrobj = new UserBase(user.uid, provideFname, '', provideLname,
          user.phoneNumber, 'PENDING', user.email);
      // create a new document for the user with uid
      await DatabaseService(uid: user.uid).updateUserData(usrobj);

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      SignInPage();
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
