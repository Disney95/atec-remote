# ATEC Remote

App de control remoto IR que replica el TV **ATEC-Haier 29T5A**, la cajita
decodificadora **ATEC HD-NCE20** y el split **Mystic MY-ASR1284**.

## Estructura

```
lib/
  main.dart                  # punto de entrada
  screens/
    home_screen.dart         # toggle entre los 3 equipos
    tv_remote_screen.dart    # UI del TV (protocolo NEC simple)
    box_remote_screen.dart   # UI de la cajita (protocolo NEC simple)
    split_remote_screen.dart # UI del split (protocolo por estado)
  models/
    ir_device.dart           # modelo para TV/cajita (código por botón)
    ac_state.dart            # modelo de estado para el split
  services/
    ir_service.dart          # puente con ConsumerIrManager + conversión NEC
  theme/app_theme.dart       # paletas inspiradas en cada control físico
  widgets/remote_button.dart # botón con haptics + animación de presión
assets/codes/
  atec_tv.json               # códigos del TV (PLACEHOLDER)
  atec_box.json               # códigos de la cajita (PLACEHOLDER)
  mystic_split.json          # esqueleto del protocolo del split (PLACEHOLDER)
android/app/src/main/kotlin/.../MainActivity.kt
                              # implementación nativa de ConsumerIrManager
```

## Cómo correrla

```bash
flutter pub get
flutter run
```

Necesitas un teléfono Android físico con emisor IR (blaster). La mayoría de
los teléfonos actuales **no tienen esta pieza de hardware** — si no la
tiene, la app entra en **modo sandbox**: la interfaz funciona igual, pero no
sale señal real. Vas a ver un aviso naranja en pantalla cuando esto pase.

## Modo escaneo (pestaña "Escanear")

Mientras consigues el hardware para capturar los códigos reales, la app
incluye una pestaña que prueba, botón POWER únicamente, una lista corta de
códigos NEC **públicos y verificables** que pertenecen a OTROS equipos (LG
STB, Vizio TV, Blaupunkt), por si el chasis interno de tus equipos resulta
compartir el mismo diseño (pasa seguido con electrónica china genérica
rebrandeada). **No hay garantía de que alguno funcione** — es la misma
técnica de prueba y error que usan los controles universales baratos.

- Fuente de cada candidato: LIRC / RemoteMaster / foros de hifi-remote.com
  (todo de dominio público, sin relación directa confirmada con ATEC/Haier).
- Si uno funciona, toca "¡Funcionó! Usar este código": se guarda localmente
  en el teléfono (con `shared_preferences`) y la pantalla del control real
  lo usa automáticamente de inmediato para el botón POWER.
- Para que quede en el proyecto (y no se pierda si reinstalas la app),
  copia el valor hex mostrado al archivo JSON correspondiente
  (`atec_tv.json` o `atec_box.json`).
- La lista de candidatos vive en `assets/codes/scan_candidates_tv.json` y
  `scan_candidates_box.json` — se pueden agregar más entradas ahí en
  cualquier momento.
- El split (Mystic) no tiene modo escaneo todavía: al ser protocolo por
  estado (no un código corto por botón), no se puede "adivinar" con la
  misma técnica.

## Lo que falta antes de que controle tus equipos de verdad

### 1. Códigos del TV y la cajita (`atec_tv.json`, `atec_box.json`)

Todos los códigos están en `0x00000000` — son placeholders. Para
conseguir los reales:

1. Consigue un receptor IR (ej. módulo TSOP38238) + un Arduino/ESP32.
2. Usa la librería `IRremote` (Arduino) para capturar cada botón del
   control físico: apunta el control al receptor, presiona un botón, anota
   el código que imprime por el puerto serie.
3. Reemplaza el valor correspondiente en el JSON, ej:
   `"POWER": "0x00FF00FF"`.
4. El punto rojo que aparece en la esquina de cada botón en la app
   desaparece automáticamente en cuanto el código deja de ser
   `0x00000000` (ver `IrDevice.isPlaceholder`).

### 2. Protocolo del split (`mystic_split.json`)

Este caso es más complejo: los splits no usan un código corto por botón,
sino que reenvían **el estado completo** (temperatura + modo + velocidad +
swing + timer) cada vez, en un protocolo propietario de 30-120+ bits.

Pasos sugeridos:
1. Captura en modo **RAW** (no NEC) con `IRremoteESP8266` los pulsos de
   varios botones del control real del Mystic.
2. Cambia **un solo parámetro a la vez** (por ejemplo, solo la
   temperatura de 24° a 25°) y compara los dos paquetes raw para ver qué
   bits cambiaron — así vas aislando qué controla cada bit.
3. Una vez entendida la estructura, implementa una función
   `AcState -> List<int> (patrón raw)` en `ir_service.dart`
   (reemplazando el actual `sendAcState`, que hoy solo imprime en modo
   sandbox y no transmite nada).

### 3. Logos e íconos

La app usa paletas de color y formas inspiradas en los controles reales,
pero **no reproduce los logos de ATEC/Haier/Mystic** (son marcas
registradas). Si quieres un ícono de lanzador con marca propia, hay que
diseñarlo aparte.
