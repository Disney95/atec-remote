import 'package:flutter/material.dart';
import '../models/ir_device.dart';
import '../services/ir_service.dart';
import '../theme/app_theme.dart';
import '../widgets/remote_button.dart';

class TvRemoteScreen extends StatefulWidget {
  const TvRemoteScreen({super.key});

  @override
  State<TvRemoteScreen> createState() => _TvRemoteScreenState();
}

class _TvRemoteScreenState extends State<TvRemoteScreen> {
  IrDevice? _device;
  bool _sandbox = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final device = await IrService.instance.loadDevice('assets/codes/atec_tv.json');
    final hasEmitter = await IrService.instance.hasIrEmitter();
    setState(() {
      _device = device;
      _sandbox = !hasEmitter;
    });
  }

  Future<void> _send(String button) async {
    final device = _device;
    if (device == null) return;
    final code = device.commands[button];
    if (code == null) return;
    await IrService.instance.transmitNec(code: code, frequencyHz: device.frequencyHz);
  }

  @override
  Widget build(BuildContext context) {
    final theme = RemoteTheme.tv;
    final device = _device;

    if (device == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: theme.body,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          if (_sandbox) _SandboxBanner(theme: theme),
          const SizedBox(height: 12),
          Text(
            'ATEC-Haier · Modelo ${device.model}',
            style: TextStyle(color: theme.textOnBody.withOpacity(0.6), fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Fila superior: power / input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleButton(theme, device, 'POWER', Icons.power_settings_new, tdtRed),
              _circleButton(theme, device, 'INPUT_AV', Icons.input, theme.accent),
            ],
          ),
          const SizedBox(height: 20),
          // D-Pad
          _DPad(theme: theme, device: device, onPress: _send),
          const SizedBox(height: 20),
          // Volumen / Canal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _rocker(theme, device, 'Volumen', 'VOL_UP', 'VOL_DOWN'),
              _circleButton(theme, device, 'MUTE', Icons.volume_off, theme.accent),
              _rocker(theme, device, 'Canal', 'CH_UP', 'CH_DOWN'),
            ],
          ),
          const SizedBox(height: 20),
          _NumericKeypad(theme: theme, device: device, onPress: _send),
          const SizedBox(height: 12),
          _circleButton(theme, device, 'MENU', Icons.menu, theme.accent),
        ],
      ),
    );
  }

  Widget _circleButton(
    RemoteTheme theme,
    IrDevice device,
    String cmd,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: 56,
      height: 56,
      child: RemoteButton(
        theme: theme,
        overrideColor: color.withOpacity(0.85),
        borderRadius: 28,
        isPlaceholder: device.isPlaceholder(cmd),
        onPressed: () => _send(cmd),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _rocker(RemoteTheme theme, IrDevice device, String label, String up, String down) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: theme.textOnBody.withOpacity(0.6), fontSize: 11)),
        const SizedBox(height: 6),
        SizedBox(
          width: 48,
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: RemoteButton(
                  theme: theme,
                  isPlaceholder: device.isPlaceholder(up),
                  onPressed: () => _send(up),
                  borderRadius: 10,
                  child: const Icon(Icons.add, size: 18),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 40,
                child: RemoteButton(
                  theme: theme,
                  isPlaceholder: device.isPlaceholder(down),
                  onPressed: () => _send(down),
                  borderRadius: 10,
                  child: const Icon(Icons.remove, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DPad extends StatelessWidget {
  final RemoteTheme theme;
  final IrDevice device;
  final Future<void> Function(String) onPress;

  const _DPad({required this.theme, required this.device, required this.onPress});

  @override
  Widget build(BuildContext context) {
    Widget dirButton(String cmd, IconData icon) {
      return SizedBox(
        width: 52,
        height: 52,
        child: RemoteButton(
          theme: theme,
          isPlaceholder: device.isPlaceholder(cmd),
          onPressed: () => onPress(cmd),
          child: Icon(icon, size: 22),
        ),
      );
    }

    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, child: dirButton('UP', Icons.keyboard_arrow_up)),
          Positioned(bottom: 0, child: dirButton('DOWN', Icons.keyboard_arrow_down)),
          Positioned(left: 0, child: dirButton('LEFT', Icons.keyboard_arrow_left)),
          Positioned(right: 0, child: dirButton('RIGHT', Icons.keyboard_arrow_right)),
          SizedBox(
            width: 60,
            height: 60,
            child: RemoteButton(
              theme: theme,
              overrideColor: theme.accent,
              borderRadius: 30,
              isPlaceholder: device.isPlaceholder('OK'),
              onPressed: () => onPress('OK'),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  final RemoteTheme theme;
  final IrDevice device;
  final Future<void> Function(String) onPress;

  const _NumericKeypad({required this.theme, required this.device, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: List.generate(10, (i) {
          final label = i == 9 ? '0' : '${i + 1}';
          final cmd = i == 9 ? 'NUM_0' : 'NUM_${i + 1}';
          if (i == 9) {
            // Dejar el último slot centrado para el 0 en la fila final.
          }
          return RemoteButton(
            theme: theme,
            isPlaceholder: device.isPlaceholder(cmd),
            onPressed: () => onPress(cmd),
            child: Text(label, style: const TextStyle(fontSize: 16)),
          );
        }),
      ),
    );
  }
}

class _SandboxBanner extends StatelessWidget {
  final RemoteTheme theme;
  const _SandboxBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Modo sandbox: este teléfono no tiene emisor IR (o faltan códigos reales). Los botones no emiten señal.',
        style: TextStyle(color: Colors.orangeAccent, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }
}
