import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';
import '../providers/calendar_settings_provider.dart';

class WeekView extends ConsumerStatefulWidget {
  const WeekView({super.key});

  @override
  ConsumerState<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends ConsumerState<WeekView> {
  late PageController _pageController;
  static const int initialPage = 1000; // Start from middle to allow infinite scrolling
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: initialPage);
    _currentWeekStart = _getWeekStart(DateTime.now());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Get the start of the week (Monday) for a given date
  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: dayOfWeek - 1));
  }

  // Get the end of the week (Sunday) for a given date
  DateTime _getWeekEnd(DateTime weekStart) {
    return weekStart.add(const Duration(days: 6));
  }

  @override
  Widget build(BuildContext context) {
    final selectedRoom = ref.watch(selectedRoomProvider);

    return Column(
      children: [
        // Week navigation header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Column(
                children: [
                  Text(
                    _formatWeekRange(_currentWeekStart),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Week View',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        // Swipeable week content
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              final weekOffset = index - initialPage;
              final newWeekStart = _getWeekStart(DateTime.now()).add(Duration(days: weekOffset * 7));
              setState(() {
                _currentWeekStart = newWeekStart;
              });
            },
            itemBuilder: (context, index) {
              final weekOffset = index - initialPage;
              final weekStart = _getWeekStart(DateTime.now()).add(Duration(days: weekOffset * 7));
              return _buildWeekContent(context, weekStart, selectedRoom);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekContent(BuildContext context, DateTime weekStart, dynamic selectedRoom) {
    if (selectedRoom == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Please select a room to view weekly bookings',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final locationState = ref.watch(locationProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await ref.read(locationProvider.notifier).refresh();
          ref.invalidate(combinedBookingsProvider);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Failed to refresh: $e')),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: locationState.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading weekly bookings...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _buildWeekGrid(context, weekStart, selectedRoom),
    );
  }

  Widget _buildWeekGrid(BuildContext context, DateTime weekStart, dynamic selectedRoom) {
    final settings = ref.watch(calendarSettingsProvider);
    final allBookings = ref.watch(combinedBookingsProvider);
    
    // Filter bookings for this week and room
    final weekEnd = _getWeekEnd(weekStart);
    final weekBookings = allBookings.where((booking) {
      return booking.roomId == selectedRoom.id &&
             booking.start.isBefore(weekEnd.add(const Duration(days: 1))) &&
             booking.end.isAfter(weekStart);
    }).toList();

    return Column(
      children: [
        // Days of week header
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              // Spacer for time column alignment
              Container(
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              // Days of the week
              ...List.generate(7, (index) {
                final day = weekStart.add(Duration(days: index));
                final isToday = _isSameDay(day, DateTime.now());
                
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: index < 6 ? BorderSide(color: Colors.grey[300]!) : BorderSide.none,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getWeekdayName(day.weekday),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isToday ? Colors.blue[700] : Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isToday ? Colors.blue[700] : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isToday ? Colors.white : Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        // Week grid with time slots and bookings
        Expanded(
          child: SingleChildScrollView(
            child: _buildTimeGrid(context, weekStart, weekBookings, settings),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeGrid(BuildContext context, DateTime weekStart, List bookings, CalendarSettings settings) {
    final timeSlots = _generateTimeSlots(settings);
    
    return Column(
      children: timeSlots.map((timeSlot) {
        return Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Row(
            children: [
              // Time label
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Center(
                  child: Text(
                    _formatTimeSlot(timeSlot),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      
                    ),
                  ),
                ),
              ),
              // Days grid
              Expanded(
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    final day = weekStart.add(Duration(days: dayIndex));
                    final dayBookings = _getBookingsForTimeSlot(bookings, day, timeSlot);
                    
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            right: dayIndex < 6 ? BorderSide(color: Colors.grey[200]!) : BorderSide.none,
                          ),
                        ),
                        child: _buildTimeSlotCell(context, day, timeSlot, dayBookings),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotCell(BuildContext context, DateTime day, DateTime timeSlot, List dayBookings) {
    final hasBooking = dayBookings.isNotEmpty;
    final booking = hasBooking ? dayBookings.first : null;
    
    return Container(
      height: double.infinity,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: hasBooking ? Colors.blue[100] : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: hasBooking ? () => _showBookingDetails(context, booking) : null,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: hasBooking
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        booking.course,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (booking.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          booking.description!,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.blue[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }

  List<DateTime> _generateTimeSlots(CalendarSettings settings) {
    final timeSlots = <DateTime>[];
    final baseDate = DateTime(2025, 1, 1); // Use a base date for time generation
    
    final totalMinutes = (settings.dayEndHour - settings.dayStartHour) * 60;
    final totalSlots = totalMinutes ~/ settings.timeSlotIntervalMinutes;
    
    for (int i = 0; i < totalSlots; i++) {
      final startMinutes = (settings.dayStartHour * 60) + (i * settings.timeSlotIntervalMinutes);
      final timeSlot = baseDate.add(Duration(minutes: startMinutes));
      timeSlots.add(timeSlot);
    }
    
    return timeSlots;
  }

  List _getBookingsForTimeSlot(List bookings, DateTime day, DateTime timeSlot) {
    final slotStart = DateTime(day.year, day.month, day.day, timeSlot.hour, timeSlot.minute);
    final settings = ref.read(calendarSettingsProvider);
    final slotEnd = slotStart.add(Duration(minutes: settings.timeSlotIntervalMinutes));
    
    return bookings.where((booking) {
      return booking.start.isBefore(slotEnd) && booking.end.isAfter(slotStart);
    }).toList();
  }

  void _showBookingDetails(BuildContext context, dynamic booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(booking.course),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${_formatTime(booking.start)} - ${_formatTime(booking.end)}'),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(booking.start)}'),
            if (booking.description != null) ...[
              const SizedBox(height: 8),
              Text('Description: ${booking.description}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatWeekRange(DateTime weekStart) {
    final weekEnd = _getWeekEnd(weekStart);
    final startMonth = _getMonthName(weekStart.month);
    final endMonth = _getMonthName(weekEnd.month);
    
    if (weekStart.month == weekEnd.month) {
      return '$startMonth ${weekStart.day}-${weekEnd.day}, ${weekStart.year}';
    } else {
      return '$startMonth ${weekStart.day} - $endMonth ${weekEnd.day}, ${weekStart.year}';
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatTimeSlot(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(1, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
