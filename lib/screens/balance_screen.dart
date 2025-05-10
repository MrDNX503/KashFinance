import 'package:flutter/material.dart';
import '../../main.dart';

class BalanceScreen extends StatefulWidget {
  final List<Transaction> transactions;

  const BalanceScreen({super.key, required this.transactions});

  @override
  _BalanceScreenState createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Balance',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0C2769), // Azul oscuro
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Todas las Transacciones del Mes',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.transactions.isEmpty
                  ? const Center(
                child: Text(
                  'No hay transacciones para mostrar.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Color(0xFFB3B4B7),
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: widget.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = widget.transactions[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        transaction.type == 'income'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: transaction.type == 'income'
                            ? const Color(0xFF34A853) // Verde
                            : const Color(0xFFD91B57), // Rojo
                        size: 20,
                      ),
                      title: Text(
                        transaction.category,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '\$${transaction.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                        ),
                      ),
                      trailing: Text(
                        transaction.date,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}