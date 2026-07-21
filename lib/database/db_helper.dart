import '../models/pedido.dart';
import '../models/detalle_pedido.dart';

/// In-memory database that works on all platforms including Web.
/// Uses static maps to simulate SQL tables (Pedidos + Detalles_Pedido).
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  // ── Tables ───────────────────────────────────────────────────────────────
  static int _pedidoAutoId = 1;
  static int _detalleAutoId = 1;
  static final Map<int, Pedido> _pedidos = {};
  static final Map<int, DetallePedido> _detalles = {};

  // ── Pedidos CRUD ──────────────────────────────────────────────────────────

  Future<Pedido> createPedido(Pedido pedido) async {
    final id = _pedidoAutoId++;
    final created = Pedido(
      id: id,
      cliente: pedido.cliente,
      fecha: pedido.fecha,
      estado: pedido.estado,
      total: pedido.total,
    );
    _pedidos[id] = created;
    return created;
  }

  Future<Pedido?> readPedido(int id) async {
    return _pedidos[id];
  }

  Future<List<Pedido>> readAllPedidos() async {
    final list = _pedidos.values.toList();
    list.sort((a, b) => b.id!.compareTo(a.id!)); // ORDER BY id DESC
    return list;
  }

  Future<int> updatePedido(Pedido pedido) async {
    if (!_pedidos.containsKey(pedido.id)) return 0;
    _pedidos[pedido.id!] = pedido;
    return 1;
  }

  Future<int> deletePedido(int id) async {
    _detalles.removeWhere((_, d) => d.pedidoId == id);
    return _pedidos.remove(id) != null ? 1 : 0;
  }

  // ── Detalles Pedido CRUD ─────────────────────────────────────────────────

  Future<DetallePedido> createDetallePedido(DetallePedido detalle) async {
    final id = _detalleAutoId++;
    final created = DetallePedido(
      id: id,
      pedidoId: detalle.pedidoId,
      producto: detalle.producto,
      cantidad: detalle.cantidad,
      precioUnitario: detalle.precioUnitario,
      subtotal: detalle.subtotal,
    );
    _detalles[id] = created;
    await _recalcularTotalPedido(detalle.pedidoId);
    return created;
  }

  Future<List<DetallePedido>> readDetallesByPedido(int pedidoId) async {
    return _detalles.values.where((d) => d.pedidoId == pedidoId).toList();
  }

  Future<int> updateDetallePedido(DetallePedido detalle) async {
    if (!_detalles.containsKey(detalle.id)) return 0;
    _detalles[detalle.id!] = detalle;
    await _recalcularTotalPedido(detalle.pedidoId);
    return 1;
  }

  Future<int> deleteDetallePedido(int id, int pedidoId) async {
    final removed = _detalles.remove(id);
    if (removed != null) {
      await _recalcularTotalPedido(pedidoId);
      return 1;
    }
    return 0;
  }

  // ── Helper ───────────────────────────────────────────────────────────────

  Future<void> _recalcularTotalPedido(int pedidoId) async {
    final detallesPedido =
        _detalles.values.where((d) => d.pedidoId == pedidoId);
    final total = detallesPedido.fold(0.0, (sum, d) => sum + d.subtotal);
    if (_pedidos.containsKey(pedidoId)) {
      final p = _pedidos[pedidoId]!;
      _pedidos[pedidoId] = Pedido(
        id: p.id,
        cliente: p.cliente,
        fecha: p.fecha,
        estado: p.estado,
        total: total,
      );
    }
  }

  Future<void> close() async {} // No-op for in-memory store
}
