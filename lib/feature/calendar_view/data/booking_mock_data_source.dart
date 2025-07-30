import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models/booking.dart';

class BookingMockDataSource {
  // In-memory storage for bookings (simulating a database)
  final List<Booking> _bookings = [];
  bool _isInitialized = false;

  /// Initialize the data source with mock data
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Load initial bookings from mock.json
      final String jsonString = await rootBundle.loadString('assets/fixtures/mock.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      if (jsonData.containsKey('bookings')) {
        final List<dynamic> bookingsJson = jsonData['bookings'];
        _bookings.addAll(
          bookingsJson.map((json) => Booking.fromJson(json)).toList(),
        );
      }
      
      _isInitialized = true;
    } catch (e) {
      // If mock.json doesn't have bookings or fails to load, start with empty list
      _isInitialized = true;
    }
  }

  /// Get all bookings
  Future<List<Booking>> getBookings() async {
    await _initialize();
    return List.from(_bookings);
  }

  /// Get bookings for a specific room
  Future<List<Booking>> getBookingsForRoom(String roomId) async {
    await _initialize();
    return _bookings.where((booking) => booking.roomId == roomId).toList();
  }

  /// Get bookings for a specific date range
  Future<List<Booking>> getBookingsForDateRange(DateTime startDate, DateTime endDate) async {
    await _initialize();
    return _bookings.where((booking) {
      return booking.start.isBefore(endDate) && booking.end.isAfter(startDate);
    }).toList();
  }

  /// Create a new booking
  Future<Booking> createBooking(Booking booking) async {
    await _initialize();
    
    // Generate a unique ID if not provided
    final newBooking = booking.id.isEmpty 
        ? booking.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
        : booking;
    
    _bookings.add(newBooking);
    return newBooking;
  }

  /// Update an existing booking
  Future<Booking> updateBooking(Booking booking) async {
    await _initialize();
    
    final index = _bookings.indexWhere((b) => b.id == booking.id);
    if (index == -1) {
      throw Exception('Booking not found with id: ${booking.id}');
    }
    
    _bookings[index] = booking;
    return booking;
  }

  /// Delete a booking by ID
  Future<void> deleteBooking(String bookingId) async {
    await _initialize();
    
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw Exception('Booking not found with id: $bookingId');
    }
    
    _bookings.removeAt(index);
  }

  /// Check if a time slot conflicts with existing bookings
  Future<bool> hasTimeConflict(String roomId, DateTime start, DateTime end, {String? excludeBookingId}) async {
    await _initialize();
    
    return _bookings.any((booking) {
      if (booking.roomId != roomId) return false;
      if (excludeBookingId != null && booking.id == excludeBookingId) return false;
      
      // Check for overlap
      return start.isBefore(booking.end) && end.isAfter(booking.start);
    });
  }

  /// Clear all bookings (for testing purposes)
  Future<void> clearAllBookings() async {
    await _initialize();
    _bookings.clear();
  }

  /// Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    await _initialize();
    
    try {
      return _bookings.firstWhere((b) => b.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  /// Get bookings count
  Future<int> getBookingsCount() async {
    await _initialize();
    return _bookings.length;
  }
}
