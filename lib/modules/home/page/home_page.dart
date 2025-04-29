import 'package:flutter/material.dart';
import 'package:reservation_equipments/modules/equipments/page/equipments_list_page.dart';
import 'landing_page_content.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserva de Equipamentos'),
        actions: [
          IconButton(
            icon: Icon(Icons.devices),
            tooltip: 'Ver Equipamentos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EquipmentsListPage()),
              );
            },
          ),
        ],
      ),
      body: LandingPageContent(),
    );
  }
}
