// lib/core/routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models/equipment_model.dart';
import '../modules/equipments/page/equipment_create_page.dart';
import '../modules/equipments/page/equipment_edit_page.dart';
import '../modules/equipments/page/equipments_list_page.dart';
/// Configuração de rotas usando GoRouter.
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
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
        // Recebe o Equipment via extra ao navegar
        final equipment = state.extra as Equipment;
        return EquipmentEditPage(equipment: equipment);
      },
    ),
  ],
);