import 'package:flutter/material.dart';
import '../models/ir_device.dart';
import '../services/ir_service.dart';
import '../theme/app_theme.dart';
import '../widgets/remote_button.dart';

class BoxRemoteScreen extends StatefulWidget {
  const BoxRemoteScreen({super.key});

  @override
  State<BoxRemoteScreen> createState() => _BoxRemoteScreenState();
}

class _BoxRemoteScreenState extends State<BoxRemoteScreen> {
  IrDevice? _device;
  bool _sandbox = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final device = await IrService.instance.loadDevice('assets/codes/atec_box.json');
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
    final theme = RemoteTheme.box;
    final device = _device;
    if (device == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: theme.body,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          if (_sandbox) _sandboxBanner(),
          const SizedBox(height: 12),
          Text(
            'Cajita ATEC · Modelo ${device.model}',
            style: TextStyle(color: theme.textOnBody.withOpacity(0.6), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _iconButton(theme, device, 'POWER', Icons.power_settings_new, tdtRed),
              _iconButton(theme, device, 'EPG', Icons.grid_view, theme.accent),
              _iconButton(theme, device, 'INFO', Icons.info_outline, theme.accent),
            ],
          ),
          const SizedBox(height: 20),
          _dPad(theme, device),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _iconButton(theme, device, 'MENU', Icons.menu, theme.accent),
              const SizedBox(width: 16),
              _iconButton(theme, device, 'EXIT', Icons.close, theme.accent),
            ],
          ),
          const SizedBox(height: 20),
          // Botones de color TDT: Rojo/Verde/Amarillo/Azul
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _colorButton(theme, device, 'RED', tdtRed),
              _colorButton(theme, device, 'GREEN', tdtGreen),
              _colorButton(theme, device, 'YELLOW', tdtYellow),
              _colorButton(theme, device, 'BLUE', tdtBlue),
            ],
          ),
          const SizedBox(height: 20),
          _numPad(theme, device),
        ],
      ),
    );
  }

  Widget _dPad(RemoteTheme theme, IrDevice device) {
    Widget dirButton(String cmd, IconData icon) {
      return SizedBox(
        width: 48,
        height: 48,
        child: RemoteButton(
          theme: theme,
          isPlaceholder: device.isPlaceholder(cmd),
          onPressed: () => _send(cmd),
          child: Icon(icon, size: 20),
        ),
      );
    }

    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, child: dirButton('UP', Icons.keyboard_arrow_up)),
          Positioned(bottom: 0, child: dirButton('DOWN', Icons.keyboard_arrow_down)),
          Positioned(left: 0, child: dirButton('LEFT', Icons.keyboard_arrow_left)),
          Positioned(right: 0, child: dirButton('RIGHT', Icons.keyboard_arrow_right)),
          SizedBox(
            width: 56,
            height: 56,
            child: RemoteButton(
              theme: theme,
              overrideColor: theme.accent,
              borderRadius: 28,
              isPlaceholder: device.isPlaceholder('OK'),
              onPressed: () => _send('OK'),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numPad(RemoteTheme theme, IrDevice device) {
    return SizedBox(
      width: 200,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        children: List.generate(10, (i) {
          final label = i == 9 ? '0' : '${i + 1}';
          final cmd = i == 9 ? 'NUM_0' : 'NUM_${i + 1}';
          return RemoteButton(
            theme: theme,
            isPlaceholder: device.isPlaceholder(cmd),
            onPressed: () => _send(cmd),
            child: Text(label),
          );
        }),
      ),
    );
  }

  Widget _iconButton(RemoteTheme theme, IrDevice device, String cmd, IconData icon, Color color) {
    return SizedBox(
      width: 48,
      height: 48,
      child: RemoteButton(
        theme: theme,
        overrideColor: color.withOpacity(0.85),
        borderRadius: 24,
        isPlaceholder: device.isPlaceholder(cmd),
        onPressed: () => _send(cmd),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _colorButton(RemoteTheme theme, IrDevice device, String cmd, Color color) {
    return SizedBox(
      width: 40,
      height: 28,
      child: RemoteButton(
        theme: theme,
        overrideColor: color,
        borderRadius: 6,
        isPlaceholder: device.isPlaceholder(cmd),
        onPressed: () => _send(cmd),
        child: const SizedBox.shrink(),
      ),
    );
  }

  Widget _sandboxBanner() {
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
