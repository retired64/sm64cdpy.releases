# Guía de uso del sistema OTA (GitHub Releases)

## 1. Cómo funciona

```
┌──────────────┐     ┌─────────────────────┐     ┌──────────────────┐
│  App inicia  │────▶│ UpdateService.init() │────▶│ PackageInfoPlus  │
│  (main.dart) │     │ obtiene versión local│     │ lee pubspec.yaml │
└──────────────┘     └─────────────────────┘     └──────────────────┘
                                                         │
                                                    "1.2.0"
                                                         │
                                                         ▼
┌──────────────┐     ┌─────────────────────┐     ┌──────────────────┐
│ SM64CoopDXApp│────▶│ _checkForUpdates()  │────▶│ GET api.github   │
│ initState()  │     │ post-frame callback │     │ .com/repos/...   │
└──────────────┘     └─────────────────────┘     │ /releases/latest │
                                                  └──────────────────┘
                                                         │
                                                   Respuesta JSON
                                                   con tag_name,
                                                   assets, body...
                                                         │
                                                         ▼
┌──────────────┐     ┌─────────────────────┐     ┌──────────────────┐
│ UpdateDialog │◀────│ isVersionLower()    │◀────│ UpdateConfig     │
│ (UI descarga)│     │ compara "1.2.0"     │     │ .fromGithubRel() │
│              │     │ vs tag remoto       │     │ parsea JSON      │
└──────────────┘     └─────────────────────┘     └──────────────────┘
```

### 1.1 Componentes clave

| Archivo | Función |
|---|---|
| `lib/services/update_service.dart` | Consulta la API de GitHub, detecta ABI, compara versiones |
| `lib/services/update_config.dart` | Parsea el JSON de la release y selecciona el APK correcto |
| `lib/widgets/update_dialog.dart` | UI del diálogo: progreso, errores, botón de descarga |
| `lib/main.dart` | Punto de integración: init en `main()`, check en `initState()` |
| `android/.../AndroidManifest.xml` | Permisos + FileProvider + InstallResultReceiver |
| `android/.../res/xml/file_paths.xml` | Rutas para almacenar el APK temporal |
| `android/app/build.gradle.kts` | `minSdk=24`, core library desugaring |

---

## 2. Cómo lanzar una nueva versión (paso a paso)

### 2.1 Actualizar la versión en el proyecto

Antes de generar el APK, actualiza **dos lugares**:

#### a) `pubspec.yaml` — línea 3
```yaml
version: 1.3.0+5
#         │     │
#         │     └── versionCode (entero, incremental)
#         └──────── versionName (X.Y.Z, semántico)
```

Reglas:
- **versionName** (ej: `1.3.0`): debe ser X.Y.Z, sin prefijo `v`. Es lo que `package_info_plus` leerá en runtime y lo que se compara contra el `tag_name` de GitHub.
- **versionCode** (ej: `5`): entero incremental. Android lo usa internamente. **No puede repetirse ni decrecer.** El build.gradle.kts ya lo multiplica por 10 y suma el código de ABI para los splits.

#### b) Si usas constantes de versión en la UI
Revisa `lib/presentation/screens/changelog_screen.dart` y `lib/core/constants/app_constants.dart` si referencian la versión. Actualízalos si es necesario.

### 2.2 Generar los APKs

```bash
cd ~/APPDUMP/source-code

# Limpiar builds anteriores
flutter clean && flutter pub get

# Generar APK único (todas las arquitecturas)
flutter build apk --release

# O generar APKs split por ABI (RECOMENDADO para releases)
flutter build apk --release --split-per-abi
```

Los APKs se generan en `build/app/outputs/flutter-apk/`:
```
app-arm64-v8a-release.apk   → dispositivos modernos 64-bit (2018+)
app-armeabi-v7a-release.apk → dispositivos 32-bit antiguos
app-x86_64-release.apk      → emuladores
```

### 2.3 Crear la release en GitHub

1. Ve a https://github.com/retired64/sm64cdpy.releases/releases
2. Haz clic en **"Draft a new release"**
3. Configura los campos:

