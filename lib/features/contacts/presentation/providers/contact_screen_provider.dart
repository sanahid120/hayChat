import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/models/user_model.dart';

import '../../../../auth/repository/chat_repository.dart';

class ContactScreenProvider extends ChangeNotifier {
  ContactScreenProvider({
    required ChatRepository repository,
    FirebaseAuth? auth,
  }) : _repository = repository,
       _auth = auth ?? FirebaseAuth.instance;

  final ChatRepository _repository;
  final FirebaseAuth _auth;

  Timer? _debounce;

  int _requestVersion = 0;
  bool _disposed = false;
  bool _isLoading = false;

  String _query = '';
  String? _error;
  List<UserModel> _searchResults = [];

  bool get isLoading => _isLoading;

  bool get isSearching => _query.isNotEmpty;

  String get query => _query;

  String? get error => _error;

  List<UserModel> get searchResults => List.unmodifiable(_searchResults);

  void updateSearchQuery(String value) {
    _query = value.trim();
    _debounce?.cancel();

    if (_query.isEmpty) {
      _requestVersion++;
      _isLoading = false;
      _error = null;
      _searchResults = [];
      _safeNotify();
      return;
    }

    _safeNotify();

    _debounce = Timer(const Duration(milliseconds: 450), () {
      searchEmail(_query);
    });
  }

  Future<void> searchEmail(String email) async {
    final currentUserId = _auth.currentUser?.uid;
    final normalizedEmail = email.trim();

    if (currentUserId == null || normalizedEmail.isEmpty) {
      return;
    }

    final currentRequest = ++_requestVersion;

    _query = normalizedEmail;
    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final results = await _repository.searchUsersByEmail(
        email: normalizedEmail,
        currentUserId: currentUserId,
      );

      if (currentRequest != _requestVersion) {
        return;
      }

      _searchResults = results;
      _error = null;
    } catch (error, stackTrace) {
      debugPrint('Contact search error: $error\n$stackTrace');

      if (currentRequest != _requestVersion) {
        return;
      }

      _searchResults = [];
      _error = 'Unable to search users.';
    } finally {
      if (currentRequest == _requestVersion) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  void clearSearch() {
    _debounce?.cancel();
    _requestVersion++;

    _query = '';
    _error = null;
    _isLoading = false;
    _searchResults = [];

    _safeNotify();
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
