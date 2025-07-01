import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/admin_auth_bloc.dart';

class AdminDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          BlocBuilder<AdminAuthBloc, AdminAuthState>(
            builder: (context, state) {
              if (state is AdminAuthAuthenticated) {
                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  accountName: Text(
                    state.admin.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  accountEmail: Text(state.admin.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      state.admin.displayName.isNotEmpty 
                        ? state.admin.displayName[0].toUpperCase()
                        : 'A',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'لوحة التحكم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              );
            },
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'لوحة التحكم',
                  route: '/dashboard',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.category,
                  title: 'إدارة الأقسام',
                  route: '/categories',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.music_note,
                  title: 'إدارة المقاطع',
                  route: '/tracks',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  title: 'إدارة المستخدمين',
                  route: '/users',
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'الإعدادات',
                  route: '/settings',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info,
                  title: 'حول التطبيق',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
          
          // Logout
          Container(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: onTap ?? () {
        Navigator.of(context).pop();
        if (route != null && currentRoute != route) {
          Navigator.of(context).pushReplacementNamed(route);
        }
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    Navigator.of(context).pop();
    showAboutDialog(
      context: context,
      applicationName: 'لوحة تحكم مشغل الموسيقى',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 جميع الحقوق محفوظة',
      children: [
        const SizedBox(height: 16),
        const Text(
          'لوحة تحكم شاملة لإدارة تطبيق مشغل الموسيقى، تتيح للمديرين إدارة المحتوى والمستخدمين بسهولة.',
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AdminAuthBloc>().add(AdminSignOut());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        );
      },
    );
  }
}
