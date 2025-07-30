import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';

class LocationSideMenu extends ConsumerWidget {
  const LocationSideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);
    final locations = locationState.locations;

    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                'Select Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: locationState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : locationState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${locationState.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref
                                  .read(locationProvider.notifier)
                                  .refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final location = locations[index];
                          final isSelected = selectedLocation?.id == location.id;

                          return ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                            title: Text(
                              location.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              '${location.rooms.length} room${location.rooms.length != 1 ? 's' : ''}',
                            ),
                            selected: isSelected,
                            onTap: () {
                              ref.read(selectedLocationProvider.notifier).state = location;
                              // Reset room selection when location changes
                              ref.read(selectedRoomProvider.notifier).state = null;
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
