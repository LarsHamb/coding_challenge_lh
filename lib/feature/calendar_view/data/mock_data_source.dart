import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models/location.dart';
import '../domain/models/booking.dart';

class MockDataSource {
  static const String _mockJsonPath = 'assets/fixtures/mock.json';

  Future<Map<String, dynamic>> _loadMockData() async {
    final String jsonString = await rootBundle.loadString(_mockJsonPath);
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<List<Location>> getLocations() async {
    try {
      final data = await _loadMockData();
      final locationsJson = data['locations'] as List<dynamic>;
      
      return locationsJson
          .map((locationJson) => Location.fromJson(locationJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load locations: $e');
    }
  }

  Future<List<Booking>> getBookings() async {
    try {
      final data = await _loadMockData();
      final bookingsJson = data['bookings'] as List<dynamic>;
      
      return bookingsJson
          .map((bookingJson) => Booking.fromJson(bookingJson as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load bookings: $e');
    }
  }
}
