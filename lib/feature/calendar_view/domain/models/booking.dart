class Booking {
  final String id;
  final String roomId;
  final String course;
  final DateTime start;
  final DateTime end;
  final String? description;

  Booking({
    required this.id,
    required this.roomId,
    required this.course,
    required this.start,
    required this.end,
    this.description,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: json['roomId'] as String,
      course: json['course'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'course': course,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      if (description != null) 'description': description,
    };
  }

  Booking copyWith({
    String? id,
    String? roomId,
    String? course,
    DateTime? start,
    DateTime? end,
    String? description,
  }) {
    return Booking(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      course: course ?? this.course,
      start: start ?? this.start,
      end: end ?? this.end,
      description: description ?? this.description,
    );
  }
}
