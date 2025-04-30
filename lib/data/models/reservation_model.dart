class Reservation {
  final int id;
  final String user;
  final String equipment;
  final String date;

  Reservation({
    required this.id,
    required this.user,
    required this.equipment,
    required this.date,
  });

  String get userName => user;

  String get equipmentName => equipment;

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      user: json['user'] as String,
      equipment: json['equipment'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'equipment': equipment,
      'date': date,
    };
  }
}
