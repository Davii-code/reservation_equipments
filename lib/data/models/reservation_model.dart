class Reservation {
  final int id;
  final String user;           // Nome do usuário que fez a reserva
  final String equipment;      // Nome do equipamento reservado
  final String date;           // Data da reserva (formato String por simplicidade)

  Reservation({
    required this.id,
    required this.user,
    required this.equipment,
    required this.date,
  });

  // Getter para compatibilidade com a interface de listagem
  String get userName => user;

  // Getter para compatibilidade com a interface de listagem
  String get equipmentName => equipment;

  // Método para converter de JSON para Reservation
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      user: json['user'] as String,
      equipment: json['equipment'] as String,
      date: json['date'] as String,
    );
  }

  // Método para converter Reservation para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'equipment': equipment,
      'date': date,
    };
  }
}
