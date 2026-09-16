enum AcMode { cool, heat, fan, dry, auto }

enum FanSpeed { auto, low, med, high }

/// Estado completo del split. Cada vez que cambia algo, se debe reconstruir
/// y reenviar el paquete IR completo (a diferencia del TV/cajita, donde cada
/// botón es un código independiente).
class AcState {
  bool power;
  AcMode mode;
  int tempCelsius;
  FanSpeed fanSpeed;
  bool swing;
  bool turbo;
  bool sleep;

  AcState({
    this.power = false,
    this.mode = AcMode.cool,
    this.tempCelsius = 24,
    this.fanSpeed = FanSpeed.auto,
    this.swing = false,
    this.turbo = false,
    this.sleep = false,
  });

  AcState copyWith({
    bool? power,
    AcMode? mode,
    int? tempCelsius,
    FanSpeed? fanSpeed,
    bool? swing,
    bool? turbo,
    bool? sleep,
  }) {
    return AcState(
      power: power ?? this.power,
      mode: mode ?? this.mode,
      tempCelsius: tempCelsius ?? this.tempCelsius,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      swing: swing ?? this.swing,
      turbo: turbo ?? this.turbo,
      sleep: sleep ?? this.sleep,
    );
  }
}
