import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reservation_equipments/data/models/users_model.dart';
import 'package:reservation_equipments/modules/equipments/controllers/equipments_controller.dart';
import '../controllers/users_controller.dart';

class UserEditPage extends ConsumerStatefulWidget {
  final UserModel user;
  const UserEditPage({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends ConsumerState<UserEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  late UserModel _fullUser;

  late TextEditingController _loginController;
  late TextEditingController _registrationCodeController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController();
    _registrationCodeController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();

    // Carrega o usuário completo (incluindo login e registrationCode)
    ref.read(apiServiceProvider)
        .fetchUserById(widget.user.id!)
        .then((u) {
      _fullUser = u;
      _loginController.text = u.login;
      _registrationCodeController.text = u.registrationCode;
      _nameController.text = u.name;
      _emailController.text = u.email;
      _active = u.active;
      setState(() => _loading = false);
    })
        .catchError((_) {
      // Se quiser, trate erro de fetch aqui
      setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _loginController.dispose();
    _registrationCodeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = _fullUser.copyWith(
        login: _loginController.text,
        registrationCode: _registrationCodeController.text,
        name: _nameController.text,
        email: _emailController.text,
        active: _active,
      );

      final notifier = ref.read(usersNotifierProvider.notifier);
      await notifier.updateUser(updated);

      // Só sai da tela se não houver erro
      final stateAfter = ref.read(usersNotifierProvider);
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
      appBar: AppBar(title: const Text('Editar Usuário')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(labelText: 'Login'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _registrationCodeController,
                decoration:
                const InputDecoration(labelText: 'Código de Registro'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Usuário Ativo'),
                value: _active,
                onChanged: (val) => setState(() => _active = val),
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

extension UserModelCopyWith on UserModel {
  UserModel copyWith({
    String? login,
    String? password,
    String? confirmPassword,
    String? name,
    String? email,
    String? registrationCode,
    bool? active,
  }) {
    final pwd = password ?? this.password;
    return UserModel(
      // O `id` não vai para o JSON, mas fica no objeto para a URL do PUT
      id: id,
      login: login ?? this.login,
      password: pwd,
      confirmPassword: confirmPassword ?? pwd,
      name: name ?? this.name,
      email: email ?? this.email,
      registrationCode: registrationCode ?? this.registrationCode,
      active: active ?? this.active,
    );
  }
}