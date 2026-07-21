class DetallePedido {
  final int? id;
  final int pedidoId;
  final String producto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetallePedido({
    this.id,
    required this.pedidoId,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pedido_id': pedidoId,
      'producto': producto,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
    };
  }

  factory DetallePedido.fromMap(Map<String, dynamic> map) {
    return DetallePedido(
      id: map['id'],
      pedidoId: map['pedido_id'],
      producto: map['producto'],
      cantidad: map['cantidad'],
      precioUnitario: map['precio_unitario'],
      subtotal: map['subtotal'],
    );
  }
}
