import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/equipment_model.dart';

/// Provider para instanciar o [ApiService].
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// StateNotifier para gerenciar lista de equipamentos e operações de CRUD.
class EquipmentsNotifier extends StateNotifier<AsyncValue<List<Equipment>>> {
  final ApiService _apiService;
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  EquipmentsNotifier(this._apiService) : super(const AsyncValue.loading()) {
    fetchEquipments();
  }

  /// Busca equipamentos com paginação. Se [refresh] for true, reinicia a lista.
  Future<void> fetchEquipments({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      state = const AsyncValue.loading();
    }
    if (!_hasMore) return;

    state = state.whenData((current) => current);
    try {
      final list = await _apiService.fetchEquipments(page: _page, limit: _limit);
      if (refresh) {
        state = AsyncValue.data(list);
      } else {
        final current = state.value ?? <Equipment>[];
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

  /// Cria um novo equipamento e adiciona ao topo da lista.
  Future<void> addEquipment(Equipment equipment) async {
    try {
      final newEq = await _apiService.createEquipment(equipment);
      final current = state.value ?? [];
      state = AsyncValue.data([newEq, ...current]);
    } catch (e, st) {
      // Tratar erro conforme necessidade
      state = AsyncValue.error(e, st);
    }
  }

  /// Atualiza equipamento existente.
  Future<void> updateEquipment(Equipment equipment) async {
    try {
      final updated = await _apiService.updateEquipment(equipment);
      final list = state.value;
      if (list != null) {
        state = AsyncValue.data(
          list.map((e) => e.id == updated.id ? updated : e).toList(),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Deleta equipamento e remove da lista.
  Future<void> deleteEquipment(int id) async {
    try {
      await _apiService.deleteEquipment(id);
      final list = state.value;
      if (list != null) {
        state = AsyncValue.data(list.where((e) => e.id != id).toList());
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider para acessar [EquipmentsNotifier] e o estado da lista.
final equipmentsNotifierProvider = StateNotifierProvider<EquipmentsNotifier, AsyncValue<List<Equipment>>>(
      (ref) {
    final api = ref.read(apiServiceProvider);
    return EquipmentsNotifier(api);
  },
);
