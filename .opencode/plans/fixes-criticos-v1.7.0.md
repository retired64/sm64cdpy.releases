# Plan de implementación — Fixes críticos v1.7.0

**Fecha:** 2026-07-28
**Modo:** Solo plan (read-only). No ejecutar sin autorización explícita.
**Orden:** Aplicar en el orden listado. Cada paso es independiente y se puede verificar tras aplicarlo.

---

## PASO 1 — [1.1] `cleanupObservers()` nunca limpia

**Archivo:** `android/app/src/main/kotlin/mods/sm64cdpy/ModInstallerPlugin.kt`
**Líneas:** 126-129
**Fix:** Invertir orden de 2 líneas.

### Código actual (:126-129)
```kotlin
    override fun onDetachedFromActivity() {
        activity = null
        cleanupObservers()
    }
```

### Código nuevo
```kotlin
    override fun onDetachedFromActivity() {
        cleanupObservers()
        activity = null
    }
```

**Verificación:** Rotar pantalla 3+ veces con una descarga en curso → no deben acumularse observers (verificar con Android Profiler o logs nativos).

---

## PASO 2 — [2.2] Sanitización ZIP con bypass de path-traversal

**Archivos (2):**
1. `android/app/src/main/kotlin/mods/sm64cdpy/ModInstallWorker.kt:376-383`
2. `android/app/src/main/kotlin/mods/sm64cdpy/ModInstallerPlugin.kt:1208-1215`

**Fix:** Reemplazar el `sanitizeEntryName` en ambos archivos por la versión de segmentos.

### Código actual (en ambos archivos, idéntico)
```kotlin
    private fun sanitizeEntryName(name: String): String {
        var sanitized = name.trim()
        while (sanitized.startsWith("/")) sanitized = sanitized.substring(1)
        sanitized = sanitized.replace("../", "").replace("..\\", "")
        sanitized = sanitized.replace("\\", "/")
        sanitized = sanitized.replace("\u0000", "")
        return sanitized
    }
```

### Código nuevo (aplicar en ambos archivos)
```kotlin
    private fun sanitizeEntryName(name: String): String {
        var sanitized = name.trim().replace("\\", "/").replace("\u0000", "")
        while (sanitized.startsWith("/")) sanitized = sanitized.substring(1)
        val parts = sanitized.split("/").filter { it.isNotEmpty() && it != "." && it != ".." }
        return parts.joinToString("/")
    }
```

**Verificación:** Build exitoso. Si quieres pruebas adicionales, crear un ZIP con una entrada llamada `"..././evil.txt"` y confirmar que la ruta resultante no contiene `..`.

---

## PASO 3 — [2.1] Redirects encadenados en `ModDownloadWorker`

**Archivo:** `android/app/src/main/kotlin/mods/sm64cdpy/ModDownloadWorker.kt`
**Líneas:** 83-99

**Fix:** Reemplazar el bloque `if` de un solo redirect por un loop acotado a 5 saltos, replicando `Accept-Encoding` en cada iteración.

### Código actual (:83-99)
```kotlin
            connection = url.openConnection() as HttpURLConnection
            connection.instanceFollowRedirects = true
            connection.connectTimeout = 15000
            connection.readTimeout = 30000
            connection.setRequestProperty("Accept-Encoding", "identity")
            connection.connect()

            if (connection.responseCode in 300..399) {
                val redirectUrl = connection.getHeaderField("Location")
                connection.disconnect()
                if (redirectUrl != null) {
                    connection = URL(redirectUrl).openConnection() as HttpURLConnection
                    connection.instanceFollowRedirects = false
                    connection.connectTimeout = 15000
                    connection.readTimeout = 30000
                    connection.connect()
                }
            }
```

### Código nuevo
```kotlin
            connection = url.openConnection() as HttpURLConnection
            connection.instanceFollowRedirects = false
            connection.connectTimeout = 15000
            connection.readTimeout = 30000
            connection.setRequestProperty("Accept-Encoding", "identity")

            var redirectsLeft = 5
            while (redirectsLeft > 0 && connection.responseCode in 300..399) {
                val redirectUrl = connection.getHeaderField("Location")
                connection.disconnect()
                if (redirectUrl == null) break
                connection = URL(redirectUrl).openConnection() as HttpURLConnection
                connection.instanceFollowRedirects = false
                connection.connectTimeout = 15000
                connection.readTimeout = 30000
                connection.setRequestProperty("Accept-Encoding", "identity")
                connection.connect()
                redirectsLeft--
            }
```

