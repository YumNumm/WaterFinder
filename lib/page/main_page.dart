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
    final mapState = ref.watch(mapStateNotifier);

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
        ],
      ),
      body: FlutterMapWidget(mapController: mapState.mapController),
    );
  }
}

class FlutterMapWidget extends StatefulHookConsumerWidget {
  const FlutterMapWidget({
    super.key,
    required this.mapController,
  });

  final MapController mapController;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FlutterMapWidgetState();
}

class _FlutterMapWidgetState extends ConsumerState<FlutterMapWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FlutterMap(
      mapController: widget.mapController,
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
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
