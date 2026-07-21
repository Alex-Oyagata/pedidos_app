import 'package:flutter/material.dart';
import 'screens/pedidos_list_screen.dart';

void main() {
  runApp(const PedidosApp());
}

class PedidosApp extends StatelessWidget {
  const PedidosApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedidos App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PedidosListScreen(),
    );
  }
}
