import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // Para acceder a la clase Transaction

class RegistroMovimientoForm extends StatefulWidget {
  final String tipoMovimiento; // 'income' o 'expense'
  final void Function(String category, double amount, DateTime date) onSave;
  // Callback para agregar el movimiento

  final String? initialCategory;
  final double? initialAmount;
  final DateTime? initialDate;

  const RegistroMovimientoForm({
    super.key,
    required this.tipoMovimiento,
    required this.onSave,
    this.initialCategory,
    this.initialAmount,
    this.initialDate,
  });

  @override
  _RegistroMovimientoFormState createState() => _RegistroMovimientoFormState();
}

class _RegistroMovimientoFormState extends State<RegistroMovimientoForm> {
  String? _categoriaSeleccionada;
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  late DateTime _fechaSeleccionada = DateTime.now();

  // Lista de categorías para el Dropdown
  static const _incomeCategories = [
    {'nombre': 'Salario',     'icono': Icons.attach_money},
    {'nombre': 'Otros',       'icono': Icons.more_horiz},
  ];
  static const _expenseCategories = [
    {'nombre': 'Despensa',    'icono': Icons.shopping_cart},
    {'nombre': 'Alquiler',    'icono': Icons.home},
    {'nombre': 'Facturas',    'icono': Icons.receipt},
    {'nombre': 'Ocio',        'icono': Icons.movie},
    {'nombre': 'Reparación',  'icono': Icons.build},
    {'nombre': 'Transporte',  'icono': Icons.directions_car},
    {'nombre': 'Educación',   'icono': Icons.school},
    {'nombre': 'Otros',       'icono': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = widget.initialDate ?? DateTime.now();
    _fechaController.text = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada);

    if (widget.initialCategory != null) {
      _categoriaSeleccionada = widget.initialCategory;
    }
    if (widget.initialAmount != null) {
      _montoController.text = widget.initialAmount.toString();
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_categoriaSeleccionada == null || _montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }
    final monto = double.tryParse(_montoController.text);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un monto válido')),
      );
      return;
    }

    widget.onSave(
      _categoriaSeleccionada!,
      monto,
      _fechaSeleccionada,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.tipoMovimiento == 'income';
    final colorPrincipal = isIncome
        ? const Color(0xFF34A853)
        : const Color(0xFFD91B57);

    final categorias = isIncome
        ? _incomeCategories
        : _expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isIncome ? 'Agregar Ingreso' : 'Agregar Gasto',
          style: const TextStyle(fontFamily: 'Roboto', fontSize: 20, color: Colors.white,),
        ),
        backgroundColor: colorPrincipal,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Campo de Categoría (Dropdown)
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
              value: _categoriaSeleccionada,
              items: categorias.map((c) {
                return DropdownMenuItem<String>(
                  value: c['nombre'] as String,
                  child: Row(
                    children: <Widget>[
                      Icon(c['icono'] as IconData),
                      SizedBox(width: 8.0),
                      Text(c['nombre'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _categoriaSeleccionada = v),
              hint: const Text('Selecciona una categoría'),
              ),
            SizedBox(height: 16.0),

            // Campo de Monto (TextField)
            TextFormField(
              controller: _montoController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Monto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Campo de Fecha (TextField con selector de calendario)
            TextFormField(
              controller: _fechaController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Fecha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _fechaSeleccionada,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        _fechaSeleccionada = picked;
                        _fechaController.text =
                            DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Botones de Guardar y Cancelar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrincipal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 12.0,
                    ),
                  ),
                  onPressed: () {
                    if (_categoriaSeleccionada == null ||
                        _montoController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Por favor completa todos los campos')),
                      );
                      return;
                    }

                    final monto = double.tryParse(_montoController.text);
                    if (monto == null || monto <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Por favor ingresa un monto válido')),
                      );
                      return;
                    }
                    //Seleccionar fecha
                    //final fechaString = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada);

                    // Llamada al callback con category, amount y date
                    widget.onSave(
                      _categoriaSeleccionada!,
                      monto,
                      _fechaSeleccionada,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar', style: TextStyle(color: Colors.white,),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white,),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
