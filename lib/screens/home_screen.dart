import 'package:flutter/material.dart';
import 'tv_remote_screen.dart';
import 'box_remote_screen.dart';
import 'split_remote_screen.dart';
import 'scan_screen.dart';

enum RemoteTarget { tv, box, split, scan }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RemoteTarget _selected = RemoteTarget.tv;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _buildToggle(),
            Expanded(child: _buildScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _tab('TV ATEC-Haier', RemoteTarget.tv),
          const SizedBox(width: 8),
          _tab('Cajita ATEC', RemoteTarget.box),
          const SizedBox(width: 8),
          _tab('Split Mystic', RemoteTarget.split),
          const SizedBox(width: 8),
          _tab('Escanear', RemoteTarget.scan),
        ],
      ),
    );
  }

  Widget _tab(String label, RemoteTarget target) {
    final selected = _selected == target;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selected = target),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? Colors.white.withOpacity(0.4) : Colors.white12,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white54,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_selected) {
      case RemoteTarget.tv:
        return const TvRemoteScreen();
      case RemoteTarget.box:
        return const BoxRemoteScreen();
      case RemoteTarget.split:
        return const SplitRemoteScreen();
      case RemoteTarget.scan:
        return const ScanScreen();
    }
  }
}
