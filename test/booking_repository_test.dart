import 'package:flutter_test/flutter_test.dart';
import 'package:coding_challenge_lh/feature/calendar_view/data/booking_mock_data_source.dart';
import 'package:coding_challenge_lh/feature/calendar_view/data/booking_repository_impl.dart';
import 'package:coding_challenge_lh/feature/calendar_view/domain/models/booking.dart';

void main() {
  group('Booking Repository Tests', () {
    late BookingMockDataSource dataSource;
    late BookingRepositoryImpl repository;

    setUp(() {
      dataSource = BookingMockDataSource();
      repository = BookingRepositoryImpl(dataSource);
    });

    test('should create a booking successfully', () async {
      // Arrange
      final booking = Booking(
        id: '',
        roomId: 'room1',
        course: 'Flutter Development',
        start: DateTime(2025, 7, 30, 10, 0),
        end: DateTime(2025, 7, 30, 11, 0),
        description: 'Test booking',
      );

      // Act
      final createdBooking = await repository.createBooking(booking);

      // Assert
      expect(createdBooking.id, isNotEmpty);
      expect(createdBooking.roomId, equals('room1'));
      expect(createdBooking.course, equals('Flutter Development'));
      expect(createdBooking.description, equals('Test booking'));
    });

    test('should get all bookings', () async {
      // Arrange
      final booking1 = Booking(
        id: '',
        roomId: 'room1',
        course: 'Course 1',
        start: DateTime(2025, 7, 30, 10, 0),
        end: DateTime(2025, 7, 30, 11, 0),
      );
      
      final booking2 = Booking(
        id: '',
        roomId: 'room2',
        course: 'Course 2',
        start: DateTime(2025, 7, 30, 14, 0),
        end: DateTime(2025, 7, 30, 15, 0),
      );

      await repository.createBooking(booking1);
      await repository.createBooking(booking2);

      // Act
      final bookings = await repository.getBookings();

      // Assert
      expect(bookings.length, equals(2));
    });

    test('should update a booking successfully', () async {
      // Arrange
      final booking = Booking(
        id: '',
        roomId: 'room1',
        course: 'Original Course',
        start: DateTime(2025, 7, 30, 10, 0),
        end: DateTime(2025, 7, 30, 11, 0),
      );

      final createdBooking = await repository.createBooking(booking);
      final updatedBooking = createdBooking.copyWith(
        course: 'Updated Course',
        description: 'Updated description',
      );

      // Act
      final result = await repository.updateBooking(updatedBooking);

      // Assert
      expect(result.course, equals('Updated Course'));
      expect(result.description, equals('Updated description'));
      expect(result.id, equals(createdBooking.id));
    });

    test('should delete a booking successfully', () async {
      // Arrange
      final booking = Booking(
        id: '',
        roomId: 'room1',
        course: 'Test Course',
        start: DateTime(2025, 7, 30, 10, 0),
        end: DateTime(2025, 7, 30, 11, 0),
      );

      final createdBooking = await repository.createBooking(booking);

      // Act
      await repository.deleteBooking(createdBooking.id);

      // Assert
      final bookings = await repository.getBookings();
      expect(bookings.length, equals(0));
    });

    test('should detect time conflicts', () async {
      // Arrange
      final booking = Booking(
        id: '',
        roomId: 'room1',
        course: 'Existing Course',
        start: DateTime(2025, 7, 30, 10, 0),
        end: DateTime(2025, 7, 30, 11, 0),
      );

      await repository.createBooking(booking);

      // Act & Assert - overlapping time
      final hasConflict1 = await repository.hasTimeConflict(
        'room1',
        DateTime(2025, 7, 30, 10, 30),
        DateTime(2025, 7, 30, 11, 30),
      );
      expect(hasConflict1, isTrue);

      // Act & Assert - different room, same time
      final hasConflict2 = await repository.hasTimeConflict(
        'room2',
        DateTime(2025, 7, 30, 10, 0),
        DateTime(2025, 7, 30, 11, 0),
      );
      expect(hasConflict2, isFalse);

      // Act & Assert - same room, different time
      final hasConflict3 = await repository.hasTimeConflict(
        'room1',
        DateTime(2025, 7, 30, 12, 0),
        DateTime(2025, 7, 30, 13, 0),
      );
      expect(hasConflict3, isFalse);
    });

    test('should get bookings for specific room', () async {
      // Arrange
      final booking1 = Booking(
        id: '',
        roomId: 'room1',
        course: 'Course 1',
        start: DateTime(2025, 7, 30, 10, 0),
        end: DateTime(2025, 7, 30, 11, 0),
      );
      
      final booking2 = Booking(
        id: '',
        roomId: 'room2',
        course: 'Course 2',
        start: DateTime(2025, 7, 30, 14, 0),
        end: DateTime(2025, 7, 30, 15, 0),
      );

      await repository.createBooking(booking1);
      await repository.createBooking(booking2);

      // Act
      final room1Bookings = await repository.getBookingsForRoom('room1');

      // Assert
      expect(room1Bookings.length, equals(1));
      expect(room1Bookings.first.roomId, equals('room1'));
    });

    test('should validate booking data', () async {
      // Test empty room ID
      expect(
        () => repository.createBooking(Booking(
          id: '',
          roomId: '',
          course: 'Test',
          start: DateTime.now(),
          end: DateTime.now().add(Duration(hours: 1)),
        )),
        throwsA(isA<ArgumentError>()),
      );

      // Test empty course
      expect(
        () => repository.createBooking(Booking(
          id: '',
          roomId: 'room1',
          course: '',
          start: DateTime.now(),
          end: DateTime.now().add(Duration(hours: 1)),
        )),
        throwsA(isA<ArgumentError>()),
      );

      // Test invalid time range
      final now = DateTime.now();
      expect(
        () => repository.createBooking(Booking(
          id: '',
          roomId: 'room1',
          course: 'Test',
          start: now.add(Duration(hours: 1)),
          end: now,
        )),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
