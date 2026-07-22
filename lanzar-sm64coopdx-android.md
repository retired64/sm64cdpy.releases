# Lanzar SM64CoopDX desde la app — Guía de implementación

## Resumen

Añadir un botón **"Launch Game"** en el Home Screen que lance `com.maniscat2.sm64coopdx` (Super Mario 64 CoopDX para Android) usando el package `android_intent_plus`, con manejo de caso "no instalado" y diálogo post-instalación de mods.

---

## Fase 1 — Agregar dependencia y permisos

### 1.1 `pubspec.yaml`

Añadir la dependencia:

```yaml
dependencies:
  android_intent_plus: ^6.0.0   # ← AGREGAR
```

```bash
flutter pub get
```

### 1.2 `android/app/src/main/AndroidManifest.xml`

El manifest ya tiene un bloque `<queries>` (línea 70-79). Añadir dentro de `<queries>`:

```xml
<queries>
    <!-- ... queries existentes (PROCESS_TEXT, VIEW https) ... -->

    <!-- SM64CoopDX — para lanzar el juego desde el mod manager -->
    <package android:name="com.maniscat2.sm64coopdx" />
</queries>
```

**Por qué `<package>` y no `<intent>`:** Sabemos el package name exacto. Con `<package>` Android siempre permite `canResolveActivity()` y `launch()` hacia ese paquete, incluso en Android 11+. No necesitamos `QUERY_ALL_PACKAGES` (overkill).

---

## Fase 2 — Servicio `GameLauncherService`

### 2.1 Crear `lib/services/game_launcher_service.dart`

```dart
import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';

class GameLauncherService {
  GameLauncherService._();

  static const _packageName = 'com.maniscat2.sm64coopdx';

  /// Devuelve `true` si el juego está instalado.
  static Future<bool> isInstalled() async {
    if (!Platform.isAndroid) return false;
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: _packageName,
      );
      return await intent.canResolveActivity();
    } catch (e) {
      debugPrint('[GameLauncher] isInstalled error: $e');
      return false;
    }
  }

  /// Lanza el juego. Retorna `true` si se lanzó, `false` si no está instalado.
  static Future<bool> launch() async {
    if (!Platform.isAndroid) return false;
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: _packageName,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      return true;
    } catch (e) {
      debugPrint('[GameLauncher] launch error: $e');
      return false;
    }
  }
}
```

**Por qué `FLAG_ACTIVITY_NEW_TASK`:** El juego usa `launchMode="singleInstance"`. Si ya está corriendo, este flag combinado con `singleInstance` trae la instancia existente al frente sin recrear nada.

**Por qué `canResolveActivity()` en vez de `getInstalledPackages()`:** Menos invasivo, mejor rendimiento, y suficiente para nuestro caso (solo necesitamos saber si existe para lanzarlo).

---

## Fase 3 — Provider de estado del juego

### 3.1 Añadir a `lib/presentation/providers/extra_providers.dart`

```dart
import '../../services/game_launcher_service.dart';

// ── Estado del juego SM64CoopDX ────────────────────────────────────────

class GameInstalledNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> check() async {
    state = await GameLauncherService.isInstalled();
  }
}

final gameInstalledProvider = NotifierProvider<GameInstalledNotifier, bool>(
  GameInstalledNotifier.new,
);
```

---

## Fase 4 — Botón "Launch Game" en Home Screen

### 4.1 Insertar en `home_screen.dart`

El botón va como una sección más del `CustomScrollView`, entre "Browse" y "Exclusive Content" o al final — depende de la jerarquía visual deseada. **Recomendación:** entre Browse y Exclusive Content, porque es una acción primaria (no una sección de contenido).

**Importar:**
```dart
import 'package:android_intent_plus/android_intent.dart';
import '../../services/game_launcher_service.dart';
```

**Widget — al final de `_HomeBody.build()`, dentro de `slivers: [...]`:**

```dart
// ── Launch game ─────────────────────────────────────
const SliverToBoxAdapter(child: SizedBox(height: 12)),
SliverToBoxAdapter(
  child: _LaunchGameButton(),
),
```

### 4.2 Widget `_LaunchGameButton`

Diseño consistente con el lenguaje visual retro existente (skew + sombra dura + border):

