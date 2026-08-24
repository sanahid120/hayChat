import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../auth/presentation/models/conversation_summary.dart';
import '../../../../auth/repository/chat_repository.dart';

class HomescreenProvider extends ChangeNotifier {
  HomescreenProvider({
    required ChatRepository repository,
  }) : _repository = repository;

  final ChatRepository _repository;

  StreamSubscription<List<ConversationSummary>>? _subscription;

  List<ConversationSummary> _allConversations = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _listeningUserId;
  bool _disposed = false;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;

  List<ConversationSummary> get conversations {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return List.unmodifiable(_allConversations);
    }

    return List.unmodifiable(
      _allConversations.where((conversation) {
        final name = conversation.otherUserName.toLowerCase();
        final email = conversation.otherUserEmail.toLowerCase();
        final message = conversation.lastMessage.toLowerCase();

        return name.contains(query) ||
            email.contains(query) ||
            message.contains(query);
      }),
    );
  }

  void listenToConversations(String currentUserId) {
    if (currentUserId.isEmpty) {
      _isLoading = false;
      _errorMessage = 'User is not authenticated.';
      _safeNotify();
      return;
    }

    // Prevent multiple listeners for the same user.
    if (_listeningUserId == currentUserId &&
        _subscription != null) {
      return;
    }

    _subscription?.cancel();

    _listeningUserId = currentUserId;
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();

    _subscription = _repository
        .watchConversations(currentUserId)
        .listen(
          (conversations) {
        _allConversations = conversations;
        _isLoading = false;
        _errorMessage = null;
        _safeNotify();
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'Conversation listener error: $error\n$stackTrace',
        );

        _allConversations = [];
        _isLoading = false;
        _errorMessage = 'Unable to load conversations.';
        _safeNotify();
      },
    );
  }

  void searchConversations(String query) {
    _searchQuery = query.trim();
    _safeNotify();
  }

  Future<void> stopListening() async {
    await _subscription?.cancel();

    _subscription = null;
    _listeningUserId = null;
    _searchQuery = '';
    _allConversations = [];
    _errorMessage = null;
    _isLoading = false;

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
    _subscription?.cancel();
    super.dispose();
  }
}