**Verificación:** Usar una URL que haga al menos 2 redirects (ej. un link de acortador + redirect de CDN). Confirmar que la descarga llega a `inputStream` sin `IOException`.

---

## PASO 4 — [2.3] Race condition `ThemeNotifier._box` / `LocaleNotifier._box`

**Archivo:** `lib/presentation/providers/theme_provider.dart`
**Líneas:** 15-22 (ThemeNotifier), 116-120 (LocaleNotifier)

**Estrategia:** En lugar de abrir la Hive box con `Future.microtask` en cada `build()`, abrirla una sola vez en `main.dart` y pasar la box ya lista a ambos notifiers.

### Plan de implementación

#### 4a. Agregar inicialización en `lib/main.dart`

Buscar la sección de inicialización en `main()` (donde se llama a `Hive.initFlutter()` o similar) y asegurar que la box `settings` esté abierta antes de `runApp()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... Hive.initFlutter() etc ...
  await Hive.openBox<String>(AppConstants.settingsBoxKey);
  // ... resto de inicialización ...
  runApp(const ProviderScope(child: MyApp()));
}
```

Si la box ya se abre en `main()`, solo hay que eliminar las aperturas redundantes en los notifiers.

#### 4b. Simplificar `ThemeNotifier`

### Código actual (`theme_provider.dart:9-36`)
```dart
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    Future.microtask(() => _loadSavedTheme());
    return ThemeMode.system;
  }

  late final Box<String> _box;

  Future<void> _loadSavedTheme() async {
    try {
      _box = await Hive.openBox<String>(AppConstants.settingsBoxKey);
      final savedTheme = _box.get('theme_mode', defaultValue: 'system');
      // ...
    }
  }
}
```

### Código nuevo
```dart
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = Hive.box<String>(AppConstants.settingsBoxKey);
    final savedTheme = box.get('theme_mode', defaultValue: 'system');
    return switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      await Hive.box<String>(AppConstants.settingsBoxKey)
          .put('theme_mode', _themeModeToString(mode));
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }
  // ... toggleTheme, isDarkMode, displayName, _themeModeToString igual ...
}
```

#### 4c. Simplificar `LocaleNotifier` (mismo patrón)

### Código actual (`theme_provider.dart:111-143`)
```dart
class LocaleNotifier extends Notifier<String?> {
  @override
  String? build() {
    Future.microtask(() => _loadSavedLocale());
    return null;
  }

  late final Box<String> _box;

  Future<void> _loadSavedLocale() async {
    try {
      _box = await Hive.openBox<String>(AppConstants.settingsBoxKey);
      final saved = _box.get('locale', defaultValue: 'system');
      // ...
    }
  }

  Future<void> setLocale(String? tag) async {
    state = tag;
    try {
      await _box.put('locale', tag ?? 'system');
    }
  }
}
```

### Código nuevo
```dart
class LocaleNotifier extends Notifier<String?> {
  @override
  String? build() {
    final box = Hive.box<String>(AppConstants.settingsBoxKey);
    final saved = box.get('locale', defaultValue: 'system');
    if (saved == 'system') return null;
    if (['en_US', 'es_419', 'pt_BR'].contains(saved)) return saved;
    return null;
  }

  Future<void> setLocale(String? tag) async {
    state = tag;
    try {
      await Hive.box<String>(AppConstants.settingsBoxKey)
          .put('locale', tag ?? 'system');
    } catch (e) {
      debugPrint('Failed to save locale preference: $e');
    }
  }
  // ... locale, localeFromTag igual ...
}
```

**Verificación:** `Hive.openBox<String>(AppConstants.settingsBoxKey)` debe ejecutarse en `main()` antes de `runApp()`. El `build()` de ambos notifiers es síncrono con `Hive.box<String>()` (abre una box ya abierta, es O(1)). No más `late final _box`, no más `Future.microtask`. Si toggleas tema inmediatamente al abrir la app, debe persistir.

---

## PASO 5 — [2.4] `String.fromCharCodes` → `utf8.decode`

