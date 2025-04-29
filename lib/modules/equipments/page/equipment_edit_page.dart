import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/equipment_model.dart';
import '../controllers/equipments_controller.dart';

/// Página de edição de um equipamento existente.
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
    _descriptionController = TextEditingController(text: widget.equipment.description);
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

      await ref.read(equipmentsNotifierProvider.notifier).updateEquipment(updated);
      if (mounted) Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Equipamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _heritageCodeController,
                decoration: const InputDecoration(labelText: 'Código de Patrimônio'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Tipo'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              DropdownButtonFormField<EquipmentState>(
                decoration: const InputDecoration(labelText: 'Estado'),
                value: _state,
                items: EquipmentState.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => setState(() {
                  if (v != null) _state = v;
                }),
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

extension on Equipment {
  copyWith({required String heritageCode, required String brand, required String model, required String type, String? description, required EquipmentState state}) {}
}
