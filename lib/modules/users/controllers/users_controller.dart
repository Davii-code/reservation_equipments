import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reservation_equipments/data/models/users_model.dart';
import '../../../data/services/api_service.dart';
import '../../equipments/controllers/equipments_controller.dart'; // Crie esse model com base no UserRequestDTO

/// StateNotifier para gerenciar a lista de usuários e operações de CRUD.
class UsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final ApiService _apiService;
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  UsersNotifier(this._apiService) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      state = const AsyncValue.loading();
    }
    if (!_hasMore) return;

    state = state.whenData((current) => current);
    try {
      final list = await _apiService.fetchUsers(page: _page, limit: _limit);
      if (refresh) {
        state = AsyncValue.data(list);
      } else {
        final current = state.value ?? <UserModel>[];
        state = AsyncValue.data([...current, ...list]);
      }

      if (list.length < _limit) {
        _hasMore = false;
      } else {
        _page++;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Cria um novo usuário e adiciona ao topo da lista.
  Future<void> addUser(UserModel user) async {
    try {
      final newUser = await _apiService.createUser(user);
      final current = state.value ?? [];
      state = AsyncValue.data([newUser, ...current]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Atualiza um usuário existente.
  Future<void> updateUser(UserModel user) async {
    try {
      final updated = await _apiService.updateUser(user);
      final list = state.value;
      if (list != null) {
        state = AsyncValue.data(
          list.map((u) => u.id == updated.id ? updated : u).toList(),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _apiService.deleteUser(id);
      final list = state.value;
      if (list != null) {
        state = AsyncValue.data(
          list.where((u) => u.id != id).toList(),
        );
      }
    } catch (e, st) {
    }
  }

}


/// Provider do UsersNotifier
final usersNotifierProvider = StateNotifierProvider<UsersNotifier, AsyncValue<List<UserModel>>>(
      (ref) {
    final api = ref.read(apiServiceProvider);
    return UsersNotifier(api);
  },
);