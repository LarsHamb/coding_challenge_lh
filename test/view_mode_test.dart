import 'package:flutter_test/flutter_test.dart';
import 'package:coding_challenge_lh/feature/calendar_view/presentation/providers/calendar_settings_provider.dart';

void main() {
  group('Calendar View Mode Tests', () {
    test('should have correct display names', () {
      expect(CalendarViewMode.list.displayName, equals('List View'));
      expect(CalendarViewMode.week.displayName, equals('Week View'));
    });

    test('should create settings with default list view mode', () {
      const settings = CalendarSettings();
      expect(settings.viewMode, equals(CalendarViewMode.list));
    });

    test('should update view mode with copyWith', () {
      const originalSettings = CalendarSettings();
      final updatedSettings = originalSettings.copyWith(
        viewMode: CalendarViewMode.week,
      );

      expect(updatedSettings.viewMode, equals(CalendarViewMode.week));
      expect(updatedSettings.timeSlotIntervalMinutes, equals(originalSettings.timeSlotIntervalMinutes));
    });

    test('should have all view modes available', () {
      final allModes = CalendarViewMode.values;
      expect(allModes.length, equals(3));
      expect(allModes, contains(CalendarViewMode.list));
      expect(allModes, contains(CalendarViewMode.week));
    });
  });
}