| Campo | Valor | Ejemplo |
|---|---|---|
| **Tag version** | `v` + versionName de pubspec.yaml | `v1.3.0` |
| **Release title** | Nombre descriptivo | `Sm64CDPY v1.3.0` |
| **Description** | Changelog (aparecerá en el diálogo OTA) | Ver sección 2.4 |

4. **IMPORTANTE — Nombrar los APKs correctamente:**

El sistema OTA selecciona el APK según la ABI del dispositivo buscando palabras clave en el nombre del archivo. Los nombres **deben** contener:

| Arquitectura | Palabra clave en el nombre | Ejemplo |
|---|---|---|
| `arm64-v8a` | `arm64` | `Sm64CDPYv1.3.0-arm64.apk` |
| `armeabi-v7a` | `arm32` | `Sm64CDPYv1.3.0-arm32.apk` |
| `x86_64` | `x86_64` | `Sm64CDPYv1.3.0-x86_64.apk` |

**Estructura de nombres recomendada:**
```
Sm64CDPYv1.3.0-arm64.apk
Sm64CDPYv1.3.0-arm32.apk
Sm64CDPYv1.3.0-x86_64.apk
```

El nombre **debe** contener la palabra clave de ABI y terminar en `.apk`. Si no se encuentra un asset para la ABI del dispositivo, se usa el primer `.apk` listado como fallback.

5. Sube los 3 APKs como assets de la release
6. Haz clic en **"Publish release"**

### 2.4 Escribir un buen changelog

El campo `body` de la release se muestra en el diálogo de actualización (máx. 6 líneas visibles). Formato recomendado:

```markdown
## Novedades
- Nueva sección de X para navegar Y
- Soporte para Z en el catálogo

## Mejoras
- Rendimiento optimizado en listas largas
- Corrección de crash al filtrar por tag vacío
```

**Buenas prácticas:**
- Usa bullet points (`-`) o listas numeradas
- Separa en secciones: Novedades, Mejoras, Correcciones
- Sé conciso — los usuarios ven esto en un AlertDialog pequeño
- No incluyas enlaces complejos (no serán cliqueables)

---

## 3. Reglas de versionamiento

### 3.1 Comparación de versiones

El método `isVersionLower()` en `update_service.dart` compara versiones en formato **X.Y.Z**:

```
isVersionLower("1.2.0", "1.3.0") → true  (hay update)
isVersionLower("1.3.0", "1.3.0") → false (misma versión)
isVersionLower("1.10.0", "1.2.0") → false (1.10 > 1.2)
isVersionLower("2.0.0", "1.9.9") → false (2.0 > 1.9)
```

### 3.2 Reglas estrictas

1. **El `versionName` en `pubspec.yaml` NO lleva prefijo `v`** → `1.3.0` ✓, `v1.3.0` ✗
2. **El `tag_name` en GitHub SÍ lleva prefijo `v`** → `v1.3.0` ✓, `1.3.0` ✗
3. **El `versionCode` debe ser incremental** → si el último fue `4`, el nuevo debe ser `5`
4. **No puede haber dos releases con el mismo `tag_name`** — GitHub lo rechaza
5. **Los nombres de APK deben contener la palabra clave de ABI** — ver tabla en 2.3

### 3.3 Qué pasa si rompes una regla

| Error | Consecuencia |
|---|---|
| `versionName` sin actualizar | La app nunca detectará la nueva versión |
| `tag_name` sin prefijo `v` | `UpdateConfig.fromGithubRelease()` no lo reconocerá, versión resultante `"0.0.0"` |
| APK sin keyword de ABI | Se usará un fallback (primer .apk encontrado), posiblemente incompatible |
| `versionCode` repetido | Google Play rechazará la subida; instalación manual fallará |
| Sin assets en la release | `checkForUpdates()` retornará `null`, no se mostrará diálogo |

---

## 4. Flujo desde la perspectiva del usuario

