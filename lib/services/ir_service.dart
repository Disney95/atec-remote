import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ir_device.dart';
import '../models/ac_state.dart';
import 'code_override_service.dart';

/// Puente entre Flutter y el ConsumerIrManager nativo de Android.
/// Si el teléfono no tiene emisor IR, entra en "modo sandbox": no transmite
/// nada de verdad, pero la UI sigue funcionando para poder probar el diseño.
class IrService {
  IrService._internal();
  static final IrService instance = IrService._internal();

  static const MethodChannel _channel = MethodChannel('atec_remote/ir');

  bool? _hasEmitterCache;

  Future<bool> hasIrEmitter() async {
    if (_hasEmitterCache != null) return _hasEmitterCache!;
    try {
      final result = await _channel.invokeMethod<bool>('hasIrEmitter');
      _hasEmitterCache = result ?? false;
    } on PlatformException {
      // Canal no implementado (ej. corriendo en un emulador sin soporte,
      // o durante desarrollo antes de tener el lado nativo listo).
      _hasEmitterCache = false;
    }
    return _hasEmitterCache!;
  }

  /// Envía un código NEC de 32 bits en la frecuencia indicada.
  /// Devuelve false si no hay hardware IR (modo sandbox) o si falla el envío.
  Future<bool> transmitNec({
    required int code,
    required int frequencyHz,
  }) async {
    final hasEmitter = await hasIrEmitter();
    if (!hasEmitter) {
      // ignore: avoid_print
      print('[SANDBOX] Simulando envío NEC 0x${code.toRadixString(16)} @ $frequencyHz Hz');
      return false;
    }
    try {
      final pattern = _necToPattern(code, frequencyHz);
      final result = await _channel.invokeMethod<bool>('transmit', {
        'frequency': frequencyHz,
        'pattern': pattern,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Error transmitiendo IR: ${e.message}');
      return false;
    }
  }

  /// Envía el paquete crudo (ya armado bit a bit) para protocolos state-based
  /// como el split. `pattern` son los tiempos on/off en microsegundos, tal
  /// como los pide ConsumerIrManager.transmit().
  Future<bool> transmitRaw({
    required List<int> pattern,
    required int frequencyHz,
  }) async {
    final hasEmitter = await hasIrEmitter();
    if (!hasEmitter) {
      // ignore: avoid_print
      print('[SANDBOX] Simulando envío RAW de ${pattern.length} pulsos @ $frequencyHz Hz');
      return false;
    }
    try {
      final result = await _channel.invokeMethod<bool>('transmit', {
        'frequency': frequencyHz,
        'pattern': pattern,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('Error transmitiendo IR: ${e.message}');
      return false;
    }
  }

  /// Convierte un código NEC de 32 bits en el patrón de tiempos on/off
  /// (en microsegundos) que espera ConsumerIrManager.transmit().
  /// Formato NEC estándar: header 9000/4500, bits 562(1) / 562+1690(0),
  /// stop bit 562.
  List<int> _necToPattern(int code, int frequencyHz) {
    const headerMark = 9000;
    const headerSpace = 4500;
    const bitMark = 562;
    const oneSpace = 1690;
    const zeroSpace = 562;

    final pattern = <int>[headerMark, headerSpace];
    for (int i = 31; i >= 0; i--) {
      final bit = (code >> i) & 1;
      pattern.add(bitMark);
      pattern.add(bit == 1 ? oneSpace : zeroSpace);
    }
    pattern.add(bitMark); // stop bit
    return pattern;
  }

  Future<IrDevice> loadDevice(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final device = IrDevice.fromJson(json);

    // deviceKey = nombre del archivo sin extensión, ej. "atec_tv"
    final deviceKey = assetPath.split('/').last.replaceFirst('.json', '');
    final overrides = await CodeOverrideService.instance.allFor(deviceKey);
    if (overrides.isEmpty) return device;

    final merged = Map<String, int>.from(device.commands)..addAll(overrides);
    return IrDevice(
      deviceName: device.deviceName,
      model: device.model,
      protocol: device.protocol,
      frequencyHz: device.frequencyHz,
      commands: merged,
    );
  }

  /// TODO: cuando se capture el protocolo real del split (ver
  /// assets/codes/mystic_split.json), esta función debe construir el patrón
  /// raw completo a partir del AcState. Por ahora solo registra el intento
  /// en modo sandbox para no enviar basura al equipo real.
  Future<bool> sendAcState(AcState state) async {
    // ignore: avoid_print
    print('[SANDBOX] Estado AC pendiente de protocolo real: '
        'power=${state.power} mode=${state.mode} temp=${state.tempCelsius} '
        'fan=${state.fanSpeed} swing=${state.swing} turbo=${state.turbo} '
        'sleep=${state.sleep}');
    return false;
  }
}
