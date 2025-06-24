import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/equipments_controller.dart';

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
      backgroundColor: const Color(0xFFF2F6FF),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: state.when(
              data: (equipments) {
                if (equipments.isEmpty) {
                  return const Center(child: Text('Nenhum equipamento encontrado.'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: equipments.length,
                  itemBuilder: (context, index) {
                    final eq = equipments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x11000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          radius: 30,
                          child: Icon(Icons.devices, color: Colors.green.shade800, size: 28),
                        ),
                        title: Text(
                          eq.model,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('Marca: ${eq.brand}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () => context.pushNamed('equipment_edit', extra: eq),
                              child: const Icon(Icons.edit, color: Colors.indigo),
                            ),
                            GestureDetector(
                              onTap: () async {
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
                              child: const Icon(Icons.delete_outline, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erro: $err')),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _BottomBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF3A3EDD),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.go('/'),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              const Text(
                'Equipamentos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Visualize, edite e exclua os equipamentos',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _BottomBar(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3EDD),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.list_alt_outlined, color: Colors.white),
            onPressed: () {},
          ),
          FloatingActionButton(
            onPressed: () => context.pushNamed('equipment_create'),
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, color: Color(0xFF3A3EDD)),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
