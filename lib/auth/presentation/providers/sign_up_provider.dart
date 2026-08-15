import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpProvider extends ChangeNotifier {
  bool _signUpInProgress = false;
  String? _errorMessage;
  UserModel? _user;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get signUpInProgress => _signUpInProgress;

  Future<bool> signUp(UserModel user) async {
    _errorMessage = null;
    bool isSuccess = false;
    _signUpInProgress = true;
    notifyListeners();

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: user.email,
        password: user.password!,
      );
      
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': user.name,
          'email': user.email,
          'profilePicture': user.profilePicture,
        });
        
        _user = user;
        isSuccess = true;
      }

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'This email is already registered.';
          break;
        case 'invalid-email':
          _errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          _errorMessage = 'The password is too weak.';
          break;
        default:
          _errorMessage = e.message ?? 'An unexpected error occurred.';
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

    _signUpInProgress = false;
    notifyListeners();
    return isSuccess;
  }
}