```
1. Usuario abre la app
2. La app consulta silenciosamente la GitHub API
3. Si NO hay internet → no pasa nada, no se molesta al usuario
4. Si la app está actualizada → no pasa nada
5. Si hay versión nueva:
   ┌──────────────────────────────────────┐
   │  Nueva versión disponible            │
   │                                      │
   │  Versión 1.3.0 disponible            │
   │  Tamaño: 21.2 MB                     │
   │                                      │
   │  Novedades:                          │
   │  - Nueva sección de X               │
   │  - Corrección de crashes            │
   │                                      │
   │  [MÁS TARDE]    [ACTUALIZAR AHORA]   │
   └──────────────────────────────────────┘
   
   Si pulsa ACTUALIZAR AHORA:
   - Android mostrará diálogo de permisos de instalación
   - Barra de progreso de descarga
   - Al terminar, Android instala el APK automáticamente
   
   Si pulsa MÁS TARDE:
   - El diálogo se cierra
   - La próxima vez que abra la app, se volverá a verificar
```

### 4.1 Manejo de errores visibles al usuario

| Error | Mensaje |
|---|---|
| Sin conexión | No se muestra nada |
| Permiso de instalación denegado | "Ve a Ajustes → Apps → esta app → Instalar apps desconocidas" |
| Descarga fallida | "Error de descarga. Verifica tu conexión." |
| APK corrupto (checksum) | "El archivo descargado está corrupto. Intenta de nuevo." |
| Error interno | Muestra el error + botón "Abrir en navegador" como fallback |

---

## 5. Pruebas del sistema OTA

### 5.1 Simular una actualización en desarrollo

El sistema OTA **no tiene modo staging**. La forma más segura de probar es:

**Opción A — Con una release real (recomendado para pre-release):**
1. Crea una release en GitHub con tag `v9.9.9` (versión absurdamente alta)
2. Sube APKs de prueba con los nombres correctos
3. La app (v1.2.0) detectará `v9.9.9` como update disponible
4. Verifica que el diálogo aparece, la descarga funciona y la instalación se completa
5. **Después de probar, ELIMINA la release v9.9.9** para no confundir a usuarios reales

**Opción B — Mock local (solo para debugging):**
1. En `update_service.dart`, comenta la llamada HTTP real
2. Retorna un `UpdateConfig` hardcodeado con `latestVersion: '99.0.0'`
3. Verifica el diálogo y la UI
4. **NO puedes probar la descarga real** con este método

### 5.2 Tests manuales recomendados antes de cada release

- [ ] La app actual (versión anterior) detecta la nueva release
- [ ] El APK de `arm64` se descarga en un dispositivo arm64 real
- [ ] El APK de `arm32` se descarga en un dispositivo arm32 real
- [ ] El diálogo muestra el changelog correctamente
- [ ] El botón "MÁS TARDE" cierra el diálogo sin instalar
- [ ] El botón "ACTUALIZAR AHORA" inicia la descarga
- [ ] La barra de progreso avanza durante la descarga
- [ ] La instalación se completa y la app se actualiza
- [ ] La app actualizada no vuelve a mostrar el diálogo de update
- [ ] Si se corta el internet durante la descarga, se muestra error

### 5.3 Debug logs

El sistema imprime logs con tag `[UpdateService]` visibles en `flutter run` o `adb logcat`:

```
[UpdateService] Versión instalada: 1.2.0
[UpdateService] ABI detectada: arm64-v8a
[UpdateService] Versión remota: 1.3.0
[UpdateService] URL APK: https://github.com/.../Sm64CDPYv1.3.0-arm64.apk
[UpdateService] Actualización disponible
```

---

## 6. Configuraciones y parámetros ajustables

### 6.1 Timeout de la API

En `lib/services/update_service.dart:46`:
```dart
.timeout(const Duration(seconds: 15))
```
Si los APKs son muy pesados o la API tarda, aumenta este valor. 15s es suficiente para la respuesta JSON de la API (no para la descarga del APK).

### 6.2 Forzar actualización (force update)

Actualmente `forceUpdate` siempre es `false` porque GitHub Releases no expone ese campo. Si en el futuro necesitas forzar actualización:

```dart
// En update_config.dart, línea del factory:
forceUpdate: json['prerelease'] == false ? false : false,
//                          ↑ cambiar según criterio

// En main.dart, línea del UpdateDialog:
isForce: config.forceUpdate,
```

