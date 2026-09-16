/// Modelo para un dispositivo IR simple (protocolo NEC, un código por botón),
/// como el TV ATEC-Haier y la cajita ATEC.
class IrDevice {
  final String deviceName;
  final String model;
  final String protocol;
  final int frequencyHz;
  final Map<String, int> commands; // nombre de botón -> código NEC (32 bits)

  IrDevice({
    required this.deviceName,
    required this.model,
    required this.protocol,
    required this.frequencyHz,
    required this.commands,
  });

  factory IrDevice.fromJson(Map<String, dynamic> json) {
    final rawCommands = Map<String, dynamic>.from(json['commands'] as Map);
    final parsed = <String, int>{};
    rawCommands.forEach((key, value) {
      // Los códigos vienen como string hex, ej "0x00FF00FF".
      final hex = (value as String).replaceFirst('0x', '').replaceFirst('0X', '');
      parsed[key] = int.parse(hex, radix: 16);
    });

    return IrDevice(
      deviceName: json['device_name'] as String,
      model: json['model'] as String,
      protocol: json['protocol'] as String,
      frequencyHz: json['frequency_hz'] as int,
      commands: parsed,
    );
  }

  /// true si el código de este botón es el placeholder 0x00000000
  /// (es decir, todavía no se ha capturado el código real).
  bool isPlaceholder(String button) => commands[button] == 0;
}
