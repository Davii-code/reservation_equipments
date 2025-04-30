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
    // Safely parse `id`, allowing int or num, default to 0 if missing/invalid
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : rawId is num
        ? rawId.toInt()
        : 0;

    // Safely parse strings, defaulting to empty
    final user = json['user']?.toString() ?? '';
    final equipment = json['typeEquipment']?.toString() ?? '';
    final date = json['reservationDate']?.toString() ?? '';

    return Reservation(
      id: id,
      user: user,
      equipment: equipment,
      date: date,
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