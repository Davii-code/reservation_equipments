import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/equipment_model.dart';
import '../controllers/equipments_controller.dart';

/// Página de criação de novo equipamento.
class EquipmentCreatePage extends ConsumerStatefulWidget {
  const EquipmentCreatePage({Key? key}) : super(key: key);

  @override
  ConsumerState<EquipmentCreatePage> createState() => _EquipmentCreatePageState();
}

class _EquipmentCreatePageState extends ConsumerState<EquipmentCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heritageCodeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  EquipmentState _state = EquipmentState.USABLE;

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
      final newEquipment = Equipment(
        heritageCode: _heritageCodeController.text,
        brand: _brandController.text,
        model: _modelController.text,
        type: _typeController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        state: _state,
      );

      await ref.read(equipmentsNotifierProvider.notifier).addEquipment(newEquipment);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Equipamento')),
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
                    .map(
                      (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.name),
                  ),
                )
                    .toList(),
                onChanged: (v) => setState(() {
                  if (v != null) _state = v;
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
