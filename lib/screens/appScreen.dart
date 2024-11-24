import 'package:flutter/material.dart';
import 'package:spiroble/screens/ResultScreen.dart';
import 'package:spiroble/screens/bluetoothScreen.dart';
import 'package:spiroble/screens/home_screen.dart';
import 'package:spiroble/screens/user_screen.dart';
import 'package:spiroble/screens/testScreen.dart';

import 'package:spiroble/widgets/bottom_navigationMenu.dart';

class AppScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<AppScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _selectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen();
      //case 2:
      //    return BosScreen();
      case 1:
        return ProfileScreen();

      case 2:
        return TestScreen();

      case 3:
        return ResultScreen();

      case 4:
        return BluetoothScreen();
      default:
        return Center(child: Text('Varsayılan Ekran')); // Varsayılan ekran
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _selectedScreen(),
      ),
      bottomNavigationBar: NavigationMenu(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
