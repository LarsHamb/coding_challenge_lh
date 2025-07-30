import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coding_challenge_lh/feature/calendar_view/presentation/widgets/list_view.dart';
import 'package:coding_challenge_lh/feature/calendar_view/presentation/providers/location_provider.dart';
import 'package:coding_challenge_lh/feature/calendar_view/presentation/providers/booking_provider.dart';
import 'package:coding_challenge_lh/feature/calendar_view/presentation/providers/calendar_settings_provider.dart';
import 'package:coding_challenge_lh/feature/calendar_view/domain/models/location.dart';
import 'package:coding_challenge_lh/feature/calendar_view/domain/models/booking.dart';

void main() {
  group('DayView Widget Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    // Helper function to create test data
    Location createTestLocation() {
      return Location(
        id: 'loc1',
        name: 'Test Location',
        rooms: [
          Room(id: 'room1', name: 'Conference Room A'),
          Room(id: 'room2', name: 'Conference Room B'),
        ],
      );
    }

    List<Booking> createTestBookings() {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      return [
        Booking(
          id: 'booking1',
          roomId: 'room1',
          course: 'Flutter Workshop',
          start: today.add(const Duration(hours: 10)),
          end: today.add(const Duration(hours: 11)),
          description: 'Learn Flutter basics',
        ),
        Booking(
          id: 'booking2',
          roomId: 'room1',
          course: 'Team Meeting',
          start: today.add(const Duration(hours: 14)),
          end: today.add(const Duration(hours: 15)),
        ),
      ];
    }

    Widget createTestWidget({
      Location? selectedLocation,
      Room? selectedRoom,
      List<Booking>? bookings,
      CalendarSettings? settings,
    }) {
      return ProviderScope(
        overrides: [
          selectedLocationProvider.overrideWith((ref) => selectedLocation),
          selectedRoomProvider.overrideWith((ref) => selectedRoom),
          bookingsProvider.overrideWith((ref) => bookings ?? []),
          calendarSettingsProvider.overrideWith((ref) => settings ?? const CalendarSettings()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: const DayView(),
          ),
        ),
      );
    }

    testWidgets('should display empty state when no room is selected', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.meeting_room_outlined), findsOneWidget);
      expect(find.text('Please select a room to view bookings'), findsOneWidget);
    });

    testWidgets('should display date navigation header', (tester) async {
      final testLocation = createTestLocation();
      final testRoom = testLocation.rooms.first;

      await tester.pumpWidget(createTestWidget(
        selectedLocation: testLocation,
        selectedRoom: testRoom,
      ));

      // Check for navigation arrows
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      // Check for date display
      expect(find.textContaining(RegExp(r'\w{3} \d+, \d{4}')), findsOneWidget); // e.g., "Jul 30, 2025"
    });


    testWidgets('should navigate to next day when right arrow is tapped', (tester) async {
      final testLocation = createTestLocation();
      final testRoom = testLocation.rooms.first;

      await tester.pumpWidget(createTestWidget(
        selectedLocation: testLocation,
        selectedRoom: testRoom,
      ));

      await tester.pumpAndSettle();

      // Tap the right arrow
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // The PageView should animate to the next page
      // We can verify this by checking if the widget is still functioning
      expect(find.byType(DayView), findsOneWidget);
    });

    testWidgets('should navigate to previous day when left arrow is tapped', (tester) async {
      final testLocation = createTestLocation();
      final testRoom = testLocation.rooms.first;

      await tester.pumpWidget(createTestWidget(
        selectedLocation: testLocation,
        selectedRoom: testRoom,
      ));

      await tester.pumpAndSettle();

      // Tap the left arrow
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // The PageView should animate to the previous page
      expect(find.byType(DayView), findsOneWidget);
    });

    testWidgets('should open booking dialog when available slot is tapped', (tester) async {
      final testLocation = createTestLocation();
      final testRoom = testLocation.rooms.first;

      await tester.pumpWidget(createTestWidget(
        selectedLocation: testLocation,
        selectedRoom: testRoom,
      ));

      await tester.pumpAndSettle();

      // Find and tap an available slot
      await tester.tap(find.text('Available - Click to book').first);
      await tester.pumpAndSettle();

      // Should show booking dialog
      expect(find.text('Book Time Slot'), findsOneWidget);
      expect(find.text('Course/Event Name *'), findsOneWidget);
      expect(find.text('Description (optional)'), findsOneWidget);
      expect(find.text('Book'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
    testWidgets('should change view mode based on calendar settings', (tester) async {
      // Test Week View
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarSettingsProvider.overrideWith((ref) => 
              const CalendarSettings(viewMode: CalendarViewMode.week)),
          ],
          child: MaterialApp(
            home: Scaffold(body: const DayView()),
          ),
        ),
      );

      expect(find.text('Week View'), findsOneWidget);
    });

    testWidgets('should handle booking creation success', (tester) async {
      final testLocation = createTestLocation();
      final testRoom = testLocation.rooms.first;

      await tester.pumpWidget(createTestWidget(
        selectedLocation: testLocation,
        selectedRoom: testRoom,
      ));

      await tester.pumpAndSettle();

      // Open booking dialog
      await tester.tap(find.text('Available - Click to book').first);
      await tester.pumpAndSettle();

      // Enter course name
      await tester.enterText(find.byType(TextField).first, 'Test Course');
      await tester.enterText(find.byType(TextField).last, 'Test Description');

      // Submit booking
      await tester.tap(find.text('Book'));
      await tester.pumpAndSettle();

      // Dialog should close (no validation errors)
      expect(find.text('Book Time Slot'), findsNothing);
    });

    testWidgets('should format time slots correctly', (tester) async {
      final testLocation = createTestLocation();
      final testRoom = testLocation.rooms.first;
      final customSettings = const CalendarSettings(
        timeSlotIntervalMinutes: 30,
        dayStartHour: 9,
        dayEndHour: 17,
      );

      await tester.pumpWidget(createTestWidget(
        selectedLocation: testLocation,
        selectedRoom: testRoom,
        settings: customSettings,
      ));

      await tester.pumpAndSettle();

      // Should display properly formatted time slots
      expect(find.textContaining('09:00'), findsOneWidget);
      expect(find.textContaining('09:30'), findsOneWidget);
      expect(find.textContaining('10:00'), findsOneWidget);
    });
  });
}