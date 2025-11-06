import 'package:flutter/material.dart';
import 'home_page.dart';
import 'historial_page.dart';
import 'alarmas_page.dart';
import 'dispositivo_page.dart';
import 'perfil_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Lista de páginas
  final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const AlarmasPage(),
    const DispositivoPage(),
    const PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF2C2C34),
          selectedItemColor: const Color(0xFF3D5AFE),
          unselectedItemColor: const Color(0xFF9E9E9E),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              activeIcon: Icon(Icons.alarm),
              label: 'Alarmas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_android),
              activeIcon: Icon(Icons.phone_android),
              label: 'Dispositivo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}