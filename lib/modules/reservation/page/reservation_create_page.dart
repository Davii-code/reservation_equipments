import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/reservation_model.dart';
import '../controllers/reservation_controller.dart';

class ReservationCreatePage extends ConsumerStatefulWidget {
  const ReservationCreatePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReservationCreatePage> createState() => _ReservationCreatePageState();
}

class _ReservationCreatePageState extends ConsumerState<ReservationCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _userController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false && _selectedDate != null) {
      final newReservation = Reservation(
        id: 0, // ou -1 se o ID for gerado no backend
        user: _userController.text,
        equipment: _equipmentController.text,
        date: DateFormat('dd/MM/yyyy').format(_selectedDate!),
      );

      await ref.read(reservationsNotifierProvider.notifier).addReservation(newReservation);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'Nome do Usuário'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(labelText: 'Nome do Equipamento'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Text(_selectedDate == null
                    ? 'Selecionar Data da Reserva'
                    : 'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Salvar Reserva'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
