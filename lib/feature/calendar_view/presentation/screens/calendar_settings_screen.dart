import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/calendar_settings_provider.dart';

class CalendarSettingsScreen extends ConsumerWidget {
  const CalendarSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(calendarSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'View Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // View mode setting
            ListTile(
              title: const Text('Calendar View Mode'),
              subtitle: Text(settings.viewMode.displayName),
              trailing: DropdownButton<CalendarViewMode>(
                value: settings.viewMode,
                items: CalendarViewMode.values.map((CalendarViewMode mode) {
                  return DropdownMenuItem<CalendarViewMode>(
                    value: mode,
                    child: Text(mode.displayName),
                  );
                }).toList(),
                onChanged: (CalendarViewMode? newValue) {
                  if (newValue != null) {
                    ref.read(calendarSettingsProvider.notifier).state = 
                        settings.copyWith(viewMode: newValue);
                  }
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Time Slot Configuration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Time slot interval setting
            ListTile(
              title: const Text('Time Slot Interval'),
              subtitle: Text('${settings.timeSlotIntervalMinutes} minutes'),
              trailing: DropdownButton<int>(
                value: settings.timeSlotIntervalMinutes,
                items: [5, 10, 15, 30, 60].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value min'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    ref.read(calendarSettingsProvider.notifier).state = 
                        settings.copyWith(timeSlotIntervalMinutes: newValue);
                  }
                },
              ),
            ),
            
            const Divider(),
            
            // Day start hour setting
            ListTile(
              title: const Text('Day Start Time'),
              subtitle: Text('${settings.dayStartHour}:00'),
              trailing: DropdownButton<int>(
                value: settings.dayStartHour,
                items: List.generate(24, (index) => index).map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('${value.toString().padLeft(2, '0')}:00'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null && newValue < settings.dayEndHour) {
                    ref.read(calendarSettingsProvider.notifier).state = 
                        settings.copyWith(dayStartHour: newValue);
                  }
                },
              ),
            ),
            
            const Divider(),
            
            // Day end hour setting
            ListTile(
              title: const Text('Day End Time'),
              subtitle: Text('${settings.dayEndHour}:00'),
              trailing: DropdownButton<int>(
                value: settings.dayEndHour,
                items: List.generate(24, (index) => index + 1).map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('${value.toString().padLeft(2, '0')}:00'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null && newValue > settings.dayStartHour) {
                    ref.read(calendarSettingsProvider.notifier).state = 
                        settings.copyWith(dayEndHour: newValue);
                  }
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Preview',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total time slots per day: ${_calculateTotalSlots(settings)}',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                  Text(
                    'Operating hours: ${settings.dayStartHour}:00 - ${settings.dayEndHour}:00',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotalSlots(CalendarSettings settings) {
    final totalMinutes = (settings.dayEndHour - settings.dayStartHour) * 60;
    return totalMinutes ~/ settings.timeSlotIntervalMinutes;
  }
}
