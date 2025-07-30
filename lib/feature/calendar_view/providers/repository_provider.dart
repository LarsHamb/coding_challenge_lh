import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data_source.dart';
import '../data/location_repository_impl.dart';
import '../data/booking_mock_data_source.dart';
import '../data/booking_repository_impl.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/repositories/booking_repository.dart';

// Provider for the location data source
final mockDataSourceProvider = Provider<MockDataSource>((ref) {
  return MockDataSource();
});

// Provider for the location repository
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final dataSource = ref.watch(mockDataSourceProvider);
  return LocationRepositoryImpl(dataSource);
});

// Provider for the booking data source
final bookingMockDataSourceProvider = Provider<BookingMockDataSource>((ref) {
  return BookingMockDataSource();
});

// Provider for the booking repository
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final dataSource = ref.watch(bookingMockDataSourceProvider);
  return BookingRepositoryImpl(dataSource);
});
