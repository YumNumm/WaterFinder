import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waterfinder/page/login_page.dart';
import 'package:waterfinder/page/splash.dart';
import 'package:waterfinder/private/key.dart';
import 'package:waterfinder/provider/supabase_provider.dart';

import 'page/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent status bar
    ),
  );
  final supabase = await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: kDebugMode,
    authCallbackUrlHostname: 'login-callback',
  );
  runApp(
    ProviderScope(
      overrides: [
        supabaseProvider.overrideWithValue(supabase),
      ],
      child: MaterialApp(
        title: 'Water Finder',
        locale: const Locale('en', 'EN'),
        routes: {
          '/': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/main': (context) => const MainPage(),
        },
        initialRoute: '/',
      ),
    ),
  );
}
