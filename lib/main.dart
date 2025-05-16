import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import 'screens/balance_screen.dart';
import 'screens/registro_movimiento_form.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const KashFinanceApp());
}

// =======================
// MODELOS
// =======================

class User {
  final int? id;
  final String email;
  final String password;
  final String name;
  final String surname;

  User({this.id, required this.email, required this.password, required this.name, required this.surname});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'surname': surname,
    'email': email,
    'password': password,
  };

  factory User.fromMap(Map<String, dynamic> m) => User(
    id: m['id'] as int?,
    email: m['email'] as String,
    password: m['password'] as String,
    name: m['name'] as String,
    surname: m['surname'] as String,
  );
}

class TransactionModel {
  final int? id;
  final String type;
  final String category;
  final double amount;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'category': category,
    'amount': amount,
    'date'    : date.toIso8601String(),
  };

  factory TransactionModel.fromMap(Map<String, dynamic> m) =>
      TransactionModel(
        id: m['id'] as int?,
        type: m['type'] as String,
        category: m['category'] as String,
        amount: (m['amount'] as num).toDouble(),
        date: DateTime.parse(m['date'] as String),
      );
}

// =======================
// DBHelper (SQLite)
// =======================

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _db;
  DBHelper._();
  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_db != null) return _db!;

    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'kashfinance.db');
    _db = await openDatabase(
      path,
      version: 2,                // <-- Bump a la versión 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,     // <-- Definimos onUpgrade
    );
    return _db!;
  }

  Future _onCreate(Database db, int v) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL DEFAULT '',
        surname TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE users ADD COLUMN name TEXT NOT NULL DEFAULT ''");
      await db.execute("ALTER TABLE users ADD COLUMN surname TEXT NOT NULL DEFAULT ''");
    }
  }

  // Usuario
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'name': user.name,
        'surname': user.surname,
        'email': user.email,
        'password': user.password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }

  // Transacciones
  Future<int> insertTransaction(TransactionModel t) async {
    final db = await database;
    return db.insert('transactions', t.toMap());
  }

  Future<List<TransactionModel>> getTransactionsByMonth(
      String month) async {
    final db = await database;
    final maps = await db.query('transactions',
        where: "substr(date,1,7)=?", whereArgs: [month], orderBy: 'date DESC');
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }
}

// =======================
// APP PRINCIPAL
// =======================

class KashFinanceApp extends StatelessWidget {
  const KashFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DBHelper();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(builder: (ctx) {
        return AuthTabbedScreen(
          onRegister: (name, surname, email, password) async {
            final exists = await db.getUserByEmail(email);
            if (exists != null) throw 'El correo ya está registrado';

            await db.insertUser(User(
              name: name,
              surname: surname,
              email: email,
              password: password,
            ));

            final newUser = await db.getUserByEmail(email);
            if (newUser == null) throw 'Error al registrar el usuario';

            Navigator.pushReplacement(
              ctx,
              MaterialPageRoute(builder: (_) => HomeScreen(user: newUser)),
            );
          },
          onLogin: (email, password) async {
            final user = await db.getUserByEmail(email);
            if (user == null || user.password != password) {
              throw 'Credenciales incorrectas';
            }

            Navigator.pushReplacement(
              ctx,
              MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
            );
          },
        );
      }),
    );
  }
}


// =======================
// PANTALLA DE AUTENTICACIÓN
// =======================

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameCtrl    = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  String? _error;
  final DBHelper _db = DBHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C2769),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _isLogin = false),
                    child: Text('Registro',
                        style: TextStyle(
                          color:
                          !_isLogin ? Colors.white : Colors.white54,
                          fontSize: 18,
                        )),
                  ),
                  const SizedBox(width: 24),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = true),
                    child: Text('Login',
                        style: TextStyle(
                          color:
                          _isLogin ? Colors.white : Colors.white54,
                          fontSize: 18,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () => _submit(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child:
                Text(_isLogin ? 'Iniciar sesión' : 'Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final name = _nameCtrl.text.trim();
    final surname = _surnameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();
    final pass = _passCtrl.text.trim();

    User? user;

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Email y contraseña son obligatorios');
      return;
    }

    if (_isLogin) {
      print('Iniciando sesión con email: $email');
      user = await _db.getUserByEmail(email);
      if (user == null || user.password != pass) {
        print('Credenciales incorrectas');
        setState(() => _error = 'Credenciales incorrectas');
        return;
      }

      print('Usuario encontrado, verificando datos incompletos...');
      if (user.name.isEmpty || user.surname.isEmpty) {
        print('Datos incompletos. Eliminando usuario...');

        setState(() => _error = 'Registro incompleto. No se puede iniciar sesión.');
        return;
      }
    } else {
      if (name.isEmpty || surname.isEmpty) {
        setState(() => _error = 'Nombre y apellido son obligatorios');
        return;
      }

      final exists = await _db.getUserByEmail(email);
      if (exists != null) {
        setState(() => _error = 'Usuario ya existe');
        return;
      }

      print('Insertando nuevo usuario...');
      try {
        await _db.insertUser(User(email: email, password: pass, name: name, surname: surname));
        print('Usuario insertado con éxito');
      } catch (e) {
        print('Error al insertar usuario: $e');
        setState(() => _error = 'Error al registrar usuario. Intente nuevamente.');
        return;
      }

      user = await _db.getUserByEmail(email);
      if (user == null || user.name.isEmpty || user.surname.isEmpty) {
        print('Registro incompleto. Eliminando usuario...');

        setState(() => _error = 'Registro incompleto. Intente nuevamente.');
        return;
      }
    }

    print("User validado: ${user?.email}, ${user?.name}, ${user?.surname}");

    if (!context.mounted) return;
    print("Login o registro exitoso, navegando a HomeScreen...");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(user: user!)),
    );
  }
}

