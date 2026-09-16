import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/scan_candidate.dart';
import '../services/ir_service.dart';
import '../services/code_override_service.dart';

enum ScanTarget { tv, box }

/// Prueba, uno por uno, códigos NEC públicos conocidos de OTROS equipos
/// (LG, Vizio, Blaupunkt, etc.) por si el chasis interno del ATEC-Haier o
/// la cajita ATEC resulta ser el mismo. No hay garantía de que funcione:
/// es la misma técnica que usan los controles universales baratos.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  ScanTarget _target = ScanTarget.tv;
  List<ScanCandidate> _candidates = [];
  int _index = 0;
  bool _loading = true;
  String? _savedMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _savedMessage = null;
      _index = 0;
    });
    final path = _target == ScanTarget.tv
        ? 'assets/codes/scan_candidates_tv.json'
        : 'assets/codes/scan_candidates_box.json';
    final raw = await DefaultAssetBundle.of(context).loadString(path);
    final list = (jsonDecode(raw) as List)
        .map((e) => ScanCandidate.fromJson(e as Map<String, dynamic>))
        .toList();
    setState(() {
      _candidates = list;
      _loading = false;
    });
  }

  Future<void> _tryCurrent() async {
    if (_candidates.isEmpty) return;
    final candidate = _candidates[_index];
    await IrService.instance.transmitNec(code: candidate.code, frequencyHz: 38000);
    HapticFeedback.lightImpact();
  }

  void _next() {
    if (_candidates.isEmpty) return;
    setState(() {
      _index = (_index + 1) % _candidates.length;
      _savedMessage = null;
    });
  }

  void _prev() {
    if (_candidates.isEmpty) return;
    setState(() {
      _index = (_index - 1 + _candidates.length) % _candidates.length;
      _savedMessage = null;
    });
  }

  Future<void> _markWorking() async {
    final candidate = _candidates[_index];
    final deviceKey = _target == ScanTarget.tv ? 'atec_tv' : 'atec_box';
    await CodeOverrideService.instance.save(
      deviceKey: deviceKey,
      button: 'POWER',
      code: candidate.code,
    );
    setState(() {
      _savedMessage =
          '¡Guardado! POWER de $deviceKey ahora usa 0x${candidate.code.toRadixString(16).toUpperCase()}. '
          'Ábrelo en la pantalla del control para probarlo, y cuando puedas, cópialo también al JSON del proyecto.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF101010),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Modo escaneo',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Prueba códigos públicos de otros equipos apuntando al aparato real. '
            'Por ahora solo cubre el botón POWER.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _targetChip('TV ATEC-Haier', ScanTarget.tv)),
              const SizedBox(width: 8),
              Expanded(child: _targetChip('Cajita ATEC', ScanTarget.box)),
            ],
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_candidates.isEmpty)
            const Text('No hay candidatos cargados.', style: TextStyle(color: Colors.white54))
          else
            _candidateCard(),
          if (_savedMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_savedMessage!, style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _targetChip(String label, ScanTarget target) {
    final selected = _target == target;
    return GestureDetector(
      onTap: () {
        setState(() => _target = target);
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          border: Border.all(color: selected ? Colors.white : Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white54, fontSize: 12)),
      ),
    );
  }

  Widget _candidateCard() {
    final candidate = _candidates[_index];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Candidato ${_index + 1} de ${_candidates.length}',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(candidate.label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('0x${candidate.code.toRadixString(16).toUpperCase()}',
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontFamily: 'monospace')),
          const SizedBox(height: 6),
          Text('Fuente: ${candidate.source}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(onPressed: _prev, icon: const Icon(Icons.chevron_left, color: Colors.white)),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _tryCurrent,
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('Probar POWER'),
                ),
              ),
              IconButton(onPressed: _next, icon: const Icon(Icons.chevron_right, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _markWorking,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('¡Funcionó! Usar este código'),
            ),
          ),
        ],
      ),
    );
  }
}
