import 'package:flutter/material.dart';
import 'package:reservation_equipments/modules/equipments/page/equipments_list_page.dart';
import 'package:reservation_equipments/modules/users/page/user_list_page.dart';
import '../../reservation/page/reservation_list_page.dart';
import 'landing_page_content.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserva de Equipamentos'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.devices),
              title: Text('Equipamentos'),
              onTap: () {
                Navigator.pop(context); // fecha o menu
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EquipmentsListPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Reservas'),
              onTap: () {
                Navigator.pop(context); // fecha o menu
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReservationsListPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Usuários'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersListPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: LandingPageContent(),
    );
  }
}
