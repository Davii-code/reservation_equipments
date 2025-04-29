import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';  // Certifique-se de importar o GoRouter

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: const Text('Equipamentos'),
              onTap: () {
                // Navegação com GoRouter
                context.push('/equipments');
              },
            ),
            ListTile(
              title: const Text('Reservas'),
              onTap: () {
                // Navegação para página de Reservas (criar esta página semelhante ao exemplo de EquipmentsListPage)
              },
            ),
            ListTile(
              title: const Text('Usuários'),
              onTap: () {
                // Navegação para página de Usuários (criar esta página semelhante ao exemplo de EquipmentsListPage)
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Página Inicial')),
    );
  }
}
