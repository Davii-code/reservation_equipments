import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes.dart';
import 'modules/home/page/home_page.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  runApp(
    ProviderScope(
      child: MyApp(), // ou seu widget raiz
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Reserva de Equipamentos',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router, // Aqui está o segredo
    );
  }
}
