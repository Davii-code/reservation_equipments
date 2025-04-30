// lib/core/routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reservation_equipments/data/models/reservation_model.dart';
import 'package:reservation_equipments/data/models/users_model.dart';
import 'package:reservation_equipments/modules/home/page/home_page.dart';
import 'package:reservation_equipments/modules/reservation/page/reservation_create_page.dart';
import 'package:reservation_equipments/modules/reservation/page/reservation_edit_page.dart';
import 'package:reservation_equipments/modules/reservation/page/reservation_list_page.dart';
import 'package:reservation_equipments/modules/users/page/user_create_page.dart';
import 'package:reservation_equipments/modules/users/page/user_edit_page.dart';
import 'package:reservation_equipments/modules/users/page/user_list_page.dart';

import '../data/models/equipment_model.dart';
import '../modules/equipments/page/equipment_create_page.dart';
import '../modules/equipments/page/equipment_edit_page.dart';
import '../modules/equipments/page/equipments_list_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/equipments',
      name: 'equipments_list',
      builder: (context, state) => const EquipmentsListPage(),
    ),
    GoRoute(
      path: '/equipments/create',
      name: 'equipment_create',
      builder: (context, state) => const EquipmentCreatePage(),
    ),
    GoRoute(
      path: '/equipments/edit',
      name: 'equipment_edit',
      builder: (context, state) {
        final equipment = state.extra as Equipment;
        return EquipmentEditPage(equipment: equipment);
      },
    ),
    GoRoute(
      path: '/reservations',
      name: 'reservation_list',
      builder: (context, state) => const ReservationsListPage(),
    ),
    GoRoute(
      path: '/reservations/create',
      name: 'reservation_create',
      builder: (context, state) => const ReservationCreatePage(),
    ),
    GoRoute(
      path: '/reservations/edit',
      name: 'reservation_edit',
      builder: (context, state) {
        final reservation = state.extra as Reservation;
        return ReservationEditPage(reservation: reservation);
      },
    ),
    GoRoute(
      path: '/users',
      name: 'users_list',
      builder: (context, state) => const UsersListPage(),
    ),
    GoRoute(
      path: '/users/create',
      name: 'users_create',
      builder: (context, state) => const UserCreatePage(),
    ),
    GoRoute(
      path: '/users/edit',
      name: 'users_edit',
      builder: (context, state) {
        final user = state.extra as UserModel;
        return UserEditPage(user: user);
      },
    ),
  ],
);