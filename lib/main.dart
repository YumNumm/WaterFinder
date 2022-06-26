import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waterfinder/page/splash.dart';
import 'package:waterfinder/provider/supabase_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabase = await Supabase.initialize(
    url: '[YOUR_SUPABASE_URL]',
    anonKey: '[YOUR_SUPABASE_ANON_KEY]',
  );
  runApp(
    ProviderScope(
      overrides: [
        supabaseProvider.overrideWithValue(supabase),
      ],
      child: MaterialApp(
        title: 'Water Finder',
        locale: const Locale('en', 'EN'),
        home: SplashPage(),
        routes: {
          '/splash': (context) => SplashPage(),
        },
        initialRoute: '/splash',
      ),
    ),
  );
}
