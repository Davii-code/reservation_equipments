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
    // dispara fetch de usuários e equipamentos
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
    final hadError = stateAfter.maybeWhen(error: (_,__)=>true, orElse: ()=>false);
    if (!hadError && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersNotifierProvider);
    final equipsState = ref.watch(equipmentsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Criar Reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Usuário
              usersState.when(
                loading: () => const LinearProgressIndicator(),
                error: (e,_) => Text('Erro ao carregar usuários'),
                data: (list) => DropdownButtonFormField<UserModel>(
                  value: _selectedUser,
                  items: list.map((u) {
                    return DropdownMenuItem(
                      value: u,
                      child: Text(u.name),
                    );
                  }).toList(),
                  onChanged: (u) => setState(() => _selectedUser = u),
                  validator: (v) => v==null ? 'Selecione um usuário' : null,
                  decoration: const InputDecoration(labelText: 'Usuário'),
                ),
              ),

              const SizedBox(height: 16),

              // Equipamento
              equipsState.when(
                loading: () => const LinearProgressIndicator(),
                error: (e,_) => Text('Erro ao carregar equipamentos'),
                data: (list) => DropdownButtonFormField<Equipment>(
                  value: _selectedEquipment,
                  items: list.map((eq) {
                    return DropdownMenuItem(
                      value: eq,
                      child: Text(eq.type), // ou eq.name, como fizer sentido
                    );
                  }).toList(),
                  onChanged: (eq) => setState(() => _selectedEquipment = eq),
                  validator: (v) => v==null ? 'Selecione um equipamento' : null,
                  decoration: const InputDecoration(labelText: 'Equipamento'),
                ),
              ),

              const SizedBox(height: 16),

              // Quantidade
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Quantidade inválida';
                  return null;
                },
                onSaved: (v) => _quantity = int.parse(v!),
                onChanged: (v) => _quantity = int.tryParse(v),
              ),

              const SizedBox(height: 16),

              // Data de Início
              ElevatedButton(
                onPressed: () => _pickDate(
                  initial: DateTime.now(),
                  onPicked: (d) => setState(() => _startDate = d),
                ),
                child: Text(_startDate == null
                    ? 'Selecionar Data de Início'
                    : 'Início: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'),
              ),

              const SizedBox(height: 16),

              // Data de Término
              ElevatedButton(
                onPressed: () => _pickDate(
                  initial: _startDate ?? DateTime.now(),
                  onPicked: (d) => setState(() => _endDate = d),
                ),
                child: Text(_endDate == null
                    ? 'Selecionar Data de Término'
                    : 'Término: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'),
              ),

              const SizedBox(height: 16),

              // Notas
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas'),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Botão Salvar
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