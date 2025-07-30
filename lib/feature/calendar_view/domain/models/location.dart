class Location {
  final String id;
  final String name;
  final List<Room> rooms;

  Location({
    required this.id,
    required this.name,
    required this.rooms,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      name: json['name'] as String,
      rooms: (json['rooms'] as List<dynamic>)
          .map((room) => Room.fromJson(room as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rooms': rooms.map((room) => room.toJson()).toList(),
    };
  }
}

class Room {
  final String id;
  final String name;

  Room({
    required this.id,
    required this.name,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
