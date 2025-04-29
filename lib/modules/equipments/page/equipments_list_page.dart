import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/equipments_controller.dart';

/// Página de listagem de equipamentos com paginação e ações CRUD.
class EquipmentsListPage extends ConsumerStatefulWidget {
  const EquipmentsListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<EquipmentsListPage> createState() => _EquipmentsListPageState();
}

class _EquipmentsListPageState extends ConsumerState<EquipmentsListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // O notifier faz fetch inicial automaticamente
    _scrollController.addListener(() {
      final notifier = ref.read(equipmentsNotifierProvider.notifier);
      final state = ref.watch(equipmentsNotifierProvider);
      if (!state.isLoading &&
          notifier.hasListeners &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        notifier.fetchEquipments();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(equipmentsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipamentos'),
      ),
      body: state.when(
        data: (equipments) {
          if (equipments.isEmpty) {
            return const Center(child: Text('Nenhum equipamento encontrado.'));
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: equipments.length,
            itemBuilder: (context, index) {
              final eq = equipments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(eq.model),
                  subtitle: Text(eq.brand),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.pushNamed('equipment_edit', extra: eq);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirmar remoção'),
                              content: const Text('Deseja realmente excluir este equipamento?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref
                                .read(equipmentsNotifierProvider.notifier)
                                .deleteEquipment(eq.id!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: \$err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('equipment_create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
