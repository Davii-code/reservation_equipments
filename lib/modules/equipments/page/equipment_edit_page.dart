import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/equipment_model.dart';
import '../controllers/equipments_controller.dart';

class EquipmentEditPage extends ConsumerStatefulWidget {
  final Equipment equipment;
  const EquipmentEditPage({Key? key, required this.equipment}) : super(key: key);

  @override
  ConsumerState<EquipmentEditPage> createState() => _EquipmentEditPageState();
}

class _EquipmentEditPageState extends ConsumerState<EquipmentEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _heritageCodeController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _typeController;
  late TextEditingController _descriptionController;
  late EquipmentState _state;

  @override
  void initState() {
    super.initState();
    _heritageCodeController = TextEditingController(text: widget.equipment.heritageCode);
    _brandController = TextEditingController(text: widget.equipment.brand);
    _modelController = TextEditingController(text: widget.equipment.model);
    _typeController = TextEditingController(text: widget.equipment.type);
    _descriptionController = TextEditingController(text: widget.equipment.description ?? '');
    _state = widget.equipment.state;
  }

  @override
  void dispose() {
    _heritageCodeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = widget.equipment.copyWith(
        heritageCode: _heritageCodeController.text,
        brand: _brandController.text,
        model: _modelController.text,
        type: _typeController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        state: _state,
      );

      final notifier = ref.read(equipmentsNotifierProvider.notifier);
      await notifier.updateEquipment(updated);

      final stateAfter = ref.read(equipmentsNotifierProvider);
      final hadError = stateAfter.maybeWhen(
        error: (_, __) => true,
        orElse: () => false,
      );

      if (!hadError && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        title: const Text('Editar Equipamento'),
        backgroundColor: const Color(0xFF3A3EDD),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atualize os dados do equipamento',
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
                    TextFormField(
                      controller: _heritageCodeController,
                      decoration: const InputDecoration(labelText: 'Código de Patrimônio'),
                      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Marca'),
                      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Modelo'),
                      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<EquipmentState>(
                      decoration: const InputDecoration(labelText: 'Estado'),
                      value: _state,
                      items: EquipmentState.values
                          .map((e) => DropdownMenuItem(value: e, child: Text(e.displayName)))
                          .toList(),
                      onChanged: (v) => setState(() {
                        if (v != null) _state = v;
                      }),
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
