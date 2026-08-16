import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInProvider extends ChangeNotifier {
  bool _signInProgress = false;
  String? _errorMessage;
  UserModel? _user;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get signInProgress => _signInProgress;

  Future<bool> signIn(UserModel user) async {
    _errorMessage = null;
    bool isSuccess = false;
    _signInProgress = true;
    notifyListeners();


    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: user.email,
            password: user.password!,
          );
      if (userCredential.user != null) {
        isSuccess = true;

        String uid = userCredential.user!.uid;
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          UserModel userModel = UserModel.fromJson(userData);
          _user = userModel;
          if (kDebugMode) {
            print('User data: $userModel');
          }
        } else {
          _errorMessage = 'User data not found';
          if (kDebugMode) {
            print('User data not found');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      if (e.code == 'user-not-found') {
        _errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-credential') {
        _errorMessage = 'Invalid email or password.';
      } else if (e.code == 'user-disabled') {
        _errorMessage = 'This user has been disabled.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'The email address is badly formatted.';
      } else {
        _errorMessage = e.message ?? 'An authentication error occurred (${e.code}).';
      }
      if (kDebugMode) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('General Error: $e');
      }
    }

    _signInProgress = false;
    notifyListeners();
    return isSuccess;
  }
}
