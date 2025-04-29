import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LandingPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Bem-vindo ao sistema de reserva!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Image.asset('assets/images/reservation.jpg', height: 200),
          SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.search, color: Colors.blue),
              title: Text('Navegue pelos equipamentos disponíveis'),
              subtitle: Text('Clique no botão de equipamento no canto superior.'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.green),
              title: Text('Faça suas reservas'),
              subtitle: Text('Escolha datas e horários para usar os equipamentos.'),
            ),
          ),
        ],
      ),
    );
  }
}