Cuando `isForce: true`, el diálogo no se puede cerrar y el botón "SALIR" cierra la app.

### 6.3 Rate limiting de GitHub API

La API anónima de GitHub permite **60 requests/hora por IP**. Para una app de usuario final esto es más que suficiente (1 request al iniciar la app). Si en el futuro necesitas más:

1. Crea un token de acceso personal (PAT) en GitHub Settings → Developer settings
2. Agrega el header en `update_service.dart`:
```dart
headers: {
  'Authorization': 'token ghp_tu_token_aqui',
  'Accept': 'application/vnd.github.v3+json',
}
```

**NO incluyas el token en el código fuente.** Si lo necesitas, usa variables de entorno o un backend intermedio.

### 6.4 Cambiar el repositorio de releases

Si el repositorio cambia, actualiza **dos lugares**:

1. `lib/services/update_service.dart` línea 15:
```dart
static const String _githubApiUrl =
    'https://api.github.com/repos/NUEVO_DUEÑO/NUEVO_REPO/releases/latest';
```

2. `lib/widgets/update_dialog.dart` en el método `_openInBrowser()`:
```dart
final uri = Uri.parse(
    'https://github.com/NUEVO_DUEÑO/NUEVO_REPO/releases/latest',
);
```

---

## 7. Checklist pre-release

Copia esta lista cada vez que vayas a lanzar una versión nueva:

```
□ pubspec.yaml: versionName y versionCode actualizados
□ Changelog escrito en lib/presentation/screens/changelog_screen.dart
□ AppConstants actualizados si referencian versión
□ flutter clean && flutter pub get
□ flutter analyze sin errores nuevos
□ flutter build apk --release --split-per-abi exitoso
□ Los 3 APKs tienen nombres con keyword de ABI (arm64, arm32, x86_64)
□ Release creada en GitHub con tag vX.Y.Z (prefijo v)
□ Changelog en el body de la release
□ Probar detección de update en dispositivo real
□ Probar descarga e instalación en al menos 1 dispositivo
□ Eliminar releases de prueba (v9.9.9, etc.)
```

---

## 8. Preguntas frecuentes

### ¿Cada cuánto se verifica si hay updates?
Una vez al iniciar la app, en el primer frame después de `runApp()`. El flag `_updateChecked` evita verificaciones duplicadas.

### ¿Qué pasa si el usuario no tiene conexión?
`checkForUpdates()` captura la excepción y retorna `null`. No se muestra ningún diálogo. La app funciona normalmente.

### ¿Se descarga el APK en segundo plano?
No. El usuario debe pulsar "ACTUALIZAR AHORA" explícitamente. La descarga es visible con barra de progreso.

### ¿Qué pasa si el usuario minimiza la app durante la descarga?
La descarga continúa en background (el plugin `ota_update` usa un `ForegroundService` en Android). Cuando termine, Android mostrará el diálogo de instalación.

### ¿Y si el APK descargado está corrupto?
El plugin `ota_update` verifica el hash SHA-256 del archivo descargado. Si no coincide, emite `CHECKSUM_ERROR` y se muestra el error al usuario.

### ¿Puedo usar este sistema en iOS?
No. El sistema OTA está diseñado exclusivamente para Android (APK sideloading). En iOS, `_canOtaUpdate` retorna `false` y el botón abre el navegador.

---

## 9. Limitaciones actuales

1. **Detección de ABI por hardware**: el método `_getDeviceAbi()` retorna `arm64-v8a` fijo. Para una detección real por hardware se necesitaría un platform channel nativo o el plugin `device_info_plus`. El fallback a `arm64` cubre la mayoría de dispositivos modernos (2018+).

2. **Sin cache de la respuesta**: cada inicio de app consulta la API. Si el usuario abre/cierra la app 60+ veces en una hora, podría alcanzar el rate limit. En la práctica esto no ocurre.

3. **Sin delta updates**: siempre se descarga el APK completo (~22 MB). No hay parches binarios incrementales.

4. **Sin rollback**: si una versión tiene un bug crítico, no hay mecanismo automático de downgrade. El usuario debería descargar manualmente una versión anterior del repositorio.
