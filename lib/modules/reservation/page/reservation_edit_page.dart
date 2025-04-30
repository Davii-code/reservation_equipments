
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/reservation_model.dart';
import '../controllers/reservation_controller.dart';

/// Página de edição de uma reserva existente.
class ReservationEditPage extends ConsumerStatefulWidget {
  final Reservation reservation;
  const ReservationEditPage({Key? key, required this.reservation}) : super(key: key);

  @override
  ConsumerState<ReservationEditPage> createState() => _ReservationEditPageState();
}

class _ReservationEditPageState extends ConsumerState<ReservationEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userController;
  late TextEditingController _equipmentController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController(text: widget.reservation.user);
    _equipmentController = TextEditingController(text: widget.reservation.equipment);
    _dateController = TextEditingController(text: widget.reservation.date);
  }

  @override
  void dispose() {
    _userController.dispose();
    _equipmentController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = widget.reservation.copyWith(
        user: _userController.text,
        equipment: _equipmentController.text,
        date: _dateController.text,
      );

      // Dispara a atualização
      final notifier = ref.read(reservationsNotifierProvider.notifier);
      await notifier.updateReservation(updated);

      // Lê o estado após a atualização
      final stateAfter = ref.read(reservationsNotifierProvider);
      final hadError = stateAfter.maybeWhen(
        error: (_, __) => true,
        orElse: () => false,
      );

      // Só pop se não houve erro
      if (!hadError && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(labelText: 'Usuário'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(labelText: 'Equipamento'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Data'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on Reservation {
  Reservation copyWith({
    String? user,
    String? equipment,
    String? date,
  }) {
    return Reservation(
      id: id,
      user: user ?? this.user,
      equipment: equipment ?? this.equipment,
      date: date ?? this.date,
    );
  }
}
