import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import 'core/theme/app_theme.dart';
import 'core/services/audio_service.dart';
import 'core/services/download_service.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/music/music_bloc.dart';
import 'presentation/bloc/user/user_bloc.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/category/category_page.dart';
import 'presentation/pages/player/player_page.dart';
import 'presentation/pages/subscription/subscription_page.dart';

final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://judwkuinzlhiblozulwv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1ZHdrdWluemxoaWJsb3p1bHd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEzMzQzNjEsImV4cCI6MjA2NjkxMDM2MX0.WDTmThQPkM7gAHYAFidHVg_xp6dryRxClmYFAtM1MvI',
  );

  await setupDependencies();
  runApp(MyApp());
}

Future<void> setupDependencies() async {
  getIt.registerSingleton<AudioService>(AudioService());
  getIt.registerSingleton<DownloadService>(DownloadService());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()..add(CheckAuthStatus())),
        BlocProvider(create: (context) => MusicBloc()),
        BlocProvider(create: (context) => UserBloc()),
      ],
      child: MaterialApp(
        title: 'مشغل الموسيقى',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashPage(),
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
          '/category': (context) => CategoryPage(),
          '/player': (context) => PlayerPage(),
          '/subscription': (context) => SubscriptionPage(),
        },
      ),
    );
  }
}
