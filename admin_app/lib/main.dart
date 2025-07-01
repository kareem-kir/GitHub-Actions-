import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/theme/admin_theme.dart';
import 'presentation/bloc/auth/admin_auth_bloc.dart';
import 'presentation/bloc/content/content_bloc.dart';
import 'presentation/bloc/users/users_bloc.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/auth/admin_login_page.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'presentation/pages/categories/categories_page.dart';
import 'presentation/pages/tracks/tracks_page.dart';
import 'presentation/pages/users/users_page.dart';
import 'presentation/pages/settings/settings_page.dart';

final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://judwkuinzlhiblozulwv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1ZHdrdWluemxoaWJsb3p1bHd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEzMzQzNjEsImV4cCI6MjA2NjkxMDM2MX0.WDTmThQPkM7gAHYAFidHVg_xp6dryRxClmYFAtM1MvI',
  );

  await setupDependencies();
  runApp(AdminApp());
}

Future<void> setupDependencies() async {
  // Register services here if needed
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AdminAuthBloc()..add(CheckAdminAuthStatus())),
        BlocProvider(create: (context) => ContentBloc()),
        BlocProvider(create: (context) => UsersBloc()),
      ],
      child: MaterialApp(
        title: 'لوحة تحكم مشغل الموسيقى',
        theme: AdminTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => AdminSplashPage(),
          '/login': (context) => AdminLoginPage(),
          '/dashboard': (context) => DashboardPage(),
          '/categories': (context) => CategoriesPage(),
          '/tracks': (context) => TracksPage(),
          '/users': (context) => UsersPage(),
          '/settings': (context) => SettingsPage(),
        },
      ),
    );
  }
}
