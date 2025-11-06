import 'package:flutter/material.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar y nombre
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF42424A),
                        border: Border.all(
                          color: const Color(0xFF3D5AFE),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Diego',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'diego@morpheo.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Opciones de perfil
              _buildProfileOption(
                icon: Icons.settings,
                title: 'Configuración',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.notifications,
                title: 'Notificaciones',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.help_outline,
                title: 'Ayuda y Soporte',
                onTap: () {},
              ),
              _buildProfileOption(
                icon: Icons.info_outline,
                title: 'Acerca de',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildProfileOption(
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                onTap: () {},
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF2C2C34),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDestructive
                      ? const Color(0xFFFF5252)
                      : Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive
                          ? const Color(0xFFFF5252)
                          : Colors.white,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}