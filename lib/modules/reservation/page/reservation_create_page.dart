import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reservation_equipments/data/models/equipment_model.dart';
import 'package:reservation_equipments/data/models/users_model.dart';
import '../../../data/models/reservation_model.dart';
import '../../equipments/controllers/equipments_controller.dart';
import '../../users/controllers/users_controller.dart';
import '../controllers/reservation_controller.dart';

class ReservationCreatePage extends ConsumerStatefulWidget {
  const ReservationCreatePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReservationCreatePage> createState() => _ReservationCreatePageState();
}

class _ReservationCreatePageState extends ConsumerState<ReservationCreatePage> {
  final _formKey = GlobalKey<FormState>();

  UserModel? _selectedUser;
  Equipment? _selectedEquipment;
  int? _quantity;
  DateTime? _startDate;
  DateTime? _endDate;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersNotifierProvider.notifier).fetchUsers(refresh: true);
      ref.read(equipmentsNotifierProvider.notifier).fetchEquipments(refresh: true);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final payload = {
      "typeEquipment": _selectedEquipment!.type,
      "quantity": _quantity!,
      "startDate": _startDate!.toIso8601String(),
      "endDate": _endDate!.toIso8601String(),
      "userId": _selectedUser!.id,
      "notes": _notesController.text,
    };

    final notifier = ref.read(reservationsNotifierProvider.notifier);
    await notifier.createReservationWithPayload(payload);

    final stateAfter = ref.read(reservationsNotifierProvider);
    final hadError = stateAfter.maybeWhen(error: (_, __) => true, orElse: () => false);
    if (!hadError && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersNotifierProvider);
    final equipsState = ref.watch(equipmentsNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        title: const Text('Nova Reserva'),
        backgroundColor: const Color(0xFF3A3EDD),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preencha os dados para reservar',
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
                      data: (list) => DropdownButtonFormField<UserModel>(
                        value: _selectedUser,
                        items: list
                            .map((u) => DropdownMenuItem(value: u, child: Text(u.name)))
                            .toList(),
                        onChanged: (u) => setState(() => _selectedUser = u),
                        validator: (v) => v == null ? 'Selecione um usuário' : null,
                        decoration: const InputDecoration(labelText: 'Usuário'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    equipsState.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => const Text('Erro ao carregar equipamentos'),
                      data: (list) => DropdownButtonFormField<Equipment>(
                        value: _selectedEquipment,
                        items: list
                            .map((e) => DropdownMenuItem(value: e, child: Text(e.type)))
                            .toList(),
                        onChanged: (e) => setState(() => _selectedEquipment = e),
                        validator: (v) => v == null ? 'Selecione um equipamento' : null,
                        decoration: const InputDecoration(labelText: 'Equipamento'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantidade'),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Quantidade inválida';
                        return null;
                      },
                      onChanged: (v) => _quantity = int.tryParse(v),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => _pickDate(
                        initial: DateTime.now(),
                        onPicked: (d) => setState(() => _startDate = d),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(
                        _startDate == null
                            ? 'Selecionar Data de Início'
                            : 'Início: ${DateFormat('dd/MM/yyyy').format(_startDate!)}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _pickDate(
                        initial: _startDate ?? DateTime.now(),
                        onPicked: (d) => setState(() => _endDate = d),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(
                        _endDate == null
                            ? 'Selecionar Data de Término'
                            : 'Término: ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Notas'),
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
              child: const Text('Salvar Reserva'),
            ),
          ],
        ),
      ),
    );
  }
}
