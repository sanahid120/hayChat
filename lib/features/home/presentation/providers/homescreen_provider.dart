import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomescreenProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> _conversations = [];
  List<QueryDocumentSnapshot> _filteredConversations = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _subscription;
  String _searchQuery = '';

  List<QueryDocumentSnapshot> get conversations => 
      _searchQuery.isEmpty ? _conversations : _filteredConversations;
  
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
        _applySearch();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        _conversations = [];
        _filteredConversations = [];
        notifyListeners();
      },
    );
  }

  void searchConversations(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredConversations = [];
    } else {
      _filteredConversations = _conversations.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final otherUserName = (data['otherUserName'] ?? '').toString().toLowerCase();
        final lastMessage = (data['lastMessage'] ?? '').toString().toLowerCase();
        return otherUserName.contains(_searchQuery) || lastMessage.contains(_searchQuery);
      }).toList();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
