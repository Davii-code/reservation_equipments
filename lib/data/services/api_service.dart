// lib/data/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reservation_equipments/data/models/auth_model.dart';
import 'package:reservation_equipments/data/models/users_model.dart';
import '../../core/constants.dart';
import '../models/equipment_model.dart';
import '../models/reservation_model.dart';

// importe a chave global do scaffold messenger
import '../../main.dart'; // ajuste o caminho conforme seu projeto

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      )) {
    // Interceptor para capturar erros e mostrar SnackBar
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioError err, handler) {
        final data = err.response?.data;
        if (data is Map && data['messages'] is List) {
          final msgs = (data['messages'] as List)
              .map((m) => m['message'] as String? ?? '')
              .where((m) => m.isNotEmpty)
              .join('\n');
          if (msgs.isNotEmpty) {
            scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(msgs),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
        // repassa o erro para ser tratado normalmente pelo caller
        return handler.next(err);
      },
    ));
  }

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

  Future<Reservation> createReservationWithPayload(Map<String, dynamic> payload) async {
    final response = await _dio.post(
      'reservation',
      data: payload,
    );
    return Reservation.fromJson(response.data);
  }

  Future<Reservation> fetchReservationById(int id) async {
    final response = await _dio.get('reservation/$id');
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

  Future<List<UserModel>> fetchUsers({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      'user',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data as List;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<UserModel> createUser(UserModel user) async {
    final response = await _dio.post(
      'user',
      data: user.toJson(),
    );
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateUser(UserModel user) async {
    final response = await _dio.put(
      'user/${user.id}',
      data: user.toJsonUpdate(),
    );
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> fetchUserById(int id) async {
    final response = await _dio.get('user/$id');
    return UserModel.fromJson(response.data);
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete('user/$id');
  }

  Future<void> login(AuthDTO authDTO) async {
    final response = await _dio.post(
      'auth/login',
      data: authDTO.toJson(),
    );

    if (response.statusCode == 200) {
      final String? token = response.data['accessToken'];
      await _secureStorage.write(key: 'jwt_token', value: token);
    }

    return;
  }

  Future<void> logout() async {
    final response = await _dio.get('auth/logout');
    if (response.statusCode == 200) {
      await _secureStorage.delete(key: 'jwt_token');
    }
  }

  Future<String?> getJwtToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }
}
