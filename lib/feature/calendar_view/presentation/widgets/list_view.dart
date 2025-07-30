import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/calendar_settings_provider.dart';
import 'week_view.dart';

class DayView extends ConsumerStatefulWidget {
  const DayView({super.key});

  @override
  ConsumerState<DayView> createState() => _DayViewState();
}

class _DayViewState extends ConsumerState<DayView> {
  late PageController _pageController;
  static const int initialPage =
      1000; // Start from middle to allow infinite scrolling

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedRoom = ref.watch(selectedRoomProvider);
    final settings = ref.watch(calendarSettingsProvider);

    // Check view mode and render appropriate widget
    switch (settings.viewMode) {
      case CalendarViewMode.week:
        return const WeekView();
      case CalendarViewMode.list:
        return _buildListView(context, selectedDate, selectedRoom);
    }
  }

  Widget _buildListView(BuildContext context, DateTime selectedDate, dynamic selectedRoom) {

    return Column(
      children: [
        // Date navigation header
        Container(
          padding: const EdgeInsets.all(16),
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
                    _formatDate(selectedDate),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    _formatWeekday(selectedDate),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
        const Divider(height: 0),
        // Swipeable day content
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              final dayOffset = index - initialPage;
              final today = DateTime.now();
              final newDate = DateTime(
                today.year,
                today.month,
                today.day,
              ).add(Duration(days: dayOffset));
              ref.read(selectedDateProvider.notifier).state = newDate;
            },
            itemBuilder: (context, index) {
              final dayOffset = index - initialPage;
              final today = DateTime.now();
              final currentDate = DateTime(
                today.year,
                today.month,
                today.day,
              ).add(Duration(days: dayOffset));

              return _buildDayContent(context, currentDate, selectedRoom);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayContent(
    BuildContext context,
    DateTime date,
    dynamic selectedRoom,
  ) {
    if (selectedRoom == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Please select a room to view bookings',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Get time slots for this specific date
    final timeSlots = ref.watch(timeSlotsProvider);
    final locationState = ref.watch(locationProvider);

    return RefreshIndicator(
      onRefresh: () async {
        try {
          // Refresh the main location data (which includes bookings)
          await ref.read(locationProvider.notifier).refresh();

          // Invalidate related providers to force rebuild
          ref.invalidate(timeSlotsProvider);
          ref.invalidate(dayBookingsProvider);
          ref.invalidate(combinedBookingsProvider);
        } catch (e) {
          // Show error feedback
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
                    'Loading bookings...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = timeSlots[index];
                return _buildTimeSlotCard(context, timeSlot, selectedRoom);
              },
            ),
    );
  }

  Widget _buildTimeSlotCard(
    BuildContext context,
    dynamic timeSlot,
    dynamic selectedRoom,
  ) {
    final isBooked = timeSlot.isBooked;
    final startTime = timeSlot.startTime;
    final booking = timeSlot.booking;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: Material(
        color: isBooked ? Colors.blue[50] : Colors.grey[100],
        child: InkWell(
          onTap: isBooked
              ? null
              : () => _onTimeSlotTap(context, timeSlot, selectedRoom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Time display
                Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBooked ? Colors.blue[300]! : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _formatTimeSlot(startTime),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isBooked ? Colors.blue[700] : Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isBooked ? Colors.blue[100] : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isBooked ? Colors.blue[300]! : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: isBooked
                        ? InkWell(
                            onTap: () => _onBookedSlotTap(
                              context,
                              timeSlot,
                              selectedRoom,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        booking?.course ?? 'Booked',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (_isUserBooking(booking)) ...[
                                      Icon(
                                        Icons.person,
                                        color: Colors.green[600],
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                                if (booking != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatTime(booking.start)} - ${_formatTime(booking.end)}',
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (booking.description != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      booking.description!,
                                      style: TextStyle(
                                        color: Colors.blue[600],
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.blue,
                                size: 18,
                              ),
                              const Spacer(),
                              Text(
                                'Available - Click to book',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTimeSlotTap(
    BuildContext context,
    dynamic timeSlot,
    dynamic selectedRoom,
  ) {
    final TextEditingController courseController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, _) {
            final isBookingLoading = ref.watch(bookingLoadingProvider);
            final bookingError = ref.watch(bookingErrorProvider);

            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              title: const Text('Book Time Slot'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
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
                                Icon(
                                  Icons.meeting_room,
                                  color: Colors.blue[700],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Room: ${selectedRoom.name}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.blue[700],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Date: ${_formatDate(timeSlot.startTime)}',
                                  style: TextStyle(color: Colors.blue[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.blue[700],
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Time: ${_formatTime(timeSlot.startTime)} - ${_formatTime(timeSlot.endTime)}',
                                  style: TextStyle(color: Colors.blue[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: courseController,
                        decoration: const InputDecoration(
                          labelText: 'Course/Event Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event),
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      if (bookingError != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            border: Border.all(color: Colors.red[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  bookingError,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isBookingLoading
                      ? null
                      : () {
                          ref.read(bookingProvider.notifier).clearError();
                          Navigator.of(context).pop();
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isBookingLoading
                      ? null
                      : () async {
                          if (courseController.text.trim().isEmpty) {
                            ref
                                .read(bookingProvider.notifier)
                                .setError('Course name is required');
                            return;
                          }

                          final success = await ref
                              .read(bookingProvider.notifier)
                              .createBooking(
                                roomId: selectedRoom.id,
                                start: timeSlot.startTime,
                                end: timeSlot.endTime,
                                course: courseController.text.trim(),
                                description:
                                    descriptionController.text.trim().isEmpty
                                    ? null
                                    : descriptionController.text.trim(),
                              );

                          if (success) {
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Booking created for ${courseController.text.trim()}!',
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                  child: isBookingLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Book'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTimeSlot(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatWeekday(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[date.weekday - 1];
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(1, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  // Check if a booking was created by the user (has an ID from user bookings)
  bool _isUserBooking(dynamic booking) {
    if (booking == null) return false;
    final userBookings = ref.read(bookingsListProvider);
    return userBookings.any((userBooking) => userBooking.id == booking.id);
  }

  // Handle tapping on booked slots
  void _onBookedSlotTap(
    BuildContext context,
    dynamic timeSlot,
    dynamic selectedRoom,
  ) {
    final booking = timeSlot.booking;
    final isUserBooking = _isUserBooking(booking);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(booking?.course ?? 'Booking Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                        Icon(
                          Icons.meeting_room,
                          color: Colors.blue[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Room: ${selectedRoom.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.blue[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Date: ${_formatDate(timeSlot.startTime)}',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.blue[700],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Time: ${_formatTime(booking?.start ?? timeSlot.startTime)} - ${_formatTime(booking?.end ?? timeSlot.endTime)}',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                    if (booking?.description != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.description,
                            color: Colors.blue[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking!.description!,
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isUserBooking) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.green[700], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Your booking - You can delete this',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (isUserBooking) ...[
              Consumer(
                builder: (context, ref, _) {
                  final isDeleting = ref.watch(bookingLoadingProvider);
                  return TextButton(
                    onPressed: isDeleting
                        ? null
                        : () async {
                            final success = await ref
                                .read(bookingProvider.notifier)
                                .deleteBooking(booking!.id);
                            if (success) {
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Booking "${booking.course}" deleted',
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.orange,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: isDeleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Delete'),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}
