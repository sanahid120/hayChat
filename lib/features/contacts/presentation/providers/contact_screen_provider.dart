import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/models/user_model.dart';

class ContactScreenProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;
  List<UserModel> _searchResults = [];
  UserModel? _userDetails;

  List<UserModel> get searchResults => _searchResults;
  UserModel? get userDetails => _userDetails;

  void searchEmail(String email) {
    final query = email.trim();
    if (query.isEmpty) {
      _isLoading = false;
      _searchResults = [];
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: query)
        .get()
        .then((querySnapshot) {
          final results = querySnapshot.docs
              .map((doc) => UserModel.fromJson(doc.data(), doc.id))
              .where(
                (user) => user.uid != FirebaseAuth.instance.currentUser?.uid,
              )
              .toList();

          _searchResults = results;
          _isLoading = false;
          notifyListeners();
        })
        .catchError((error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        });
  }

  void getUserById(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) {
          if (doc.exists) {
            final user = UserModel.fromJson(doc.data()!, doc.id);
            _userDetails = user;
          } else {
            _userDetails = null;
            _error = 'User not found';
          }
          _isLoading = false;
          notifyListeners();
        })
        .catchError((error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        });
  }
}
