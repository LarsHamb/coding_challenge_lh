import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../providers/repository_provider.dart';

class BookingState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;

  const BookingState({
    required this.bookings,
    this.isLoading = false,
    this.error,
  });

  BookingState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository _repository;

  BookingNotifier(this._repository) : super(const BookingState(bookings: [])) {
    _loadInitialBookings();
  }

  /// Load initial bookings from repository
  Future<void> _loadInitialBookings() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final bookings = await _repository.getBookings();
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load bookings: $e',
      );
    }
  }

  // Create a new booking
  Future<bool> createBooking({
    required String roomId,
    required DateTime start,
    required DateTime end,
    required String course,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Create new booking
      final newBooking = Booking(
        id: '', // Repository will generate ID
        roomId: roomId,
        start: start,
        end: end,
        course: course,
        description: description,
      );

      // Create booking through repository
      final createdBooking = await _repository.createBooking(newBooking);

      // Update local state
      final updatedBookings = [...state.bookings, createdBooking];
      state = state.copyWith(bookings: updatedBookings, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create booking: $e',
      );
      return false;
    }
  }

  // Delete a booking
  Future<bool> deleteBooking(String bookingId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Delete through repository
      await _repository.deleteBooking(bookingId);
      
      // Update local state
      final updatedBookings = state.bookings.where((b) => b.id != bookingId).toList();
      state = state.copyWith(bookings: updatedBookings, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete booking: $e',
      );
      return false;
    }
  }

  // Clear any error messages
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  // Set error message
  void setError(String error) {
    state = state.copyWith(error: error);
  }
}

// Provider for the booking notifier
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingNotifier(repository);
});

// Convenience providers
final bookingsListProvider = Provider<List<Booking>>((ref) {
  return ref.watch(bookingProvider).bookings;
});

final bookingLoadingProvider = Provider<bool>((ref) {
  return ref.watch(bookingProvider).isLoading;
});

final bookingErrorProvider = Provider<String?>((ref) {
  return ref.watch(bookingProvider).error;
});
