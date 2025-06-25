enum EquipmentState {
  USABLE,
  IN_MAINTENANCE,
  IN_REPAIR,
  DEFECTIVE,
  OBSOLETE,
  RESERVED,
  AWAITING_RETURN,
}

/// Extensão para (de)serialização do [EquipmentState].
extension EquipmentStateExtension on EquipmentState {
  /// Converte para string (usado pela API).
  String toJson() => name;

  String get displayName {
    switch (this) {
      case EquipmentState.USABLE:
        return 'Disponível';
      case EquipmentState.IN_MAINTENANCE:
        return 'Em Manutenção';
      case EquipmentState.IN_REPAIR:
        return 'Em Conserto';
      case EquipmentState.DEFECTIVE:
        return 'Com Defeito';
      case EquipmentState.OBSOLETE:
        return 'Obsoleto';
      case EquipmentState.RESERVED:
        return 'Reservado';
      case EquipmentState.AWAITING_RETURN:
        return 'Aguardando Devolução';
      default: // Caso algum novo estado seja adicionado e esquecido aqui
        return name; // Retorna o nome original como fallback
    }
  }

  /// Constrói a partir do valor retornado pela API (string ou índice).
  static EquipmentState fromJson(dynamic value) {
    if (value is String) {
      return EquipmentState.values.firstWhere(
            (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
        orElse: () => throw Exception('Estado de equipamento inválido: $value'),
      );
    } else if (value is int) {
      return EquipmentState.values[value];
    } else {
      throw Exception('Não foi possível converter valor para EquipmentState: $value');
    }
  }
}

class Equipment {
  final int? id;
  final String heritageCode;
  final String brand;
  final String model;
  final String? description;
  final String type;
  final EquipmentState state;

  Equipment({
    this.id,
    required this.heritageCode,
    required this.brand,
    required this.model,
    this.description,
    required this.type,
    required this.state,
  });

  /// Cria um [Equipment] a partir de um JSON.
  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()),
      heritageCode: json['heritageCode'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      state: EquipmentStateExtension.fromJson(json['state']),
    );
  }

  /// Converte o [Equipment] para JSON.
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'heritageCode': heritageCode,
      'brand': brand,
      'model': model,
      'description': description,
      'type': type,
      'state': state.toJson(),
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  // Implementação correta do método copyWith
  Equipment copyWith({
    int? id,
    String? heritageCode,
    String? brand,
    String? model,
    String? type,
    String? description,
    EquipmentState? state,
  }) {
    return Equipment(
      id: id ?? this.id,
      heritageCode: heritageCode ?? this.heritageCode,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      type: type ?? this.type,
      description: description ?? this.description,
      state: state ?? this.state,
    );
  }
}
