import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reservation_equipments/data/models/users_model.dart';
import '../controllers/users_controller.dart';

class UserCreatePage extends ConsumerStatefulWidget {
  const UserCreatePage({Key? key}) : super(key: key);

  @override
  ConsumerState<UserCreatePage> createState() => _UserCreatePageState();
}

class _UserCreatePageState extends ConsumerState<UserCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _registrationCodeController = TextEditingController();
  bool _active = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _registrationCodeController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = UserModel(
        login: _loginController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        name: _nameController.text,
        email: _emailController.text,
        registrationCode: _registrationCodeController.text,
        active: _active,
      );

      final notifier = ref.read(usersNotifierProvider.notifier);
      await notifier.addUser(user);

      final stateAfter = ref.read(usersNotifierProvider);
      final hadError = stateAfter.maybeWhen(error: (_, __) => true, orElse: () => false);
      if (!hadError && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(title: const Text('Criar Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(labelText: 'Login'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
                validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar Senha'),
                validator: (v) => v != _passwordController.text ? 'Senhas não conferem' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                v != null && !RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(v)
                    ? 'Email inválido'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _registrationCodeController,
                decoration: const InputDecoration(labelText: 'Código de Registro'),
                validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Usuário Ativo'),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Salvar Usuário'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
