import 'package:flutter/foundation.dart' hide Category;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:url_launcher/url_launcher.dart';
import 'package:waterfinder/schema/category.dart';
import 'package:waterfinder/schema/spot.dart';

import '../model/supabase_service_model.dart';

// ダミーのProviderを用意する
final supabaseProvider = Provider<sb.Supabase>((ref) {
  debugPrint('run isarprovider');
  throw UnimplementedError('Supabase is not loaded');
});

class SupabaseStateNotifier extends StateNotifier<SupabaseModel> {
  SupabaseStateNotifier(this.supabase)
      : super(
          SupabaseModel(
            supabase: supabase,
            user: null,
            spots: [],
            categories: [],
          ),
        );
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
      throw Exception(error);
    } else {
      logger.i(res.url);
      await launchUrl(
        Uri.parse(res.url!),
        webOnlyWindowName: '_self',
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<List<Spot>> getPoints() async {
    final res = await supabase.client.from('spot').select().execute();
    final error = res.error;
    if (error != null) {
      logger.w('Error getting points: $error');
      throw Exception(error);
    } else {
      final spots = <Spot>[];
      for (final e in res.data as List<dynamic>) {
        spots.add(Spot.fromJson(e as Map<String, dynamic>));
      }
      // Update State
      state = state.copyWith(spots: spots);
      return state.spots;
    }
  }

  Future<void> getCategory() async{
    final res = await supabase.client.from('category').select().execute();
    final error = res.error;
    if (error != null) {
      logger.w('Error getting category: $error');
      throw Exception(error);
    } else {
      final categories = <Category>[];
      for (final e in res.data as List<dynamic>) {
        categories.add(Category.fromJson(e as Map<String,dynamic>));
      }
      // Update State
      state = state.copyWith(categories: categories);
    }
  }

  Future<void> signOut() async {
    final res = await supabase.client.auth.signOut();
    if (res.error != null) {
      logger.w('Error signing out: ${res.error!.message}');
      throw Exception(res.error!.message);
    } else {
      logger.i('Signed out');
    }
  }

  sb.User? getCurrentUser() {
    state = state.copyWith(user: supabase.client.auth.currentUser);
    return state.user;
  }
}

final supabaseStateNotifier =
    StateNotifierProvider<SupabaseStateNotifier, SupabaseModel>((ref) {
  return SupabaseStateNotifier(ref.watch(supabaseProvider));
});
