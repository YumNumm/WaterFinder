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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ref.read(mapStateNotifier.notifier).addMarker(
                    Marker(
                      point: LatLng(35, 135),
                      builder: (context) => const Text('A'),
                    ),
                  );
              ref.read(mapStateNotifier.notifier).clearMarker();
            },
          ),
        ],
      ),
      body: const FlutterMapWidget(),
    );
  }
}

class FlutterMapWidget extends StatefulHookConsumerWidget {
  const FlutterMapWidget({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FlutterMapWidgetState();
}

class _FlutterMapWidgetState extends ConsumerState<FlutterMapWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStateNotifier);

    super.build(context);
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