**Archivo:** `lib/presentation/providers/mod_providers.dart:330`

### Código actual
```dart
      final raw = String.fromCharCodes(bytes);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
```

### Código nuevo
```dart
      final raw = utf8.decode(bytes);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
```

**Verificación:** `utf8` ya está importado (`import 'dart:convert'` en la cabecera). Build exitoso.

---

## PASO 6 — [2.6] Agregar `.zip` al fallback de `_inferFileName`

**Archivo:** `lib/services/download_url_resolver.dart:51`

### Código actual
```dart
  return '$safeName$suffix';
```

### Código nuevo
```dart
  return '$safeName$suffix.zip';
```

**Verificación:** Descargar un mod desde una URL sin nombre de archivo detectable (ej. `https://example.com/download?id=123` con Content-Disposition vacío). El archivo descargado debe tener extensión `.zip` y `ModDownloadWorker` debe tratarlo como ZIP.

---

## PASO 7 — [2.5] Limpiar `_titleByModName` al terminar

**Archivo:** `lib/overlay/overlay_bridge.dart`
**Líneas:** 63-91 (`_forwardEventToOverlay`)

**Fix:** Agregar `_titleByModName.remove(event.modName)` en los casos terminales: `BgInstallCompleted`, `BgOperationCancelled`, `BgInstallError`.

### Ubicación exacta del cambio

Dentro de `_forwardEventToOverlay`, en cada `case` terminal, agregar la limpieza:

```dart
      case BgInstallCompleted(fileCount: final f, targetDir: final d):
        _titleByModName.remove(event.modName);   // ← nuevo
        payload['status'] = 'completed';
        payload['fileCount'] = f;
        payload['targetDir'] = d;
        break;
      case BgOperationCancelled():
        _titleByModName.remove(event.modName);   // ← nuevo
        payload['status'] = 'cancelled';
        break;
      case BgInstallError(error: final e):
        _titleByModName.remove(event.modName);   // ← nuevo
        payload['type'] = 'install_error';
        payload['error'] = e;
        break;
```

**Verificación:** Hacer 10 descargas desde el overlay. Al finalizar todas, `_titleByModName` debe estar vacío (verificable con `debugPrint` temporal).

---

## PASO 8 — [3.1] Snackbar si falla `launchUrl` en links sociales

**Archivo:** `lib/presentation/widgets/app_drawer.dart:880-885`

### Código actual
```dart
  Future<void> _launch() async {
    final uri = Uri.parse(widget.link.url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
```

### Código nuevo
```dart
  Future<void> _launch() async {
    final uri = Uri.parse(widget.link.url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }
```

**Verificación:** Tocar un botón de link social con la app que maneja el URI desinstalada → debe aparecer snackbar, no silencio.

---

## PASO 9 — [3.2] Snackbar si falla arranque del overlay

**Archivo:** `lib/presentation/screens/settings_screen.dart:1340`

### Código actual (~:1328-1341)
```dart
      try {
        if (!await FloatyChatheads.isOverlayPermissionGranted()) {
          await FloatyChatheads.requestOverlayPermission();
        }
        // No auto-request notification permission here ...
        if (!await FloatyChatheads.isOverlayPermissionGranted()) {
          return;
        }
        await FloatyChatheads.showChatHead(
          entryPoint: 'overlayMain',
          contentWidth: 260,
          contentHeight: 340,
          persistOnAppClose: true,
        );
      }
      await _check();
    } catch (_) {}
```

### Código nuevo
```dart
      try {
        if (!await FloatyChatheads.isOverlayPermissionGranted()) {
          await FloatyChatheads.requestOverlayPermission();
        }
        if (!await FloatyChatheads.isOverlayPermissionGranted()) {
          return;
        }
        await FloatyChatheads.showChatHead(
          entryPoint: 'overlayMain',
          contentWidth: 260,
          contentHeight: 340,
          persistOnAppClose: true,
        );
      }
      await _check();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to start overlay. Check permissions.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
```

**Verificación:** Intentar abrir el overlay sin permiso `SYSTEM_ALERT_WINDOW` → debe aparecer snackbar de error, no apagarse el spinner silenciosamente.

---

## PASO 10 — Miscelánea de deuda técnica

