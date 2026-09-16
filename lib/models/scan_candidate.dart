/// Un candidato de código a probar en el modo escaneo: representa un código
/// NEC público y verificable (de proyectos abiertos LIRC/Flipper-IRDB/etc.)
/// que pertenece a OTRO equipo, pero que podría coincidir si el chasis por
/// dentro de ATEC/Haier/Mystic es el mismo que el de esa marca.
class ScanCandidate {
  final String label; // ej. "LG STB genérico (LIRC)"
  final int code; // código NEC de 32 bits ya combinado
  final String source; // de dónde salió, para que quede trazable

  const ScanCandidate({
    required this.label,
    required this.code,
    required this.source,
  });

  factory ScanCandidate.fromJson(Map<String, dynamic> json) {
    final hex = (json['code'] as String).replaceFirst('0x', '').replaceFirst('0X', '');
    return ScanCandidate(
      label: json['label'] as String,
      code: int.parse(hex, radix: 16),
      source: json['source'] as String,
    );
  }
}
