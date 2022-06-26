import 'package:flutter_map/flutter_map.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:location/location.dart';

part 'map_service_model.freezed.dart';

@freezed
class MapModel with _$MapModel {
  const factory MapModel({
    required MapController mapController,
    required LocationData? currentLocation,
    required bool liveUpdate,
    required double zoomLevel,
    required List<Marker> markers,
  }) = _MapModel;
}
