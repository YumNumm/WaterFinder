import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waterfinder/schema/category.dart';
import 'package:waterfinder/schema/spot.dart';

part 'supabase_service_model.freezed.dart';

@freezed
class SupabaseModel with _$SupabaseModel {
  const factory SupabaseModel({
    required Supabase supabase,
    required User? user,
    required List<Spot> spots,
    required List<Category> categories,
  }) = _SupabaseModel;
}
