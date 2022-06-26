import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:logger/logger.dart';
import 'package:waterfinder/model/map_service_model.dart';

class MapStateNotifier extends StateNotifier<MapModel> {
  MapStateNotifier()
      : super(
          MapModel(
            currentLocation: null,
            mapController: MapController(),
            liveUpdate: true,
            zoomLevel: 8,
            markers: [],
          ),
        );

  final Location locationService = Location();
  final Logger logger = Logger();

  Future<void> initLocationService() async {
    await locationService.changeSettings();

    LocationData? location;
    bool serviceEnabled;
    bool serviceRequestResult;

    try {
      serviceEnabled = await locationService.serviceEnabled();

      if (serviceEnabled) {
        final permission = await locationService.requestPermission();

        if (permission == PermissionStatus.granted) {
          location = await locationService.getLocation();
          state.copyWith(currentLocation: location);
          locationService.onLocationChanged.listen((LocationData result) async {
            if (mounted) {
              state.copyWith(currentLocation: location);
              // If Live Update is enabled, move map center
              if (state.liveUpdate) {
                state.mapController.move(
                  LatLng(result.latitude ?? 35, result.longitude ?? 135),
                  state.zoomLevel,
                );
              }
            }
          });
        }
      } else {
        serviceRequestResult = await locationService.requestService();
        if (serviceRequestResult) {
          await initLocationService();
          return;
        }
      }
    } on PlatformException catch (e) {
      logger.i(e.toString());
      location = null;
    }
  }

  void addMarker(Marker marker) =>
      state = state.copyWith(markers: [...state.markers, marker]);

  void clearMarker() => state = state.copyWith(markers: []);
}

final mapStateNotifier =
    StateNotifierProvider<MapStateNotifier, MapModel>((ref) {
  return MapStateNotifier();
});
