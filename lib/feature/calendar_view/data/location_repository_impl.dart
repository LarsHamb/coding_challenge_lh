import '../domain/repositories/location_repository.dart';
import '../domain/models/location.dart';
import '../domain/models/booking.dart';
import 'mock_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final MockDataSource _dataSource;
  
  // Cache variables
  List<Location>? _cachedLocations;
  List<Booking>? _cachedBookings;
  DateTime? _lastFetchTime;
  
  // Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  LocationRepositoryImpl(this._dataSource);
  
  @override
  bool get hasCachedData {
    return _cachedLocations != null && 
           _cachedBookings != null && 
           _lastFetchTime != null &&
           DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }
  
  @override
  Future<List<Location>> getLocations() async {
    if (hasCachedData) {
      return _cachedLocations!;
    }
    
    try {
      final locations = await _dataSource.getLocations();
      _cachedLocations = locations;
      _lastFetchTime = DateTime.now();
      return locations;
    } catch (e) {
      // If we have stale cache, return it as fallback
      if (_cachedLocations != null) {
        return _cachedLocations!;
      }
      rethrow;
    }
  }
  
  @override
  Future<List<Booking>> getBookings() async {
    if (hasCachedData) {
      return _cachedBookings!;
    }
    
    try {
      final bookings = await _dataSource.getBookings();
      _cachedBookings = bookings;
      _lastFetchTime = DateTime.now();
      return bookings;
    } catch (e) {
      // If we have stale cache, return it as fallback
      if (_cachedBookings != null) {
        return _cachedBookings!;
      }
      rethrow;
    }
  }
  
  @override
  Future<void> clearCache() async {
    _cachedLocations = null;
    _cachedBookings = null;
    _lastFetchTime = null;
  }
  
  /// Fetch all data at once (more efficient)
  Future<LocationData> fetchAllData() async {
    if (hasCachedData) {
      return LocationData(
        locations: _cachedLocations!,
        bookings: _cachedBookings!,
      );
    }
    
    try {
      // Fetch both locations and bookings in parallel
      final results = await Future.wait([
        _dataSource.getLocations(),
        _dataSource.getBookings(),
      ]);
      
      final locations = results[0] as List<Location>;
      final bookings = results[1] as List<Booking>;
      
      // Cache the results
      _cachedLocations = locations;
      _cachedBookings = bookings;
      _lastFetchTime = DateTime.now();
      
      return LocationData(
        locations: locations,
        bookings: bookings,
      );
    } catch (e) {
      // If we have stale cache, return it as fallback
      if (_cachedLocations != null && _cachedBookings != null) {
        return LocationData(
          locations: _cachedLocations!,
          bookings: _cachedBookings!,
        );
      }
      rethrow;
    }
  }
}

/// Data class to hold both locations and bookings
class LocationData {
  final List<Location> locations;
  final List<Booking> bookings;
  
  const LocationData({
    required this.locations,
    required this.bookings,
  });
}
