import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:waterfinder/provider/map_provider.dart';
import 'package:waterfinder/provider/supabase_provider.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              ref.read(supabaseStateNotifier.notifier).signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  ref.read(mapStateNotifier.notifier).addMarker(
                        Marker(
                          point: LatLng(35, 135),
                          builder: (context) => const Text('A'),
                        ),
                      );
                  //ref.read(mapStateNotifier.notifier).clearMarker();
                },
              );
            },
          ),
        ],
      ),
      body: const FlutterMapWidget(),
    );
  }
}

class FlutterMapWidget extends HookConsumerWidget {
  const FlutterMapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapStateNotifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapStateNotifier.notifier).initLocationService();
    });

    return FlutterMap(
      mapController: mapState.mapController,
      options: MapOptions(
        center: LatLng(35, 135),
        zoom: 8,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          tileProvider: NetworkTileProvider(),
        ),
        MarkerLayerOptions(
          markers: mapState.markers,
        )
      ],
      nonRotatedChildren: [
        AttributionWidget.defaultWidget(
          source: 'OpenStreetMap contributors',
          onSourceTapped: () {},
        ),
      ],
    );
  }
}
