
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/equipment_model.dart';
import '../../../data/models/reservation_model.dart';
import '../../../data/models/users_model.dart';
import '../../equipments/controllers/equipments_controller.dart';
import '../../users/controllers/users_controller.dart';
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
  UserModel? _selectedUser;
  Equipment? _selectedEquipment;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    final date = DateTime.parse(widget.reservation.date);
    _dateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(date));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersNotifierProvider.notifier).fetchUsers(refresh: true);
      ref.read(equipmentsNotifierProvider.notifier).fetchEquipments(refresh: true);
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = Reservation(
        id: widget.reservation.id,
        user: _selectedUser?.name ?? widget.reservation.user,
        equipment: _selectedEquipment?.type ?? widget.reservation.equipment,
        date: _dateController.text,
      );

      final notifier = ref.read(reservationsNotifierProvider.notifier);
      await notifier.updateReservation(updated);

      final stateAfter = ref.read(reservationsNotifierProvider);
      final hadError = stateAfter.maybeWhen(error: (_, __) => true, orElse: () => false);

      if (!hadError && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersNotifierProvider);
    final equipsState = ref.watch(equipmentsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
                  usersState.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => const Text('Erro ao carregar usuários'),
                    data: (list) {
                      _selectedUser ??= list.firstWhere(
                            (u) => u.name == widget.reservation.user,
                        orElse: () => list.first,
                      );
                      return DropdownButtonFormField<int>(
                        value: _selectedUser?.id,
                        decoration: const InputDecoration(labelText: 'Usuário'),
                        items: list.map((user) {
                          return DropdownMenuItem<int>(
                            value: user.id,
                            child: Text(user.name),
                          );
                        }).toList(),
                        onChanged: (int? selectedId) {
                          setState(() {
                            _selectedUser = list.firstWhere((user) => user.id == selectedId);
                          });
                        },
                      );
                    },
                  ),
              const SizedBox(height: 16),
              equipsState.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => const Text('Erro ao carregar equipamentos'),
                data: (list) {
                  // Inicializa o equipamento selecionado, buscando pelo id
                  _selectedEquipment ??= list.firstWhere(
                        (e) => e.type == widget.reservation.equipment,
                    orElse: () => list.first,
                  );

                  return DropdownButtonFormField<int>(
                    value: _selectedEquipment?.id,  // Usando o id para o value
                    items: list.map((e) {
                      return DropdownMenuItem<int>(
                        value: e.id,  // Usando o id do equipamento como valor
                        child: Text(e.type),
                      );
                    }).toList(),
                    onChanged: (int? selectedId) {
                      // Atualiza o equipamento selecionado com base no id
                      setState(() {
                        _selectedEquipment = list.firstWhere((e) => e.id == selectedId);
                      });
                    },
                    validator: (v) => v == null ? 'Selecione um equipamento' : null,
                    decoration: const InputDecoration(labelText: 'Equipamento'),
                  );
                },
              ),
              const SizedBox(height: 16),
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