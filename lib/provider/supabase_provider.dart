import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:url_launcher/url_launcher.dart';

import '../model/supabase_service_model.dart';

// ダミーのProviderを用意する
final supabaseProvider = Provider<sb.Supabase>((ref) {
  debugPrint('run isarprovider');
  throw UnimplementedError('Supabase is not loaded');
});

class SupabaseStateNotifier extends StateNotifier<SupabaseModel> {
  SupabaseStateNotifier(this.supabase)
      : super(SupabaseModel(supabase: supabase));
  final sb.Supabase supabase;

  final Logger logger = Logger();

  
  Future<void> signInWithGoogle() async {
    final res = await supabase.client.auth.signIn(
      provider: sb.Provider.google,
      options: sb.AuthOptions(
        redirectTo: kIsWeb ? null : 'com.yumnumm.waterfinder://login-callback/',
      ),
    );
    final error = res.error;
    if (error != null) {
      logger.w('Error signing in with Google: $error');
      throw error;
    } else {
      logger.i(res.url);
      await launchUrl(
        Uri.parse(res.url!),
        webOnlyWindowName: '_self',
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

final supabaseStateNotifier =
    StateNotifierProvider<SupabaseStateNotifier, SupabaseModel>((ref) {
  return SupabaseStateNotifier(ref.watch(supabaseProvider));
});
