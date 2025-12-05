import 'package:flutter/material.dart';
import '../features/products/presentation/pages/product_list_page.dart';
import '../features/sales/presentation/pages/pos_page.dart';
import '../features/sales/presentation/pages/sales_history_page.dart';
import '../features/clients/presentation/pages/client_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ProductListPage(),
    const POSPage(),
    const SalesHistoryPage(),
    const ClientListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale),
            label: 'Ventas',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Clientes',
          ),
        ],
      ),
    );
  }
}
