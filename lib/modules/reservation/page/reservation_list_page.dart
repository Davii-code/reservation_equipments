import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/reservation_controller.dart';

/// Página de listagem de reservas com paginação e ações CRUD.
class ReservationsListPage extends ConsumerStatefulWidget {
  const ReservationsListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReservationsListPage> createState() => _ReservationsListPageState();
}

class _ReservationsListPageState extends ConsumerState<ReservationsListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final notifier = ref.read(reservationsNotifierProvider.notifier);
      final state = ref.watch(reservationsNotifierProvider);
      if (!state.isLoading &&
          notifier.hasListeners &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        notifier.fetchReservations();
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
    final state = ref.watch(reservationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
      ),
      body: state.when(
        data: (reservations) {
          if (reservations.isEmpty) {
            return const Center(child: Text('Nenhuma reserva encontrada.'));
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Reserva de ${reservation.equipmentName}'),
                  subtitle: Text('Usuário: ${reservation.userName}\n'
                      'Data: ${reservation.date}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.pushNamed('reservation_edit', extra: reservation);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirmar remoção'),
                              content: const Text('Deseja realmente excluir esta reserva?'),
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
                                .read(reservationsNotifierProvider.notifier)
                                .deleteReservation(reservation.id!);
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
        error: (err, _) => Center(child: Text('Erro: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('reservation_create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