// =======================
// HOMESCREEN INTEGRADA
// =======================

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper _db = DBHelper();
  String _username = '';
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  List<TransactionModel> _transactions = [];
  int _monthIndex = 0;
  final List<String> _months = ['2025-05', '2025-06', '2025-07'];
  final List<String> _monthLabels = ['Mayo 2025', 'Junio 2025', 'Julio 2025'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = widget.user;
    final month = _months[_monthIndex];
    final txs = await _db.getTransactionsByMonth(month);
    final income = txs
        .where((t) => t.type == 'income')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expense = txs
        .where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);
    setState(() {
      _username = user?.name ?? 'Usuario';
      _totalIncome = income;
      _totalExpenses = expense;
      _transactions = txs;
    });
  }

  void _previousMonth() {
    if (_monthIndex > 0) {
      setState(() => _monthIndex--);
      _loadData();
    }
  }

  void _nextMonth() {
    if (_monthIndex < _months.length - 1) {
      setState(() => _monthIndex++);
      _loadData();
    }
  }

  void _agregarTransaccion(TransactionModel nueva) async {
    await _db.insertTransaction(nueva);
    _loadData();
  }

  void _eliminarTransaccion(TransactionModel transaccion) {
    setState(() {
      _transactions.remove(transaccion);
      if (transaccion.type == 'income') {
        _totalIncome -= transaccion.amount;
      } else {
        _totalExpenses -= transaccion.amount;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double balance = _totalIncome - _totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Kash',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: 'Finance',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF0C2769),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and Login Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hola, $_username',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => KashFinanceApp(),
                        ),
                            (route) => false,
                      );
                    },
                    child: const Text(
                      'Salir',
                      style: TextStyle(
                        color: Color(0xFFA61F1F),
                        fontFamily: 'Roboto',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Month Selector
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C2769),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _monthIndex > 0 ? _previousMonth : null,
                      icon: const Icon(Icons.arrow_left, color: Colors.white),
                    ),
                    Text(
                      _monthLabels[_monthIndex],
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _monthIndex < _months.length - 1 ? _nextMonth : null,
                      icon: const Icon(Icons.arrow_right, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Balance Total
              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Balance Total',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000000),
                          ),
                        ),
                        Text(
                          '\$${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0C2769),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Summary (Income & Expenses)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ingresos',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                  color: Color(0xFF34A853),
                                ),
                              ),
                              Text(
                                '\$${_totalIncome.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF34A853),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gastos',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                  color: Color(0xFFD91B57),
                                ),
                              ),
                              Text(
                                '\$${_totalExpenses.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD91B57),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(

                        builder: (context) => BalanceScreen(
                          transactions: _transactions,
                          onDelete: _eliminarTransaccion,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C2769),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Balance',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_transactions.isEmpty) ...[
                const Center(
                  child: Text(
                    'Aún no has realizado movimientos en este mes, Empieza ahora!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: Color(0xFFB3B4B7),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistroMovimientoForm(
                              tipoMovimiento: 'income',
                              onSave: (String cat, double amt, DateTime date) {
                                final nueva = TransactionModel(
                                  type: 'income',
                                  category: cat,
                                  amount: amt,
                                  date: date,
                                );
                                _agregarTransaccion(nueva);
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34A853),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ingresos',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistroMovimientoForm(
                              tipoMovimiento: 'expense',
                              onSave: (String cat, double amt, DateTime date) {
                                final nueva = TransactionModel(
                                  type: 'expense',
                                  category: cat,
                                  amount: amt,
                                  date: date,
                                );
                                _agregarTransaccion(nueva);
                              },
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD91B57),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Gastos',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Column(
                  children: [
                    const Text(
                      'Últimos 5 Movimientos',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length > 5 ? 5 : _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions.reversed.toList()[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              transaction.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
                              color: transaction.type == 'income' ? Color(0xFF34A853) : Color(0xFFD91B57),
                              size: 20,
                            ),
                            title: Text(
                              transaction.category,
                              style: const TextStyle(fontFamily: 'Roboto'),
                            ),
                            subtitle: Text(
                              '\$${transaction.amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontFamily: 'Roboto'),
                            ),
                            trailing: Text(
                              DateFormat('yyyy-MM-dd').format(transaction.date),
                              style: const TextStyle(fontFamily: 'Roboto'),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistroMovimientoForm(
                                  tipoMovimiento: 'income',
                                  onSave: (String cat, double amt, DateTime date) {
                                    final nueva = TransactionModel(
                                      type: 'income',
                                      category: cat,
                                      amount: amt,
                                      date: date,
                                    );
                                    _agregarTransaccion(nueva);
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34A853),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Ingresos',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistroMovimientoForm(
                                  tipoMovimiento: 'expense',
                                  onSave: (String cat, double amt, DateTime date) {
                                    final nueva = TransactionModel(
                                      type: 'expense',
                                      category: cat,
                                      amount: amt,
                                      date: date,
                                    );
                                    _agregarTransaccion(nueva);
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD91B57),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Gastos',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}