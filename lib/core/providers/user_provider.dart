import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../repository/user_repository.dart';
import '../storage/local_storage_service.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel>(() {
  return UserNotifier();
});

class UserNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() async {
    final repo = ref.watch(userRepositoryProvider);
    
    // Fetch initial user from repo (backend source of truth)
    UserModel user = await repo.getCurrentUser();
    
    return user;
  }

  Future<void> deductPoints(int points) async {
    final currentState = state.value;
    if (currentState == null) return;
    
    if (currentState.points < points) return;
    
    final newPoints = currentState.points - points;
    
    // Persist locally
    await ref.read(localStorageProvider).setUserPoints(newPoints);
    
    // Update state
    state = AsyncData(currentState.copyWith(points: newPoints));
  }
  
  Future<void> addPoints(int points) async {
    final currentState = state.value;
    if (currentState == null) return;
    
    final newPoints = currentState.points + points;
    
    // Persist locally
    await ref.read(localStorageProvider).setUserPoints(newPoints);
    
    // Update state
    state = AsyncData(currentState.copyWith(points: newPoints));
  }
}