```dart
class _LaunchGameButton extends ConsumerStatefulWidget {
  const _LaunchGameButton();

  @override
  ConsumerState<_LaunchGameButton> createState() => _LaunchGameButtonState();
}

class _LaunchGameButtonState extends ConsumerState<_LaunchGameButton> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final installed = await GameLauncherService.isInstalled();
    if (!mounted) return;
    ref.read(gameInstalledProvider.notifier).state = installed;
    setState(() => _checking = false);
  }

  Future<void> _launch() async {
    final launched = await GameLauncherService.launch();
    if (!mounted) return;
    if (!launched) {
      _showNotInstalledDialog();
    }
  }

  void _showNotInstalledDialog() {
    final retro = RetroTheme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: retro.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('Game not installed',
            style: retro.heading(size: 16, color: retro.red)),
        content: Text(
          'SM64CoopDX (com.maniscat2.sm64coopdx) is not installed on this device.',
          style: retro.body(size: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close',
                style: retro.body(size: 13, color: retro.inkDim)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Abrir página de descargas (GitHub Releases)
              context.go('/links-resource');
            },
            child: Text('Download',
                style: retro.body(size: 13, color: retro.accent,
                    weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    if (_checking) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: retro.surface,
            border: Border.all(color: retro.border, width: 2),
          ),
          child: Center(
            child: SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2, color: retro.accent,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: GestureDetector(
        onTap: _launch,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(-0.18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: retro.accent,
              border: Border.all(color: retro.border, width: 2),
              boxShadow: retro.hardShadow(dx: 3, dy: 3),
            ),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.skewX(0.18),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 22,
                      color: Color(0xFF20232E)),
                  SizedBox(width: 8),
                  Text('LAUNCH  GAME',
                      style: TextStyle(
                        color: Color(0xFF20232E),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      )),
                  Icon(Icons.arrow_forward, size: 18,
                      color: Color(0xFF20232E)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Fase 5 — Diálogo post-instalación de mods

### 5.1 Widget `PostInstallDialog`

Este diálogo se muestra después de instalar un mod exitosamente, avisando que si el juego ya estaba abierto, debe cerrarse y reabrirse para que los archivos nuevos se carguen.

Crear en `lib/presentation/widgets/post_install_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/retro_theme.dart';
import '../../services/game_launcher_service.dart';

Future<void> showPostInstallDialog(BuildContext context) async {
  final retro = RetroTheme.of(context);
  final isGameInstalled = await GameLauncherService.isInstalled();

  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: retro.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      title: Row(
        children: [
          Icon(Icons.check_circle, color: retro.accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Mod installed',
                style: retro.heading(size: 15)),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isGameInstalled) ...[
            Text(
              'If the game was already running, close it completely '
              '(not just minimize) and reopen it so the new files '
              'are loaded correctly.',
              style: retro.body(size: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 14, color: retro.amber),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'No force-stop or root needed — just close the game '
                    'normally and reopen it.',
                    style: retro.body(size: 11.5, color: retro.inkDim),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'Files have been copied to the mods folder.',
              style: retro.body(size: 13),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Close',
              style: retro.body(size: 13, color: retro.inkDim)),
        ),
        if (isGameInstalled)
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              GameLauncherService.launch();
            },
            child: Text('LAUNCH GAME',
                style: retro.body(size: 13, color: retro.accent,
                    weight: FontWeight.w800)),
          ),
      ],
    ),
  );
}
```

### 5.2 Integrar en `mod_detail_screen.dart`

En el `_PrimaryDownloadButton` o donde se maneje la finalización de la instalación de un mod, añadir al final del callback de éxito:

```dart
// Después de instalar exitosamente:
if (context.mounted) {
  showPostInstallDialog(context);
}
```

> **Nota:** El punto exacto de integración depende de cómo fluye la instalación actual. Buscar donde se muestra el snackbar de "Downloaded: ..." o "Installed: ..." y añadir `showPostInstallDialog` justo después.

---

## Fase 6 — Verificación

### 6.1 `flutter analyze`

```bash
flutter analyze
```

Debe dar 0 errores en `lib/`.

### 6.2 Pruebas manuales

| Escenario | Resultado esperado |
|---|---|
| Tocar "Launch Game" con juego instalado | Se abre SM64CoopDX |
| Tocar "Launch Game" sin juego instalado | Diálogo "Game not installed" con opción Download |
| Instalar mod → diálogo post-install | Diálogo con advertencia de cerrar/reabrir |
| Instalar mod → "Launch Game" en diálogo | Lanza el juego si está instalado |
| Dispositivo no-Android | Botón no se muestra, `isInstalled()` retorna `false` |

---

## Resumen de archivos modificados/creados

| Archivo | Acción |
|---|---|
| `pubspec.yaml` | +`android_intent_plus: ^6.0.0` |
| `android/app/src/main/AndroidManifest.xml` | +`<package android:name="com.maniscat2.sm64coopdx" />` en `<queries>` |
| `lib/services/game_launcher_service.dart` | **Nuevo** — `GameLauncherService` |
| `lib/presentation/providers/extra_providers.dart` | +`GameInstalledNotifier` + `gameInstalledProvider` |
| `lib/presentation/screens/home_screen.dart` | +`_LaunchGameButton` en slivers |
| `lib/presentation/widgets/post_install_dialog.dart` | **Nuevo** — `showPostInstallDialog` |
| `lib/presentation/screens/mod_detail_screen.dart` | +llamada a `showPostInstallDialog` tras instalar |

---

## Decisiones de diseño

| Decisión | Justificación |
|---|---|
| `android_intent_plus` en vez de `url_launcher` | `url_launcher` no soporta lanzar por package name con `FLAG_ACTIVITY_NEW_TASK`. `android_intent_plus` sí. |
| `<package>` en vez de `<intent>` en queries | Más específico y ligero. Solo necesitamos visibilidad de un paquete concreto. |
| Servicio en vez de lógica inline | Reutilizable desde Home, post-install dialog, y futuro widget flotante. |
| Provider para `isInstalled` | Evita llamar a Android en cada rebuild. Se cachea al iniciar Home. |
| Botón con skew (matriz) | Consistente con `_ExclusiveCard` y `SkewChip` — el diseño "anime panel" de la app. |
| `singleInstance` + `FLAG_ACTIVITY_NEW_TASK` | Reutiliza la instancia existente del juego. No crea duplicados. |
