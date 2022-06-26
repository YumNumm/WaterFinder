import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import '../model/supabase_service_model.dart';

// ダミーのProviderを用意する
final supabaseProvider = Provider<Supabase>((ref) {
  debugPrint('run isarprovider');
  throw UnimplementedError('Supabase is not loaded');
});

class SupabaseStateNotifier extends StateNotifier<SupabaseModel> {
  SupabaseStateNotifier(this.supabase)
      : super(SupabaseModel(supabase: supabase));
  final Supabase supabase;

 
}

final supabaseStateNotifier =
    StateNotifierProvider<SupabaseStateNotifier, SupabaseModel>((ref) {
  return SupabaseStateNotifier(ref.watch(supabaseProvider));
});
