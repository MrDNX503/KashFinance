import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // Para acceder a la clase Transaction

class AuthTabbedScreen extends StatelessWidget {
  final Future<void> Function(String name, String surname, String email, String password) onRegister;
  final Future<void> Function(String email, String password) onLogin;

  const AuthTabbedScreen({
    super.key,
    required this.onRegister,
    required this.onLogin,
  });


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0C2769),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0C2769),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Registro'),
              Tab(text: 'Login'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RegisterTab(onRegister: onRegister),
            _LoginTab(onLogin: onLogin),
          ],
        ),
      ),
    );
  }
}

class _RegisterTab extends StatefulWidget {
  final Future<void> Function(String, String, String, String) onRegister;
  const _RegisterTab({required this.onRegister});

  @override
  State<_RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<_RegisterTab> {
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Crear una cuenta',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Introduce tus datos para registrarte',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            _buildInput(_nameCtrl, 'Nombre', Icons.person),
            const SizedBox(height: 12),
            _buildInput(_surnameCtrl, 'Apellido', Icons.person_outline),
            const SizedBox(height: 12),
            _buildInput(_emailCtrl, 'Correo electrónico', Icons.email),
            const SizedBox(height: 12),
            _buildInput(_passCtrl, 'Contraseña', Icons.lock, obscure: true),
            const SizedBox(height: 16),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ElevatedButton(
              onPressed: () async {
                final name = _nameCtrl.text.trim();
                final surname = _surnameCtrl.text.trim();
                final email = _emailCtrl.text.trim();
                final pass = _passCtrl.text.trim();

                if ([name, surname, email, pass].any((s) => s.isEmpty)) {
                  setState(() => _error = 'Todos los campos son obligatorios');
                  return;
                }
                try {
                  await widget.onRegister(name, surname, email, pass);
                } catch (e) {
                  setState(() => _error = e.toString());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03678C),
                minimumSize: const Size.fromHeight(48),
                foregroundColor: Colors.white,
              ),
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _LoginTab extends StatefulWidget {
  final Future<void> Function(String, String) onLogin;
  const _LoginTab({required this.onLogin});

  @override
  State<_LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<_LoginTab> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.person, size: 80, color: Colors.white54),
          const SizedBox(height: 24),
          _buildInput(_emailCtrl, 'Correo electrónico', Icons.email),
          const SizedBox(height: 12),
          _buildInput(_passCtrl, 'Contraseña', Icons.lock, obscure: true),
          const SizedBox(height: 16),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ElevatedButton(
            onPressed: () async {
              final email = _emailCtrl.text.trim();
              final pass = _passCtrl.text.trim();

              if (email.isEmpty || pass.isEmpty) {
                setState(() => _error = 'Correo y contraseña son obligatorios');
                return;
              }
              try {
                await widget.onLogin(email, pass);
              } catch (e) {
                print('Error en login: $e');
                setState(() => _error = e.toString());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03678C),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Iniciar sesión'),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}