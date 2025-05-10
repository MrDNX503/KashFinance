import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // Para acceder a la clase Transaction

class RegistroMovimientoForm extends StatefulWidget {
  final String tipoMovimiento; // 'income' o 'expense'
  final Function(Transaction) onSave; // Callback para agregar el movimiento

  const RegistroMovimientoForm({
    super.key,
    required this.tipoMovimiento,
    required this.onSave,
  });

  @override
  _RegistroMovimientoFormState createState() => _RegistroMovimientoFormState();
}

class _RegistroMovimientoFormState extends State<RegistroMovimientoForm> {
  String? _categoriaSeleccionada;
  TextEditingController _montoController = TextEditingController();
  TextEditingController _fechaController = TextEditingController();
  DateTime? _fechaSeleccionada;

  // Lista de categorías para el Dropdown
  List<Map<String, dynamic>> _categoriasConIconos = [
    {'nombre': 'Despensa', 'icono': Icons.shopping_cart},
    {'nombre': 'Salario', 'icono': Icons.attach_money},
    {'nombre': 'Alquiler', 'icono': Icons.home},
    {'nombre': 'Facturas', 'icono': Icons.receipt},
    {'nombre': 'Ocio', 'icono': Icons.movie},
    {'nombre': 'Reparación', 'icono': Icons.build},
    {'nombre': 'Transporte', 'icono': Icons.directions_car},
    {'nombre': 'Educación', 'icono': Icons.school},
    {'nombre': 'Otros', 'icono': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    // Establecer la fecha actual como predeterminada
    _fechaSeleccionada = DateTime.now();
    _fechaController.text =
        DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!);
  }

  @override
  void dispose() {
    _montoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determinar colores según el tipo de movimiento
    final Color colorPrincipal = widget.tipoMovimiento == 'income'
        ? const Color(0xFF34A853) // Verde para ingresos
        : const Color(0xFFD91B57); // Rojo para gastos

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tipoMovimiento == 'income'
              ? 'Agregar Ingreso'
              : 'Agregar Gasto',
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            color: Colors.white,
          ),
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
              items: _categoriasConIconos.map((Map<String, dynamic> categoria) {
                return DropdownMenuItem<String>(
                  value: categoria['nombre'],
                  child: Row(
                    children: <Widget>[
                      Icon(categoria['icono']),
                      SizedBox(width: 8.0),
                      Text(categoria['nombre']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _categoriaSeleccionada = newValue;
                });
              },
              hint: Row(
                children: <Widget>[
                  SizedBox(width: 8.0),
                  Text('Selecciona una opción'),
                ],
              ),
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
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _fechaSeleccionada ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _fechaSeleccionada = pickedDate;
                        _fechaController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
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
                        _montoController.text.isEmpty ||
                        _fechaController.text.isEmpty) {
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

                    // Crear nueva transacción
                    final nuevaTransaccion = Transaction(
                      type: widget.tipoMovimiento,
                      category: _categoriaSeleccionada!,
                      amount: monto,
                      date: _fechaController.text,
                    );

                    // Llamar al callback para agregar la transacción
                    widget.onSave(nuevaTransaccion);

                    // Regresar a la pantalla anterior
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 12.0,
                    ),
                  ),
                  onPressed: () {
                    // Cancelar y regresar
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
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
