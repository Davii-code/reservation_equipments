import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reservation_equipments/data/models/auth_model.dart';
import '../../../data/services/api_service.dart';
import '../../equipments/controllers/equipments_controller.dart';

class LoginNotifier extends StateNotifier<AsyncValue<bool>> {
  final ApiService _apiService;

  LoginNotifier(this._apiService) : super(const AsyncValue.loading());

  Future<void> login(AuthDTO authDTO) async {
    try {
      await _apiService.login(authDTO);
      state = AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

}
final loginNotifierProvider = StateNotifierProvider<LoginNotifier, AsyncValue<void>>(
      (ref) {
    final api = ref.read(apiServiceProvider);
    return LoginNotifier(api);
  },
);
