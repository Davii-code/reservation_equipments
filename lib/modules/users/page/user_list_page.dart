import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/users_controller.dart';

class UsersListPage extends ConsumerStatefulWidget {
  const UsersListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends ConsumerState<UsersListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final notifier = ref.read(usersNotifierProvider.notifier);
      final state = ref.watch(usersNotifierProvider);
      if (!state.isLoading &&
          notifier.hasListeners &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        notifier.fetchUsers();
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
    final state = ref.watch(usersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
      ),
      body: state.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado.'));
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Text('Email: ${user.email} \ Nome: ${user.name}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.pushNamed('users_edit', extra: user);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirmar remoção'),
                              content: const Text('Deseja realmente excluir este usuário?'),
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
                                .read(usersNotifierProvider.notifier)
                                .deleteUser(user.id!);
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
          context.pushNamed('users_create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
