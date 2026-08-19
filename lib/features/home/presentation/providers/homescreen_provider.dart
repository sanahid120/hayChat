import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomescreenProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _subscription;

  List<QueryDocumentSnapshot> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void listenToConversations(String currentUid) {
    if (currentUid.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;

    _subscription = FirebaseFirestore.instance
        .collection('conversation')
        .doc(currentUid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _conversations = snapshot.docs;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        _conversations = [];
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
