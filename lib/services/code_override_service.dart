import 'package:shared_preferences/shared_preferences.dart';

/// Cuando el modo escaneo encuentra un código que sí funciona, se guarda
/// aquí (no en el JSON del asset, que es de solo lectura en tiempo de
/// ejecución). En el próximo build, conviene copiar estos valores al JSON
/// correspondiente para que queden versionados en el proyecto.
class CodeOverrideService {
  CodeOverrideService._internal();
  static final CodeOverrideService instance = CodeOverrideService._internal();

  static const _prefix = 'ir_override_';

  Future<void> save({
    required String deviceKey, // ej. "atec_tv" / "atec_box"
    required String button,
    required int code,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix${deviceKey}_$button', code.toRadixString(16));
  }

  Future<int?> get({
    required String deviceKey,
    required String button,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final hex = prefs.getString('$_prefix${deviceKey}_$button');
    if (hex == null) return null;
    return int.parse(hex, radix: 16);
  }

  Future<Map<String, int>> allFor(String deviceKey) async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, int>{};
    final prefixKey = '$_prefix${deviceKey}_';
    for (final key in prefs.getKeys()) {
      if (key.startsWith(prefixKey)) {
        final button = key.substring(prefixKey.length);
        final hex = prefs.getString(key);
        if (hex != null) result[button] = int.parse(hex, radix: 16);
      }
    }
    return result;
  }
}
