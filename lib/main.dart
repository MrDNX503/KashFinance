import 'package:flutter/material.dart';
import 'screens/balance_screen.dart';
import 'screens/registro_movimiento_form.dart';

void main() {
  runApp(const KashFinanceApp());
}

class KashFinanceApp extends StatelessWidget {
  const KashFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KashFinance',
      theme: ThemeData(
        primaryColor: const Color(0xFF0C2769), // Dark blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0C2769),
          secondary: const Color(0xFFD91B57), // Red
          background: const Color(0xFFEDEDED), // Light gray
        ),
        scaffoldBackgroundColor: const Color(0xFFEDEDED),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: const Color(0xFFFFFFFF), // White
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000000), // Black
            fontFamily: 'Roboto',
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Color(0xFFB3B4B7), // Gray
            fontFamily: 'Roboto',
          ),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class Transaction {
  final int? id;
  final String type; // 'income' or 'expense'
  final String category;
  final double amount;
  final String date;

  Transaction({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
  });
}

// Placeholder DatabaseHelper (to be replaced by backend team)
class DatabaseHelper {
  Future<String> getUsername() async => 'User';
  Future<double> getTotalIncome(String month) async => 0.0; // Simulate no transactions
  Future<double> getTotalExpenses(String month) async => 0.0;
  Future<List<Transaction>> getTransactions(String month) async => []; // Empty initially
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String _username = 'User';
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  List<Transaction> _transactions = [];
  String _selectedMonth = '2025-05';
  int _monthIndex = 0;
  final List<String> _months = ['2025-05', '2025-06', '2025-07'];
  final List<String> _monthLabels = ['Mayo 2025', 'Junio 2025', 'Julio 2025'];

  @override
  void initState() {
    super.initState();
    _transactions = [];
    _totalIncome = 0.0;
    _totalExpenses = 0.0;
    // _loadData(); // Temporarily disabled to use test data
  }

  Future<void> _loadData() async {
    final username = await _dbHelper.getUsername();
    final totalIncome = await _dbHelper.getTotalIncome(_selectedMonth);
    final totalExpenses = await _dbHelper.getTotalExpenses(_selectedMonth);
    final transactions = await _dbHelper.getTransactions(_selectedMonth);
    setState(() {
      _username = username;
      _totalIncome = totalIncome;
      _totalExpenses = totalExpenses;
      _transactions = transactions;
    });
  }

  void _previousMonth() {
    if (_monthIndex > 0) {
      setState(() {
        _monthIndex--;
        _selectedMonth = _months[_monthIndex];
        // _loadData(); // Temporarily disabled to use test data
      });
    }
  }

  void _nextMonth() {
    if (_monthIndex < _months.length - 1) {
      setState(() {
        _monthIndex++;
        _selectedMonth = _months[_monthIndex];
        // _loadData(); // Temporarily disabled to use test data
      });
    }
  }

  void _agregarTransaccion(Transaction nuevaTransaccion) {
    setState(() {
      _transactions.add(nuevaTransaccion);
      if (nuevaTransaccion.type == 'income') {
        _totalIncome += nuevaTransaccion.amount;
      } else {
        _totalExpenses += nuevaTransaccion.amount;
      }
    });
  }

  void _eliminarTransaccion(Transaction transaccion) {
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
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Hola, $_username',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              // Month Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              onSave: _agregarTransaccion,
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
                              onSave: _agregarTransaccion,
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
                              transaction.date,
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
                                  onSave: _agregarTransaccion,
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
                                  onSave: _agregarTransaccion,
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