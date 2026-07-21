class Pedido {
  final int? id;
  final String cliente;
  final String fecha;
  final String estado;
  final double total;

  Pedido({
    this.id,
    required this.cliente,
    required this.fecha,
    required this.estado,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'fecha': fecha,
      'estado': estado,
      'total': total,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      cliente: map['cliente'],
      fecha: map['fecha'],
      estado: map['estado'],
      total: map['total'],
    );
  }
}
