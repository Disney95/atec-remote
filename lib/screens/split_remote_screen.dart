import 'package:flutter/material.dart';
import '../models/ac_state.dart';
import '../services/ir_service.dart';
import '../theme/app_theme.dart';
import '../widgets/remote_button.dart';

/// A diferencia del TV y la cajita (un código NEC por botón), el split
/// funciona por ESTADO: cada cambio reenvía el paquete completo. Por eso
/// esta pantalla es un panel tipo "display LCD del control real", no una
/// grilla de botones sueltos.
class SplitRemoteScreen extends StatefulWidget {
  const SplitRemoteScreen({super.key});

  @override
  State<SplitRemoteScreen> createState() => _SplitRemoteScreenState();
}

class _SplitRemoteScreenState extends State<SplitRemoteScreen> {
  AcState _state = AcState();

  Future<void> _apply(AcState Function(AcState) update) async {
    setState(() => _state = update(_state));
    await IrService.instance.sendAcState(_state);
  }

  @override
  Widget build(BuildContext context) {
    final theme = RemoteTheme.split;

    return Container(
      color: theme.body,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _pendingBanner(),
          const SizedBox(height: 12),
          Text(
            'Mystic Split · Modelo MY-ASR1284',
            style: TextStyle(color: theme.textOnBody.withOpacity(0.6), fontSize: 12),
          ),
          const SizedBox(height: 16),
          _display(theme),
          const SizedBox(height: 20),
          _tempControl(theme),
          const SizedBox(height: 20),
          _modeRow(theme),
          const SizedBox(height: 16),
          _fanRow(theme),
          const SizedBox(height: 16),
          _toggleRow(theme),
          const SizedBox(height: 20),
          _powerButton(theme),
        ],
      ),
    );
  }

  Widget _display(RemoteTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: theme.buttonFace,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.bodyEdge),
      ),
      child: Column(
        children: [
          Text(
            '${_state.tempCelsius}°C',
            style: TextStyle(
              color: _state.power ? theme.accent : theme.textOnBody.withOpacity(0.3),
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _state.power
                ? '${_modeLabel(_state.mode)} · ${_fanLabel(_state.fanSpeed)}'
                : 'APAGADO',
            style: TextStyle(color: theme.textOnBody.withOpacity(0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _tempControl(RemoteTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 56,
          height: 48,
          child: RemoteButton(
            theme: theme,
            onPressed: () => _apply((s) => s.copyWith(
                  tempCelsius: (s.tempCelsius - 1).clamp(16, 30),
                )),
            child: const Icon(Icons.remove),
          ),
        ),
        const SizedBox(width: 24),
        Text('Temperatura', style: TextStyle(color: theme.textOnBody.withOpacity(0.6))),
        const SizedBox(width: 24),
        SizedBox(
          width: 56,
          height: 48,
          child: RemoteButton(
            theme: theme,
            onPressed: () => _apply((s) => s.copyWith(
                  tempCelsius: (s.tempCelsius + 1).clamp(16, 30),
                )),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _modeRow(RemoteTheme theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: AcMode.values.map((mode) {
        final selected = _state.mode == mode;
        return SizedBox(
          width: 64,
          height: 40,
          child: RemoteButton(
            theme: theme,
            overrideColor: selected ? theme.accent : null,
            onPressed: () => _apply((s) => s.copyWith(mode: mode)),
            child: Text(
              _modeLabel(mode),
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white : theme.textOnBody,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _fanRow(RemoteTheme theme) {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: FanSpeed.values.map((fan) {
        final selected = _state.fanSpeed == fan;
        return SizedBox(
          width: 56,
          height: 36,
          child: RemoteButton(
            theme: theme,
            overrideColor: selected ? theme.accent : null,
            onPressed: () => _apply((s) => s.copyWith(fanSpeed: fan)),
            child: Text(
              _fanLabel(fan),
              style: TextStyle(
                fontSize: 10,
                color: selected ? Colors.white : theme.textOnBody,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _toggleRow(RemoteTheme theme) {
    Widget toggle(String label, bool value, void Function(bool) onChanged) {
      return Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: theme.textOnBody.withOpacity(0.6))),
          Switch(
            value: value,
            activeColor: theme.accent,
            onChanged: onChanged,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        toggle('Swing', _state.swing, (v) => _apply((s) => s.copyWith(swing: v))),
        toggle('Turbo', _state.turbo, (v) => _apply((s) => s.copyWith(turbo: v))),
        toggle('Sleep', _state.sleep, (v) => _apply((s) => s.copyWith(sleep: v))),
      ],
    );
  }

  Widget _powerButton(RemoteTheme theme) {
    return SizedBox(
      width: 64,
      height: 64,
      child: RemoteButton(
        theme: theme,
        overrideColor: _state.power ? tdtGreen : Colors.grey.shade400,
        borderRadius: 32,
        onPressed: () => _apply((s) => s.copyWith(power: !s.power)),
        child: const Icon(Icons.power_settings_new, color: Colors.white),
      ),
    );
  }

  Widget _pendingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Protocolo IR del split pendiente de capturar: los botones cambian '
        'el estado en pantalla pero todavía no emiten señal real.',
        style: TextStyle(color: Colors.deepOrange, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _modeLabel(AcMode mode) {
    switch (mode) {
      case AcMode.cool:
        return 'FRÍO';
      case AcMode.heat:
        return 'CALOR';
      case AcMode.fan:
        return 'VENT.';
      case AcMode.dry:
        return 'SECO';
      case AcMode.auto:
        return 'AUTO';
    }
  }

  String _fanLabel(FanSpeed fan) {
    switch (fan) {
      case FanSpeed.auto:
        return 'AUTO';
      case FanSpeed.low:
        return 'BAJA';
      case FanSpeed.med:
        return 'MEDIA';
      case FanSpeed.high:
        return 'ALTA';
    }
  }
}
