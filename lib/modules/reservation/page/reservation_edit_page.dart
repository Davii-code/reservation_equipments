import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/equipment_model.dart';
import '../../../data/models/reservation_model.dart';
import '../../../data/models/users_model.dart';
import '../../equipments/controllers/equipments_controller.dart';
import '../../users/controllers/users_controller.dart';
import '../controllers/reservation_controller.dart';

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
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        title: const Text('Editar Reserva'),
        backgroundColor: const Color(0xFF3A3EDD),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atualize as informações da reserva',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
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
                        _selectedEquipment ??= list.firstWhere(
                              (e) => e.type == widget.reservation.equipment,
                          orElse: () => list.first,
                        );
                        return DropdownButtonFormField<int>(
                          value: _selectedEquipment?.id,
                          items: list.map((e) {
                            return DropdownMenuItem<int>(
                              value: e.id,
                              child: Text(e.type),
                            );
                          }).toList(),
                          onChanged: (int? selectedId) {
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
                      readOnly: true,
                      onTap: () async {
                        final currentDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: currentDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Data da Reserva'),
                      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFF3A3EDD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
