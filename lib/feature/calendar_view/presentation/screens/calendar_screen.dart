import 'package:coding_challenge_lh/feature/calendar_view/domain/models/location.dart';
import 'package:coding_challenge_lh/feature/calendar_view/presentation/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/location_side_menu.dart';
import '../widgets/list_view.dart';
import 'calendar_settings_screen.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocation = ref.watch(selectedLocationProvider);
    final selectedRoom = ref.watch(selectedRoomProvider);
    final availableRooms = ref.watch(availableRoomsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      appBar: AppBar(
        title: Text(selectedLocation?.name ?? 'Select Location'),
        actions: [
          if (selectedLocation != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: RommSelectionWidget(availableRooms: availableRooms, selectedRoom: selectedRoom),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CalendarSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const LocationSideMenu(),
      body: const DayView(),
    );
  }
}

class RommSelectionWidget extends ConsumerWidget {
  const RommSelectionWidget({
    super.key,
    required this.availableRooms,
    required this.selectedRoom,
  });

  final List<Room> availableRooms;
  final Room? selectedRoom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (roomId) {
        final room = availableRooms.firstWhere((r) => r.id == roomId);
        ref.read(selectedRoomProvider.notifier).state = room;
      },
      itemBuilder: (context) => availableRooms
          .map((room) => PopupMenuItem<String>(
                value: room.id,
                child: Row(
                  children: [
                    Icon(
                      Icons.meeting_room,
                      color: selectedRoom?.id == room.id
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      room.name,
                      style: TextStyle(
                        fontWeight: selectedRoom?.id == room.id
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selectedRoom?.id == room.id
                            ? Colors.blue
                            : Colors.black,
                      ),
                    ),
                    if (selectedRoom?.id == room.id)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.check,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.meeting_room,
              color: selectedRoom != null ? Colors.blue : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              selectedRoom?.name ?? 'Select Room',
              style: TextStyle(
                color: selectedRoom != null ? Colors.blue : Colors.grey,
                fontWeight: selectedRoom != null 
                    ? FontWeight.w500 
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: selectedRoom != null ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
