import 'package:flutter/material.dart';

/// Paletas inspiradas en el aspecto de cada control físico (no son logos,
/// solo esquemas de color: cuerpo oscuro, acentos y colores de función).
class RemoteTheme {
  final Color body;
  final Color bodyEdge;
  final Color buttonFace;
  final Color buttonFacePressed;
  final Color textOnBody;
  final Color accent;

  const RemoteTheme({
    required this.body,
    required this.bodyEdge,
    required this.buttonFace,
    required this.buttonFacePressed,
    required this.textOnBody,
    required this.accent,
  });

  // TV ATEC-Haier: cuerpo charcoal/negro, look de control de CRT clásico.
  static const tv = RemoteTheme(
    body: Color(0xFF1C1C1E),
    bodyEdge: Color(0xFF3A3A3C),
    buttonFace: Color(0xFF2C2C2E),
    buttonFacePressed: Color(0xFF48484A),
    textOnBody: Color(0xFFE5E5EA),
    accent: Color(0xFF0A84FF),
  );

  // Cajita ATEC: cuerpo compacto negro, con acentos de color para TDT.
  static const box = RemoteTheme(
    body: Color(0xFF141414),
    bodyEdge: Color(0xFF2E2E2E),
    buttonFace: Color(0xFF262626),
    buttonFacePressed: Color(0xFF3D3D3D),
    textOnBody: Color(0xFFF2F2F2),
    accent: Color(0xFFFFA000),
  );

  // Split Mystic: cuerpo blanco tipo control de A/C con display LCD.
  static const split = RemoteTheme(
    body: Color(0xFFF5F5F5),
    bodyEdge: Color(0xFFD0D0D0),
    buttonFace: Color(0xFFFFFFFF),
    buttonFacePressed: Color(0xFFE0E0E0),
    textOnBody: Color(0xFF1C1C1E),
    accent: Color(0xFF00A0DC),
  );
}

const tdtRed = Color(0xFFE53935);
const tdtGreen = Color(0xFF43A047);
const tdtYellow = Color(0xFFFDD835);
const tdtBlue = Color(0xFF1E88E5);
