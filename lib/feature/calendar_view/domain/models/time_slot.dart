import 'booking.dart';

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;
  final Booking? booking;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
    this.booking,
  });

  TimeSlot copyWith({
    DateTime? startTime,
    DateTime? endTime,
    bool? isBooked,
    Booking? booking,
  }) {
    return TimeSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
      booking: booking ?? this.booking,
    );
  }
}
