import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../models/equipment_model.dart';
import '../models/reservation_model.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ));

  Future<List<Equipment>> fetchEquipments({int page = 1, int limit = 20}) async {
    final uri = '${_dio.options.baseUrl}equipment?page=$page&limit=$limit';
    print('🔍 Fetching equipments from: $uri');
    final response = await _dio.get(
      'equipment',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data as List;
    return data.map((json) => Equipment.fromJson(json)).toList();
  }

  Future<Equipment> createEquipment(Equipment equipment) async {
    final response = await _dio.post(
      'equipment',
      data: equipment.toJson(),
    );
    return Equipment.fromJson(response.data);
  }

  Future<Equipment> updateEquipment(Equipment equipment) async {
    final response = await _dio.put(
      'equipment/${equipment.id}',
      data: equipment.toJson(),
    );
    return Equipment.fromJson(response.data);
  }

  Future<void> deleteEquipment(int id) async {
    await _dio.delete('equipment/$id');
  }

  Future<List<Reservation>> fetchReservations({int page = 1, int limit = 20}) async {
    final uri = '${_dio.options.baseUrl}reservation?page=$page&limit=$limit';
    print('🔍 Fetching reservations from: $uri');
    final response = await _dio.get(
      'reservation',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data as List;
    return data.map((json) => Reservation.fromJson(json)).toList();
  }

  Future<Reservation> createReservation(Reservation reservation) async {
    final response = await _dio.post(
      'reservation',
      data: reservation.toJson(),
    );
    return Reservation.fromJson(response.data);
  }

  Future<Reservation> updateReservation(Reservation reservation) async {
    final response = await _dio.put(
      'reservation/${reservation.id}',
      data: reservation.toJson(),
    );
    return Reservation.fromJson(response.data);
  }

  Future<void> deleteReservation(int id) async {
    await _dio.delete('reservation/$id');
  }
}
