import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_service_model.freezed.dart';

@freezed
class SupabaseModel with _$SupabaseModel {
  const factory SupabaseModel({
    required Supabase supabase,
    required User? user,
  }) = _SupabaseModel;
}
