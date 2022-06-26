import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState<T extends StatefulWidget> extends SupabaseAuthState<T> {
  final Logger logger = Logger();
  @override
  void onUnauthenticated() {
    logger.i('Unauthenticated');
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  void onAuthenticated(Session session) {
    logger.i('Authenticated');
    Navigator.of(context).pushNamedAndRemoveUntil('/account', (route) => false);
  }

  @override
  void onPasswordRecovery(Session session) {}

  @override
  void onErrorAuthenticating(String message) {
    logger.w('Error authenticating $message');
  }
}
