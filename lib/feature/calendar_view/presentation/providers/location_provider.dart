import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/time_slot.dart';
import '../../domain/models/location.dart';
import '../../domain/models/booking.dart';
import '../../domain/repositories/location_repository.dart';
import '../../providers/repository_provider.dart';
import 'calendar_settings_provider.dart';
import 'booking_provider.dart';

// State class to hold the location data
class LocationState {
  final List<Location> locations;
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;

  const LocationState({
    this.locations = const [],
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    List<Location>? locations,
    List<Booking>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      locations: locations ?? this.locations,
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier class to manage the location state
class LocationNotifier extends StateNotifier<LocationState> {
  final LocationRepository _repository;

  LocationNotifier(this._repository) : super(const LocationState()) {
    initialize();
  }

  /// Initialize the provider by loading data from repository
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load locations and bookings from repository
      final results = await Future.wait([
        _repository.getLocations(),
        _repository.getBookings(),
      ]);

      final locations = results[0] as List<Location>;
      final bookings = results[1] as List<Booking>;

      state = state.copyWith(
        locations: locations,
        bookings: bookings,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        locations: [],
        bookings: [],
      );
    }
  }

  /// Get all rooms from all locations
  List<Room> getAllRooms() {
    return state.locations.expand((location) => location.rooms).toList();
  }

  /// Get bookings for a specific room
  List<Booking> getBookingsForRoom(String roomId) {
    return state.bookings.where((booking) => booking.roomId == roomId).toList();
  }

  /// Get location by room ID
  Location? getLocationByRoomId(String roomId) {
    for (final location in state.locations) {
      if (location.rooms.any((room) => room.id == roomId)) {
        return location;
      }
    }
    return null;
  }

  /// Refresh data
  Future<void> refresh() async {
    await initialize();
  }

  /// Clear cache and refresh data
  Future<void> clearCacheAndRefresh() async {
    await _repository.clearCache();
    await initialize();
  }

  /// Check if repository has cached data
  bool get hasCachedData => _repository.hasCachedData;
}

// Provider instance
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    final repository = ref.watch(locationRepositoryProvider);
    return LocationNotifier(repository);
  },
);

// Convenience providers for specific data
final locationsProvider = Provider<List<Location>>((ref) {
  return ref.watch(locationProvider).locations;
});

final bookingsProvider = Provider<List<Booking>>((ref) {
  return ref.watch(locationProvider).bookings;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(locationProvider).isLoading;
});

final errorProvider = Provider<String?>((ref) {
  return ref.watch(locationProvider).error;
});

// Cache status provider
final cacheStatusProvider = Provider<bool>((ref) {
  final notifier = ref.watch(locationProvider.notifier);
  return notifier.hasCachedData;
});

// Combined bookings provider (mock + user bookings)
final combinedBookingsProvider = Provider<List<Booking>>((ref) {
  final mockBookings = ref.watch(bookingsProvider);
  final userBookings = ref.watch(bookingsListProvider);
  
  // Combine mock bookings with user-created bookings
  return [...mockBookings, ...userBookings];
});

// Selection providers
final selectedLocationProvider = StateProvider<Location?>((ref) => null);
final selectedRoomProvider = StateProvider<Room?>((ref) => null);
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Filtered rooms provider based on selected location
final availableRoomsProvider = Provider<List<Room>>((ref) {
  final selectedLocation = ref.watch(selectedLocationProvider);
  if (selectedLocation == null) return [];
  return selectedLocation.rooms;
});

// Filtered bookings provider based on selected room and date
final dayBookingsProvider = Provider<List<Booking>>((ref) {
  final selectedRoom = ref.watch(selectedRoomProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final allBookings = ref.watch(combinedBookingsProvider); // Use combined bookings
  
  if (selectedRoom == null) return [];
  
  return allBookings.where((booking) {
    return booking.roomId == selectedRoom.id &&
           booking.start.year == selectedDate.year &&
           booking.start.month == selectedDate.month &&
           booking.start.day == selectedDate.day;
  }).toList();
});

// Time slots provider that generates slots for the selected date
final timeSlotsProvider = Provider<List<TimeSlot>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final dayBookings = ref.watch(dayBookingsProvider);
  final settings = ref.watch(calendarSettingsProvider);
  
  return _generateTimeSlots(selectedDate, dayBookings, settings);
});

// Helper function to generate time slots
List<TimeSlot> _generateTimeSlots(DateTime date, List<Booking> bookings, CalendarSettings settings) {
  final slots = <TimeSlot>[];
  
  // Create base date for the selected day
  final baseDate = DateTime(date.year, date.month, date.day);
  
  // Generate slots from dayStartHour to dayEndHour
  final totalMinutes = (settings.dayEndHour - settings.dayStartHour) * 60;
  final totalSlots = totalMinutes ~/ settings.timeSlotIntervalMinutes;
  
  for (int i = 0; i < totalSlots; i++) {
    final startMinutes = (settings.dayStartHour * 60) + (i * settings.timeSlotIntervalMinutes);
    final endMinutes = startMinutes + settings.timeSlotIntervalMinutes;
    
    final startTime = baseDate.add(Duration(minutes: startMinutes));
    final endTime = baseDate.add(Duration(minutes: endMinutes));
    
    // Check if this slot overlaps with any booking
    final overlappingBooking = bookings.where((booking) {
      return (startTime.isBefore(booking.end) && endTime.isAfter(booking.start));
    }).firstOrNull;
    
    slots.add(TimeSlot(
      startTime: startTime,
      endTime: endTime,
      isBooked: overlappingBooking != null,
      booking: overlappingBooking,
    ));
  }
  
  return slots;
}
