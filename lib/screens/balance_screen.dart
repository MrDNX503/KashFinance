import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';

class BalanceScreen extends StatefulWidget {
  final List<TransactionModel> transactions;
  final Function(TransactionModel) onDelete;

  const BalanceScreen({super.key, required this.transactions, required this.onDelete});

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
        backgroundColor: const Color(0xFF0C2769),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Todas las Transacciones',
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
                  final fechaStr = DateFormat('yyyy-MM-dd').format(transaction.date);
                  return Dismissible(
                    key: Key(fechaStr + transaction.category),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              title: const Text(
                                'Confirmar Eliminación',
                                style: TextStyle(fontFamily: 'Roboto'),
                              ),
                              content: const Text(
                                '¿Estás seguro que quieres eliminar?',
                                style: TextStyle(fontFamily: 'Roboto'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(fontFamily: 'Roboto'),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Eliminar',
                                    style: TextStyle(fontFamily: 'Roboto'),
                                  ),
                                ),
                              ],
                            ),
                      );
                      return confirm ?? false;
                    },
                    onDismissed: (direction) {
                      widget.onDelete(transaction);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Transacción eliminada: ${transaction.category}',
                            style: const TextStyle(fontFamily: 'Roboto'),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          transaction.type == 'income'
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: transaction.type == 'income'
                              ? const Color(0xFF34A853)
                              : const Color(0xFFD91B57),
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
                          fechaStr,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                          ),
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