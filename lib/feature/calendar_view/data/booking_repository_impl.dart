import '../domain/repositories/booking_repository.dart';
import '../domain/models/booking.dart';
import 'booking_mock_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingMockDataSource _dataSource;
  
  BookingRepositoryImpl(this._dataSource);
  
  @override
  Future<List<Booking>> getBookings() async {
    return await _dataSource.getBookings();
  }
  
  @override
  Future<List<Booking>> getBookingsForRoom(String roomId) async {
    return await _dataSource.getBookingsForRoom(roomId);
  }
  
  @override
  Future<List<Booking>> getBookingsForDateRange(DateTime startDate, DateTime endDate) async {
    return await _dataSource.getBookingsForDateRange(startDate, endDate);
  }
  
  @override
  Future<Booking> createBooking(Booking booking) async {
    // Validate booking data
    if (booking.roomId.isEmpty) {
      throw ArgumentError('Room ID cannot be empty');
    }
    
    if (booking.course.isEmpty) {
      throw ArgumentError('Course cannot be empty');
    }
    
    if (booking.start.isAfter(booking.end)) {
      throw ArgumentError('Start time must be before end time');
    }
    
    // Check for conflicts
    final hasConflict = await hasTimeConflict(
      booking.roomId, 
      booking.start, 
      booking.end,
    );
    
    if (hasConflict) {
      throw Exception('Time slot conflicts with existing booking');
    }
    
    return await _dataSource.createBooking(booking);
  }
  
  @override
  Future<Booking> updateBooking(Booking booking) async {
    // Validate booking data
    if (booking.id.isEmpty) {
      throw ArgumentError('Booking ID cannot be empty');
    }
    
    if (booking.roomId.isEmpty) {
      throw ArgumentError('Room ID cannot be empty');
    }
    
    if (booking.course.isEmpty) {
      throw ArgumentError('Course cannot be empty');
    }
    
    if (booking.start.isAfter(booking.end)) {
      throw ArgumentError('Start time must be before end time');
    }
    
    // Check for conflicts (excluding current booking)
    final hasConflict = await hasTimeConflict(
      booking.roomId, 
      booking.start, 
      booking.end,
      excludeBookingId: booking.id,
    );
    
    if (hasConflict) {
      throw Exception('Time slot conflicts with existing booking');
    }
    
    return await _dataSource.updateBooking(booking);
  }
  
  @override
  Future<void> deleteBooking(String bookingId) async {
    if (bookingId.isEmpty) {
      throw ArgumentError('Booking ID cannot be empty');
    }
    
    return await _dataSource.deleteBooking(bookingId);
  }
  
  @override
  Future<bool> hasTimeConflict(String roomId, DateTime start, DateTime end, {String? excludeBookingId}) async {
    return await _dataSource.hasTimeConflict(roomId, start, end, excludeBookingId: excludeBookingId);
  }
  
  /// Additional helper methods
  
  /// Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    return await _dataSource.getBookingById(bookingId);
  }
  
  /// Get total bookings count
  Future<int> getBookingsCount() async {
    return await _dataSource.getBookingsCount();
  }
  
  /// Clear all bookings (for testing)
  Future<void> clearAllBookings() async {
    return await _dataSource.clearAllBookings();
  }
}
