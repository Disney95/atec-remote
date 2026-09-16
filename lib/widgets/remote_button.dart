import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Botón de control remoto con:
/// - vibración háptica al presionar
/// - animación de "hundimiento" (depth) al tocar
/// - marca visual de placeholder si el código IR aún no es real
class RemoteButton extends StatefulWidget {
  final Widget child;
  final RemoteTheme theme;
  final VoidCallback onPressed;
  final bool isPlaceholder;
  final Color? overrideColor;
  final double borderRadius;

  const RemoteButton({
    super.key,
    required this.child,
    required this.theme,
    required this.onPressed,
    this.isPlaceholder = false,
    this.overrideColor,
    this.borderRadius = 14,
  });

  @override
  State<RemoteButton> createState() => _RemoteButtonState();
}

class _RemoteButtonState extends State<RemoteButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
    HapticFeedback.mediumImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _pressed = false);
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.overrideColor ?? widget.theme.buttonFace;
    final pressedColor = widget.overrideColor?.withOpacity(0.75) ??
        widget.theme.buttonFacePressed;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        decoration: BoxDecoration(
          color: _pressed ? pressedColor : baseColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: widget.theme.bodyEdge, width: 1),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DefaultTextStyle(
              style: TextStyle(
                color: widget.theme.textOnBody,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              child: widget.child,
            ),
            if (widget.isPlaceholder)
              Positioned(
                top: 2,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
