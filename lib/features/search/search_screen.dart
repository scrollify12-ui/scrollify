import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/search_provider.dart';
import 'widgets/friend_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'models/search_user_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final show = _searchController.text.isNotEmpty;
      if (show != _showClear) {
        setState(() => _showClear = show);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    print('[SEARCH-UI] build() called. State: $searchState');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 38,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF262626),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12, width: 0.5),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.search, color: Colors.grey, size: 20),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  onChanged: (value) {
                    ref.read(searchControllerProvider.notifier).onQueryChanged(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by username...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (_showClear)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    ref.read(searchControllerProvider.notifier).onQueryChanged('');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.close, color: Colors.grey, size: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: _buildBody(searchState),
    );
  }

  Widget _buildBody(SearchState state) {
    switch (state.status) {
      case SearchStatus.initial:
        return _buildInitialState(state.suggestedUsers);

      case SearchStatus.loading:
        // If we are actively searching and have results to show, overlay a loading bar
        if (state.results.isNotEmpty) {
          return Column(
            children: [
              const LinearProgressIndicator(
                color: Color(0xFFF5C542),
                backgroundColor: Colors.transparent,
                minHeight: 2,
              ),
              Expanded(child: _buildResultsList(state.results)),
            ],
          );
        }
        // If we don't have results but we have suggestions (e.g. typing very first character),
        // let's show suggestions with a loading bar on top.
        if (state.suggestedUsers.isNotEmpty && state.query.length < 3) {
          return Column(
            children: [
              const LinearProgressIndicator(
                color: Color(0xFFF5C542),
                backgroundColor: Colors.transparent,
                minHeight: 2,
              ),
              Expanded(child: _buildInitialState(state.suggestedUsers)),
            ],
          );
        }
        
        // Otherwise, show skeleton loaders for fresh search
        return _buildLoadingState();

      case SearchStatus.success:
        return _buildResultsList(state.results);

      case SearchStatus.empty:
        return _buildEmptyState();

      case SearchStatus.error:
        return _buildErrorState(state.error ?? 'Unknown error');
    }
  }

  // ──────────────────────────────────────────────────────
  // STATE: Initial (no search yet)
  // ──────────────────────────────────────────────────────
  Widget _buildInitialState(List<SearchUserModel> suggestions) {
    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Colors.grey[700], size: 64),
            const SizedBox(height: 16),
            Text(
              'Search users by username',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Type at least 2 characters',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Suggested',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: _buildResultsList(suggestions),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────
  // STATE: Loading (shimmer-like placeholders)
  // ──────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Column(
      children: [
        const LinearProgressIndicator(
          color: Color(0xFFF5C542),
          backgroundColor: Colors.transparent,
          minHeight: 2,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildShimmerTile();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[850] ?? Colors.grey[900]!,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[850] ?? Colors.grey[900]!,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[850] ?? Colors.grey[900]!,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Button placeholder
          Container(
            height: 32,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey[850] ?? Colors.grey[900]!,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // STATE: Success (results list)
  // ──────────────────────────────────────────────────────
  Widget _buildResultsList(List<SearchUserModel> results) {
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(top: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          onTap: () {
            context.push('/user-profile', extra: user);
          },
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[800],
            backgroundImage: user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                ? CachedNetworkImageProvider(user.profilePhoto!)
                : null,
            child: user.profilePhoto == null || user.profilePhoto!.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          title: Text(
            user.username,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            user.fullName,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          trailing: FriendButton(
            targetUserId: user.id,
            initialStatus: user.friendStatus,
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────
  // STATE: Empty (no results)
  // ──────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, color: Colors.grey, size: 56),
          const SizedBox(height: 16),
          const Text(
            'No users found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try another username.',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────
  // STATE: Error
  // ──────────────────────────────────────────────────────
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              ref.read(searchControllerProvider.notifier).retry();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5C542),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Tap to retry',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
