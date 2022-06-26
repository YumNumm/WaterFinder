import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends SupabaseAuthState<SplashPage> {
  @override
  void initState() {
    recoverSupabaseSession();
    super.initState();
  }

  @override
  void onAuthenticated(Session session) {
    Logger().i('uid: ${session.user?.id}');

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  void onErrorAuthenticating(String message) {
    // TODO(YumNumm): implement onErrorAuthenticating
  }

  @override
  void onPasswordRecovery(Session session) {
    // TODO(YumNumm): implement onPasswordRecovery
  }

  @override
  void onUnauthenticated() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
