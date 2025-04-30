import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/reservation_model.dart';
import '../../equipments/controllers/equipments_controller.dart';

/// StateNotifier para gerenciar a lista de reservas e operações de CRUD.
class ReservationsNotifier extends StateNotifier<AsyncValue<List<Reservation>>> {
  final ApiService _apiService;
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  ReservationsNotifier(this._apiService) : super(const AsyncValue.loading()) {
    fetchReservations();
  }

  /// Busca reservas com paginação. Se [refresh] for true, reinicia a lista.
  Future<void> fetchReservations({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      state = const AsyncValue.loading();
    }
    if (!_hasMore) return;

    state = state.whenData((current) => current);
    try {
      final list = await _apiService.fetchReservations(page: _page, limit: _limit);
      if (refresh) {
        state = AsyncValue.data(list);
      } else {
        final current = state.value ?? <Reservation>[];
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

  /// Cria uma nova reserva e adiciona ao topo da lista.
  Future<void> addReservation(Reservation reservation) async {
    try {
      final newReservation = await _apiService.createReservation(reservation);
      final current = state.value ?? [];
      state = AsyncValue.data([newReservation, ...current]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createReservationWithPayload(Map<String, dynamic> payload) async {
    try {
      final newRes = await _apiService.createReservationWithPayload(payload);
      final current = state.value ?? [];
      state = AsyncValue.data([newRes, ...current]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }


  /// Atualiza uma reserva existente.
  Future<void> updateReservation(Reservation reservation) async {
    try {
      final updated = await _apiService.updateReservation(reservation);
      final list = state.value;
      if (list != null) {
        state = AsyncValue.data(
          list.map((r) => r.id == updated.id ? updated : r).toList(),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Deleta uma reserva e remove da lista.
  Future<void> deleteReservation(int id) async {
    try {
      await _apiService.deleteReservation(id);
      final list = state.value;
      if (list != null) {
        state = AsyncValue.data(list.where((r) => r.id != id).toList());
      }
    } catch (e, st) {
    }
  }

}
final reservationsNotifierProvider = StateNotifierProvider<ReservationsNotifier, AsyncValue<List<Reservation>>>(
      (ref) {
    final api = ref.read(apiServiceProvider);
    return ReservationsNotifier(api);
  },
);
