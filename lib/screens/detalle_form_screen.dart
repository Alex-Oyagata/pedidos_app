import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/detalle_pedido.dart';

class DetalleFormScreen extends StatefulWidget {
  final int pedidoId;
  final int? detalleId;

  const DetalleFormScreen({Key? key, required this.pedidoId, this.detalleId})
      : super(key: key);

  @override
  _DetalleFormScreenState createState() => _DetalleFormScreenState();
}

class _DetalleFormScreenState extends State<DetalleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productoController;
  late TextEditingController _cantidadController;
  late TextEditingController _precioController;
  DetallePedido? _detalle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _productoController = TextEditingController();
    _cantidadController = TextEditingController(text: '1');
    _precioController = TextEditingController(text: '0.00');
    _loadDetalle();
  }

  Future<void> _loadDetalle() async {
    if (widget.detalleId != null) {
      final detalles =
          await DatabaseHelper.instance.readDetallesByPedido(widget.pedidoId);
      try {
        _detalle = detalles.firstWhere((d) => d.id == widget.detalleId);
        _productoController.text = _detalle!.producto;
        _cantidadController.text = _detalle!.cantidad.toString();
        _precioController.text = _detalle!.precioUnitario.toString();
      } catch (_) {}
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveDetalle() async {
    if (!_formKey.currentState!.validate()) return;

    final cantidad = int.parse(_cantidadController.text);
    final precio = double.parse(_precioController.text);
    final subtotal = cantidad * precio;

    if (_detalle == null) {
      await DatabaseHelper.instance.createDetallePedido(
        DetallePedido(
          pedidoId: widget.pedidoId,
          producto: _productoController.text.trim(),
          cantidad: cantidad,
          precioUnitario: precio,
          subtotal: subtotal,
        ),
      );
    } else {
      await DatabaseHelper.instance.updateDetallePedido(
        DetallePedido(
          id: _detalle!.id,
          pedidoId: widget.pedidoId,
          producto: _productoController.text.trim(),
          cantidad: cantidad,
          precioUnitario: precio,
          subtotal: subtotal,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_detalle == null ? 'Agregar Producto' : 'Editar Producto'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Datos del Producto',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _productoController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Producto',
                          prefixIcon: Icon(Icons.inventory_2),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'El producto no puede estar vacío'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cantidadController,
                        decoration: const InputDecoration(
                          labelText: 'Cantidad',
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          final n = int.tryParse(v);
                          if (n == null || n <= 0) return 'Ingrese un número mayor a 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _precioController,
                        decoration: const InputDecoration(
                          labelText: 'Precio Unitario',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          final n = double.tryParse(v);
                          if (n == null || n < 0) return 'Ingrese un precio válido';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                    _detalle == null ? 'GUARDAR PRODUCTO' : 'ACTUALIZAR PRODUCTO',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saveDetalle,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('CANCELAR',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _productoController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    super.dispose();
  }
}
