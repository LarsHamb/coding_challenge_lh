import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum for different view modes
enum CalendarViewMode {
  list('List View'),
  compact('Compact View'),
  week('Week View');

  const CalendarViewMode(this.displayName);
  final String displayName;
}

// Settings for the calendar view
class CalendarSettings {
  final int timeSlotIntervalMinutes;
  final int dayStartHour;
  final int dayEndHour;
  final CalendarViewMode viewMode;

  const CalendarSettings({
    this.timeSlotIntervalMinutes = 30,
    this.dayStartHour = 6, // 6 AM
    this.dayEndHour = 22, // 10 PM
    this.viewMode = CalendarViewMode.list,
  });

  CalendarSettings copyWith({
    int? timeSlotIntervalMinutes,
    int? dayStartHour,
    int? dayEndHour,
    CalendarViewMode? viewMode,
  }) {
    return CalendarSettings(
      timeSlotIntervalMinutes: timeSlotIntervalMinutes ?? this.timeSlotIntervalMinutes,
      dayStartHour: dayStartHour ?? this.dayStartHour,
      dayEndHour: dayEndHour ?? this.dayEndHour,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

// Settings provider
final calendarSettingsProvider = StateProvider<CalendarSettings>((ref) {
  return const CalendarSettings();
});
