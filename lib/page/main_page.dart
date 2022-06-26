// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:waterfinder/provider/map_provider.dart';
import 'package:waterfinder/provider/supabase_provider.dart';
import 'package:waterfinder/schema/category.dart';
import 'package:waterfinder/schema/spot.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supabaseStateNotifier.notifier).getCurrentUser();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Do you want to Signout?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        ref.read(supabaseStateNotifier.notifier).signOut();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              );
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
              //ref.read(mapStateNotifier.notifier).clearMarker();
            },
          ),
        ],
      ),
      floatingActionButton: const Fabwidgets(),
      body: const FlutterMapWidget(),
    );
  }
}

class Fabwidgets extends HookConsumerWidget {
  const Fabwidgets({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapStateNotifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reload FAB
        FloatingActionButton(
          child: const Icon(Icons.restore_page),
          onPressed: () async {
            final spots =
                await ref.read(supabaseStateNotifier.notifier).getPoints();
            await ref.read(supabaseStateNotifier.notifier).getCategory();
            final categories = ref.read(supabaseStateNotifier).categories;
            final markers = <Marker>[];
            for (final spot in spots) {
              markers.add(
                Marker(
                  point: LatLng(spot.lat, spot.lon),
                  builder: (context) => GestureDetector(
                    onTap: () {
                      final category = categories.firstWhere(
                        (e) => e.id == spot.categoryId,
                        orElse: () => const Category(
                          id: -1,
                          name: 'Unknown',
                        ),
                      );
                      showDialog<void>(
                        context: context,
                        builder: (context) => SimpleDialog(
                          title: const Text('Water Spot Information'),
                          children: [
                            Text('Name: ${spot.title}'),
                            Text('Description: ${spot.describe}'),
                            Text('Category: ${category.name}'),
                          ],
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              );
            }

            ref.read(mapStateNotifier.notifier).updateAllMarker(markers);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Water Spots are loaded (N=${mapState.markers.length})',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Map Live Location FAB
        FloatingActionButton(
          heroTag: 'LiveUpdate',
          enableFeedback: true,
          tooltip:
              '${(mapState.liveUpdate) ? "Enable" : "Disable"} Live Location',
          onPressed: () {
            ref.read(mapStateNotifier.notifier).switchLiveUpdate();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${(!mapState.liveUpdate) ? "Enabled" : "Disabled"} '
                  'Location Automatic Update',
                ),
              ),
            );
          },
          child: Icon(
            (mapState.liveUpdate) ? Icons.location_on : Icons.location_off,
          ),
        ),
      ],
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
      // Start Tap position Stream
    });

    return FlutterMap(
      mapController: mapState.mapController,
      options: MapOptions(
        center: LatLng(35, 135),
        zoom: 8,
        interactiveFlags: InteractiveFlag.pinchMove |
            InteractiveFlag.pinchZoom |
            InteractiveFlag.drag |
            InteractiveFlag.doubleTapZoom |
            InteractiveFlag.flingAnimation,
        onLongPress: (position, point) {
          // Show input Form
          showDialog<void>(
            context: context,
            builder: (ctx) => SpotDataInputDialog(
              latlong: point,
            ),
          );

          // ref.read(supabaseStateNotifier.notifier).addSpot();
        },
      ),
      layers: [
        TileLayerOptions(
          // TODO(YumNumm): Change to Mapbox tile server
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          tileProvider: NetworkTileProvider(),
        ),
        MarkerLayerOptions(
          markers: mapState.markers,
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              point: LatLng(
                mapState.currentLocation?.latitude ?? 0,
                mapState.currentLocation?.longitude ?? 0,
              ),
              builder: (_) => const Icon(Icons.location_on),
            )
          ],
        )
      ],
      nonRotatedChildren: [
        AttributionWidget.defaultWidget(
          source: 'OpenStreetMap',
          onSourceTapped: () {},
          alignment: Alignment.bottomLeft,
        ),
      ],
    );
  }
}

class SpotDataInputDialog extends HookConsumerWidget {
  const SpotDataInputDialog({
    required this.latlong,
    super.key,
  });

  final LatLng latlong;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleState = useState('');
    final descriptionState = useState('');

    return AlertDialog(
      title: const Text('Add Water Spot'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            onChanged: (str) => titleState.value = str,
            decoration: const InputDecoration(
              labelText: 'Title',
            ),
          ),
          TextFormField(
            onChanged: (str) => descriptionState.value = str,
            decoration: const InputDecoration(
              labelText: 'Description',
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.cancel),
          label: const Text('Cancel'),
        ),
        TextButton.icon(
          onPressed: () async {
            await showGeneralDialog(
              context: context,
              barrierDismissible: false,
              transitionDuration: Duration.zero, // これを入れると遅延を入れなくて
              barrierColor: Colors.black.withOpacity(0.5),
              pageBuilder: (
                BuildContext context,
                _,
                __,
              ) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              },
            );
            await ref.read(supabaseStateNotifier.notifier).addSpot(
                  Spot(
                    id: 0,
                    categoryId: 1,
                    title: titleState.value,
                    describe: descriptionState.value,
                    lat: latlong.latitude,
                    lon: latlong.longitude,
                    pictureUrl: null,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    createdUserId:
                        ref.read(supabaseStateNotifier).user?.id ?? '',
                  ),
                );
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.send),
          label: const Text('ADD'),
        ),
      ],
    );
  }
}
