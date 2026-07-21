import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/pedido.dart';
import '../models/detalle_pedido.dart';
import 'detalle_form_screen.dart';

class PedidoFormScreen extends StatefulWidget {
  final int? pedidoId;
  const PedidoFormScreen({Key? key, this.pedidoId}) : super(key: key);

  @override
  _PedidoFormScreenState createState() => _PedidoFormScreenState();
}

class _PedidoFormScreenState extends State<PedidoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clienteController;
  String _estado = 'Pendiente';
  Pedido? _pedido;
  List<DetallePedido> _detalles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _clienteController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.pedidoId != null) {
      _pedido = await DatabaseHelper.instance.readPedido(widget.pedidoId!);
      if (_pedido != null) {
        _clienteController.text = _pedido!.cliente;
        _estado = _pedido!.estado;
        _detalles =
            await DatabaseHelper.instance.readDetallesByPedido(_pedido!.id!);
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _savePedido() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pedido == null) {
      // CREATE
      final nuevo = Pedido(
        cliente: _clienteController.text.trim(),
        fecha: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
        estado: _estado,
        total: 0.0,
      );
      final created = await DatabaseHelper.instance.createPedido(nuevo);
      setState(() => _pedido = created);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Pedido guardado. Ahora puedes agregar productos.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // UPDATE
      final updated = Pedido(
        id: _pedido!.id,
        cliente: _clienteController.text.trim(),
        fecha: _pedido!.fecha,
        estado: _estado,
        total: _pedido!.total,
      );
      await DatabaseHelper.instance.updatePedido(updated);
      setState(() => _pedido = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Pedido actualizado correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _refreshDetalles() async {
    if (_pedido == null) return;
    final p = await DatabaseHelper.instance.readPedido(_pedido!.id!);
    final d =
        await DatabaseHelper.instance.readDetallesByPedido(_pedido!.id!);
    setState(() {
      _pedido = p;
      _detalles = d;
    });
  }

  Future<void> _deleteDetalle(int detalleId) async {
    await DatabaseHelper.instance
        .deleteDetallePedido(detalleId, _pedido!.id!);
    _refreshDetalles();
  }

  void _confirmDeleteDetalle(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('¿Eliminar este producto del pedido?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteDetalle(id);
            },
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text(_pedido == null ? 'Nuevo Pedido' : 'Editar Pedido #${_pedido!.id}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Sección: datos del pedido ─────────────────────────────
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Datos del Pedido',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _clienteController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Cliente',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'El cliente no puede estar vacío'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _estado,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Pendiente', child: Text('Pendiente')),
                          DropdownMenuItem(
                              value: 'Completado', child: Text('Completado')),
                        ],
                        onChanged: (v) => setState(() => _estado = v!),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: Text(_pedido == null
                              ? 'GUARDAR PEDIDO'
                              : 'ACTUALIZAR PEDIDO'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: _savePedido,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Sección: detalles (solo si el pedido ya fue guardado) ─
            if (_pedido != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Productos del Pedido',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    'Total: \$${_pedido!.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _detalles.isEmpty
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.shopping_cart_outlined,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text('Sin productos aún.',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _detalles
                          .map((d) => Card(
                                margin:
                                    const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(d.producto,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 15)),
                                            Text(
                                                '${d.cantidad} x \$${d.precioUnitario.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                    color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                          '\$${d.subtotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15)),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.indigo),
                                        tooltip: 'Editar producto',
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  DetalleFormScreen(
                                                pedidoId: _pedido!.id!,
                                                detalleId: d.id,
                                              ),
                                            ),
                                          );
                                          _refreshDetalles();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        tooltip: 'Eliminar producto',
                                        onPressed: () =>
                                            _confirmDeleteDetalle(d.id!),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('AGREGAR PRODUCTO'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetalleFormScreen(pedidoId: _pedido!.id!),
                      ),
                    );
                    _refreshDetalles();
                  },
                ),
              ),
            ] else ...[
              Card(
                color: Colors.amber.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Guarda el pedido primero para poder agregar productos.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _clienteController.dispose();
    super.dispose();
  }
}
