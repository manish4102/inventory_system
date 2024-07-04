import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:inventory_system/pages/expenses_page.dart';
import 'package:inventory_system/pages/products_page.dart';
import 'package:inventory_system/pages/sales_page.dart';
import 'package:inventory_system/pages/profile_page.dart';

class CurvedNavigationBarContainer extends StatefulWidget {
  @override
  _CurvedNavigationBarContainerState createState() => _CurvedNavigationBarContainerState();
}

class _CurvedNavigationBarContainerState extends State<CurvedNavigationBarContainer> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ProductsPage(),
    SalesPage(),
    ExpensesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.attach_money, size: 30),
          Icon(Icons.inventory, size: 30),
          Icon(Icons.person, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
