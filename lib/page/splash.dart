import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:waterfinder/components/auth_state.dart';
import 'package:waterfinder/provider/supabase_provider.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends AuthState<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}