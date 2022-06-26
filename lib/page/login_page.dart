import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' as rpd;
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waterfinder/page/main_page.dart';

import '../provider/supabase_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends SupabaseAuthState<LoginPage> {
  @override
  Widget build(
    BuildContext context,
  ) {
    final size = MediaQuery.of(context).size;
    const isProcessing = false;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 0, 72, 131),
              Colors.blueAccent,
            ],
          ),
        ),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withOpacity(0.7),
                width: size.width * 0.8,
                height: size.height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedTextKit(
                      animatedTexts: [
                        ColorizeAnimatedText(
                          'WaterFinder',
                          textStyle: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                          colors: [
                            const Color.fromARGB(255, 0, 72, 131),
                            Colors.blueAccent,
                          ],
                        ),
                      ],
                    ),
                    const Text(
                      'You can find watering places in the world',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _LoginButton()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    startAuthObserver();
    super.initState();
  }

  @override
  void dispose() {
    stopAuthObserver();
    super.dispose();
  }

  @override
  void onAuthenticated(Session session) {
    Logger().i('OK Successfully authenticated');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
    }
  }

  @override
  void onErrorAuthenticating(String message) {
    // TODO: implement onErrorAuthenticating
  }

  @override
  void onPasswordRecovery(Session session) {
    // TODO: implement onPasswordRecovery
  }

  @override
  void onUnauthenticated() {
    // TODO: implement onUnauthenticated
  }
}

class _LoginButton extends rpd.HookConsumerWidget {
  const _LoginButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, rpd.WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await ref.read(supabaseStateNotifier.notifier).signInWithGoogle();
      },
      label: const Text(
        'Login',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
