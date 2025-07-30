import '../models/booking.dart';

abstract class BookingRepository {
  /// Get all bookings
  Future<List<Booking>> getBookings();
  
  /// Get bookings for a specific room
  Future<List<Booking>> getBookingsForRoom(String roomId);
  
  /// Get bookings for a specific date range
  Future<List<Booking>> getBookingsForDateRange(DateTime startDate, DateTime endDate);
  
  /// Create a new booking
  Future<Booking> createBooking(Booking booking);
  
  /// Update an existing booking
  Future<Booking> updateBooking(Booking booking);
  
  /// Delete a booking by ID
  Future<void> deleteBooking(String bookingId);
  
  /// Check if a time slot conflicts with existing bookings
  Future<bool> hasTimeConflict(String roomId, DateTime start, DateTime end, {String? excludeBookingId});
}
