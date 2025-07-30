import '../../domain/models/location.dart';
import '../../domain/models/booking.dart';

abstract class LocationRepository {
  /// Get all locations
  Future<List<Location>> getLocations();
  
  /// Get all bookings
  Future<List<Booking>> getBookings();
  
  /// Clear cached data
  Future<void> clearCache();
  
  /// Check if data is cached
  bool get hasCachedData;
}
