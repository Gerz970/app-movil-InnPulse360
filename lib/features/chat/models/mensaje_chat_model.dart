class MensajeChat {
  final String id;
  final String contenido;
  final bool esUsuario; // true = usuario, false = asistente
  final DateTime timestamp;

  MensajeChat({
    required this.id,
    required this.contenido,
    required this.esUsuario,
    required this.timestamp,
  });

  factory MensajeChat.fromJson(Map<String, dynamic> json, bool esUsuario) {
    return MensajeChat(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      contenido: json['contenido'] ?? json['response'] ?? '',
      esUsuario: esUsuario,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contenido': contenido,
      'esUsuario': esUsuario,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

