import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/search_user_model.dart';
import '../repository/search_repository.dart';

final searchRepositoryProvider = Provider((ref) => SearchRepository());

// Enum for clear UI state tracking
enum SearchStatus { initial, loading, success, empty, error }

class SearchState {
  final SearchStatus status;
  final String query;
  final List<SearchUserModel> results;
  final List<SearchUserModel> suggestedUsers;
  final String? error;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results = const [],
    this.suggestedUsers = const [],
    this.error,
  });

  // Convenience getters for backward compat
  bool get isLoading => status == SearchStatus.loading;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<SearchUserModel>? results,
    List<SearchUserModel>? suggestedUsers,
    String? error,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      suggestedUsers: suggestedUsers ?? this.suggestedUsers,
      error: error,
    );
  }

  @override
  String toString() => 'SearchState(status=$status, query="$query", results=${results.length}, suggestions=${suggestedUsers.length}, error=$error)';
}

class SearchController extends StateNotifier<SearchState> {
  final SearchRepository _repository;
  Timer? _debounceTimer;

  SearchController(this._repository) : super(const SearchState()) {
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    try {
      final suggestions = await _repository.getSuggestedUsers();
      if (mounted) {
        state = state.copyWith(suggestedUsers: suggestions);
      }
    } catch (e) {
      print('[SEARCH] Failed to fetch suggestions: $e');
    }
  }

  void onQueryChanged(String query) {
    print('[SEARCH] onQueryChanged: "$query"');

    // Cancel any pending debounce
    _debounceTimer?.cancel();

    if (query.trim().length < 2) {
      print('[SEARCH] Query too short, resetting to initial state');
      state = state.copyWith(
        status: SearchStatus.initial,
        query: query,
        // We keep results so it doesn't flash empty if we type again quickly,
        // but the UI will show suggestedUsers when status is initial.
      );
      return;
    }

    // Update query immediately but keep current status and results visible (no flicker)
    state = state.copyWith(query: query);

    // Debounce the actual API call
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      print('[SEARCH] Debounce fired, calling _performSearch("$query")');
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    // Set loading but keep existing results (or suggestions) visible to avoid blank screen
    // We only clear the error.
    state = state.copyWith(status: SearchStatus.loading, error: null);
    print('[SEARCH] State -> loading. Current results: ${state.results.length}');

    try {
      print('[SEARCH] Calling repository.searchUsers("$query")...');
      final results = await _repository.searchUsers(query);
      print('[SEARCH] API returned ${results.length} results');

      // Only update if the query hasn't changed while waiting
      if (state.query == query) {
        if (results.isEmpty) {
          print('[SEARCH] State -> empty');
          state = state.copyWith(
            status: SearchStatus.empty,
            results: const [],
          );
        } else {
          print('[SEARCH] State -> success with ${results.length} users');
          state = state.copyWith(
            status: SearchStatus.success,
            results: results,
          );
        }
      } else {
        print('[SEARCH] Query changed during request, ignoring results');
      }
    } catch (e, st) {
      print('[SEARCH] ERROR: $e');
      print('[SEARCH] Stack: $st');
      if (state.query == query) {
        state = state.copyWith(
          status: SearchStatus.error,
          error: e.toString(),
        );
        print('[SEARCH] State -> error');
      }
    }
  }

  void retry() {
    if (state.query.trim().length >= 2) {
      _performSearch(state.query);
    }
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      final newStatus = await _repository.sendFriendRequest(targetUserId);
      
      // Update both results and suggestions if they contain the user
      final updatedResults = state.results.map((u) {
        if (u.id == targetUserId) {
          return SearchUserModel(
            id: u.id,
            fullName: u.fullName,
            username: u.username,
            profilePhoto: u.profilePhoto,
            points: u.points,
            streak: u.streak,
            friendStatus: newStatus,
          );
        }
        return u;
      }).toList();

      final updatedSuggestions = state.suggestedUsers.map((u) {
        if (u.id == targetUserId) {
          return SearchUserModel(
            id: u.id,
            fullName: u.fullName,
            username: u.username,
            profilePhoto: u.profilePhoto,
            points: u.points,
            streak: u.streak,
            friendStatus: newStatus,
          );
        }
        return u;
      }).toList();

      state = state.copyWith(
        results: updatedResults,
        suggestedUsers: updatedSuggestions,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final searchControllerProvider = StateNotifierProvider<SearchController, SearchState>((ref) {
  return SearchController(ref.watch(searchRepositoryProvider));
});