### 10a. [6.1] `FileDownloader.setLogEnabled` condicionado a debug

**Archivo:** `lib/main.dart:32`

```dart
// Código actual
FileDownloader.setLogEnabled(true);
// Código nuevo
FileDownloader.setLogEnabled(kDebugMode);
```

### 10b. [6.5] `existsSync` → `await exists`

**Archivo:** `lib/data/datasource/local_mod_datasource.dart:151`

Buscar y cambiar `file.existsSync()` → `await file.exists()`.

### 10c. [6.4] Borrar comentarios TODO en `build.gradle.kts`

**Archivo:** `android/app/build.gradle.kts`

Eliminar las líneas:
```
// TODO: Specify your own unique Application ID ...
// TODO: Add your own signing config ...
```

### 10d. [5.3] Eliminar `favoritesBoxKey`

**Archivo:** `lib/core/constants/app_constants.dart:9`

Eliminar:
```dart
  static const String favoritesBoxKey = 'favorites';
```

### 10e. [5.2] Centralizar URL en `update_dialog.dart`

**Archivo 1:** `lib/core/constants/app_constants.dart` — agregar:
```dart
  static const String githubReleasesLatestUrl =
      'https://github.com/retired64/sm64cdpy.releases/releases/latest';
```

**Archivo 2:** `lib/widgets/update_dialog.dart:144` — cambiar:
```dart
// Código actual
'https://github.com/retired64/sm64cdpy.releases/releases/latest',
// Código nuevo
AppConstants.githubReleasesLatestUrl,
```

### 10f. [5.1] Reemplazar `AppConstants.appVersion` → `UpdateService.currentVersion`

**Archivos afectados (4):**
- `lib/core/constants/app_constants.dart:18` — eliminar `static const String appVersion = '1.6.2';`
- `lib/presentation/screens/disclaimer_screen.dart:76,117,179` — cambiar `AppConstants.appVersion` → `UpdateService.currentVersion`
- `lib/presentation/screens/settings_screen.dart:106` — mismo cambio
- `lib/presentation/widgets/app_drawer.dart:184` — mismo cambio

Verificar que `UpdateService.init()` se llama en `main()` antes de `runApp()` (ya está confirmado en `main.dart`).

### 10g. [6.2] Eliminar `BackgroundInstallService.dispose()` (o conectarlo)

Si no se va a usar:
**Archivo:** `lib/services/background_install_service.dart:122-127` — eliminar método `dispose()`.

Si se quiere conectar a lifecycle (opcional, baja prioridad):
Agregar en `main.dart` o en el widget raíz un `WidgetsBindingObserver` que llame a `dispose()` cuando la app se destruye.

---

## Resumen: 10 pasos, ~18 cambios en ~12 archivos

| Paso | Archivo | Cambio | Esfuerzo |
|------|---------|--------|----------|
| 1 | `ModInstallerPlugin.kt` | Invertir 2 líneas en `onDetachedFromActivity` | 1 línea |
| 2 | `ModInstallWorker.kt` + `ModInstallerPlugin.kt` | `sanitizeEntryName` con split/filter (×2) | 6 líneas × 2 |
| 3 | `ModDownloadWorker.kt` | Loop de redirects máx. 5 saltos | ~15 líneas |
| 4 | `theme_provider.dart` | `build()` síncrono con `Hive.box<>()`, quitar `late final _box` + `Future.microtask` | ~15 líneas |
| 5 | `mod_providers.dart` | `utf8.decode` en vez de `String.fromCharCodes` | 1 línea |
| 6 | `download_url_resolver.dart` | Agregar `.zip` al fallback | 1 carácter |
| 7 | `overlay_bridge.dart` | `_titleByModName.remove()` en 3 cases | 3 líneas |
| 8 | `app_drawer.dart` | Snackbar en catch de `_launch` | 3 líneas |
| 9 | `settings_screen.dart` | Snackbar en catch de overlay toggle | 3 líneas |
| 10 | 6 archivos misc. | `kDebugMode`, `exists()`, TODO comments, constantes muertas, etc. | ~12 líneas total |

**Tiempo estimado de implementación:** ~30 minutos (los cambios son todos pequeños y localizados).
**Tiempo estimado de build + verificación:** ~15 minutos.
