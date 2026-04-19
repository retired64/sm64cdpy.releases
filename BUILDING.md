# Building sm64cdpy from Source

> **Language / Idioma:** [English](https://github.com/retired64/sm64cdpy.releases/blob/main/BUILDING.md#english) · [Español](https://github.com/retired64/sm64cdpy.releases/blob/main/BUILDING.md#espa%C3%B1ol)

---

# English

## Table of Contents

- [Prerequisites](#prerequisites)
- [Required Versions](#required-versions)
- [Linux Environment Setup](#linux-environment-setup)
- [Cloning the Repository](#cloning-the-repository)
- [Setting Up the Environment](#setting-up-the-environment)
- [Building the APK](#building-the-apk)
- [Installing on a Device](#installing-on-a-device)
- [Useful Day-to-Day Commands](#useful-day-to-day-commands)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, make sure you have the following installed on your system:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- [Android SDK](https://developer.android.com/studio) (via Android Studio or command-line tools)
- [Java Development Kit 17](https://adoptium.net/) (OpenJDK Temurin 17 recommended)
- [Git](https://git-scm.com/)
- ADB (Android Debug Bridge) — included with the Android SDK

> [!IMPORTANT]
> This project was built and tested on **Flutter 3.41.6 (stable channel)** with **Dart 3.11.4**. Using an older version of Flutter or Dart will likely cause dependency resolution errors or build failures. Always check your version before proceeding.

---

## Required Versions

| Tool | Minimum Version | Tested On |
|---|---|---|
| Flutter | 3.41.6 (stable) | 3.41.6 |
| Dart SDK | ^3.11.0 | 3.11.4 |
| Android SDK | 36.1.0 | 36.1.0 |
| Build Tools | 36.1.0 | 36.1.0 |
| Android Platform | android-36 / android-36.1 | android-36.1 |
| NDK | 28.x (optional) | 28.2.13676358 |
| Java (JDK) | 17 | OpenJDK Temurin 17.0.10 |
| Target Android | 7.0+ (API 24+) | — |

> [!NOTE]
> The `pubspec.yaml` declares `sdk: ^3.11.0`, which means any Dart SDK version **3.11.0 or higher** (but below 4.0.0) is compatible. However, only **3.11.4** has been actively tested. If you experience unexpected behavior on a newer Dart version, please open an issue.

---

## Linux Environment Setup

This section documents the exact environment variables and `PATH` configuration used to develop and build this project on Linux. These paths are the reference baseline — your own paths may differ slightly depending on where you installed each tool.

### Android SDK structure

The project was built against the following Android SDK layout (located at `$HOME/Android/Sdk`):

```
Android/Sdk/
├── build-tools/    36.1.0        ← required
├── cmdline-tools/  latest
├── emulator/
├── ndk/            28.2.13676358  (optional, only needed for native code)
├── platform-tools/               ← contains adb, fastboot
├── platforms/      android-36.1  ← required
├── sources/        android-36.1
└── system-images/  android-36.1  (for emulator, optional)
```

> [!NOTE]
> Multiple SDK versions and NDKs are present in the development environment (`build-tools` 28.0.3 through 36.1.0, `platforms` android-30 through android-36.1, NDK 25–28). Flutter will automatically pick the correct build tools and platform. You do **not** need to install all of them — only `build-tools/36.1.0` and `platforms/android-36.1` are strictly required.

### Required environment variables

Add the following to your shell configuration file (`~/.bashrc`, `~/.zshrc`, or equivalent). These are the exact values used in the reference build environment:

```bash
# Flutter SDK — point to your Flutter installation directory
export PATH="$HOME/flutter/<version>/bin:$PATH"
# Example used in this project:
# export PATH="$HOME/flutter/3.41.6/bin:$PATH"

# Android SDK root
export ANDROID_HOME="$HOME/Android/Sdk"

# Android SDK tools — all three subdirectories are needed
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# Java — managed via SDKMAN in the reference environment
# SDKMAN sets JAVA_HOME automatically when you run: sdk use java 17.x.x-tem
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
```

> [!IMPORTANT]
> Flutter uses the `JAVA_HOME` environment variable to locate the JDK. If `flutter doctor` reports a JDK warning, verify that `JAVA_HOME` points to a **JDK 17** installation:
> ```bash
> echo $JAVA_HOME
> java -version
> # Expected: openjdk version "17.0.x" ...
> ```
> You can also tell Flutter explicitly which JDK to use:
> ```bash
> flutter config --jdk-dir="$HOME/.sdkman/candidates/java/current"
> ```

> [!TIP]
> The reference environment uses [SDKMAN](https://sdkman.io/) to manage Java versions. If you have multiple JDKs installed, SDKMAN lets you switch between them with:
> ```bash
> sdk list java               # See all available versions
> sdk use java 17.0.10-tem    # Switch to Temurin 17 for the current session
> sdk default java 17.0.10-tem  # Set Temurin 17 as the default permanently
> ```

### Verifying all paths are set correctly

After adding the variables above, reload your shell and run:

```bash
# Reload shell config (zsh example)
source ~/.zshrc

# Verify each tool is reachable
flutter --version         # Flutter 3.41.6, Dart 3.11.4
java -version             # openjdk 17.0.x
adb --version             # Android Debug Bridge version x.x.x
sdkmanager --version      # (optional) Android SDK Manager
```

> [!WARNING]
> If `flutter` is not found after reloading, make sure the Flutter `bin` directory is **before** other entries in your `PATH`. A common issue is that a system-wide Flutter package (e.g. from `snap` or `apt`) shadows your manually installed version. Check which binary is being used:
> ```bash
> which flutter
> # Should point to your manual install, e.g.:
> # /home/<user>/flutter/3.41.6/bin/flutter
> ```
> If it points to `/snap/bin/flutter` or `/usr/bin/flutter`, move the Flutter export to the **top** of your `PATH` in your shell config.

### Chrome executable (for web builds, optional)

If you plan to also run the web build or use Chrome-based DevTools:

```bash
export CHROME_EXECUTABLE=$(which google-chrome)
```

> [!NOTE]
> This is optional for Android-only builds. `flutter doctor` may warn about it if Chrome is not found, but it has no impact on APK compilation whatsoever.

### Full reference shell block (`~/.zshrc`)

This is the complete environment block used in the reference build machine, reproduced here for clarity. Copy and adapt it to your setup:

```bash
# Flutter SDK
export PATH="$HOME/flutter/3.41.6/bin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# Pub cache binaries (tools installed via flutter pub global activate)
export PATH="$PATH:$HOME/.pub-cache/bin"

# Chrome (optional, for web builds)
export CHROME_EXECUTABLE=$(which google-chrome)

# SDKMAN (Java version manager — must stay at the end of the file)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
```

> [!CAUTION]
> The SDKMAN initialization line **must** remain at the very end of your shell config file. Placing it earlier can cause `java` to resolve to the wrong version or not be found at all, which breaks Gradle and therefore the entire Android build pipeline.

---

## Cloning the Repository

```bash
git clone https://github.com/retired64/sm64cdpy.releases.git
cd sm64cdpy.releases
```

> [!TIP]
> If you only want the latest code without the full commit history (faster clone), you can use:
> ```bash
> git clone --depth 1 https://github.com/retired64/sm64cdpy.releases.git
> cd sm64cdpy.releases
> ```

---

## Setting Up the Environment

### 1. Verify your Flutter installation

```bash
flutter --version
```

Expected output (or newer):

```
Flutter 3.41.6 • channel stable • https://github.com/flutter/flutter.git
Framework • revision db50e20168
Engine    • revision 425cfb54d0
Dart      • version 3.11.4
DevTools  • version 2.54.2
```

> [!WARNING]
> If your Flutter version is **lower than 3.41.6**, update it before continuing:
> ```bash
> flutter upgrade
> ```
> Do **not** use a dev or beta channel build — this project targets stable only. To check which channel you are on:
> ```bash
> flutter channel
> # Must show: stable
> ```

### 2. Run Flutter doctor

```bash
flutter doctor -v
```

All Android-related checks must show `[✓]`. This is the expected healthy output:

```
[✓] Flutter (Channel stable, 3.41.6)
[✓] Android toolchain - develop for Android devices (Android SDK version 36.1.0)
[✓] Chrome - develop for the web
[✓] Linux toolchain - develop for Linux desktop
[✓] Connected device (N available)
[✓] Network resources
```

> [!IMPORTANT]
> If `flutter doctor` shows `[!] Android toolchain` with a license warning, run the following and accept **all** prompts by pressing `y`:
> ```bash
> flutter doctor --android-licenses
> ```
> You must accept all licenses before any build will succeed. This is a one-time step.

> [!NOTE]
> The `[!] Linux toolchain` warning about `eglinfo` (from `mesa-utils`) does **not** affect Android builds. It only matters if you build for Linux desktop targets. You can safely ignore it for this project.

### 3. Install dependencies

```bash
flutter pub get
```

This will download and link all packages declared in `pubspec.yaml`, including:

- `flutter_riverpod` + `riverpod_annotation` — state management
- `go_router` — declarative navigation
- `hive_flutter` — local key-value storage (favorites, settings)
- `cached_network_image` + `shimmer` — image loading with placeholders
- `http` — REST requests to the mod catalogue
- `file_picker`, `share_plus`, `path_provider` — file import/export (favorites JSON)
- `flutter_file_downloader` — direct mod downloads
- `google_fonts`, `flutter_svg`, `lucide_icons_flutter` — UI components
- `intl` — date formatting

> [!NOTE]
> `flutter pub get` will also resolve and lock all transitive dependencies into `pubspec.lock`. Do **not** delete `pubspec.lock` if you want a reproducible build. Committing it to version control ensures everyone builds against identical package versions.

> [!TIP]
> If you see a network error during `pub get`, verify your internet connection. You can also run with verbose output to see exactly which package is failing:
> ```bash
> flutter pub get --verbose
> ```

---

## Building the APK

### Option A — arm64-only APK (recommended for most devices)

```bash
flutter build apk --release --target-platform android-arm64
```

Output file:
```
build/app/outputs/flutter-apk/app-release.apk
```

> [!TIP]
> This is the best option if you are building for personal use or for a specific modern Android device. Almost all Android phones from 2017 onwards use arm64 (AArch64) architecture. The resulting APK is smaller than the universal build and behaviorally identical to the split APK for arm64.

---

### Option B — Split per ABI (recommended for GitHub Releases)

```bash
flutter build apk --release --split-per-abi
```

Output files:
```
build/app/outputs/flutter-apk/
├── app-arm64-v8a-release.apk    ← modern phones (2017+) — upload as primary asset
├── app-armeabi-v7a-release.apk  ← older 32-bit devices
└── app-x86_64-release.apk       ← emulators / x86 tablets
```

> [!TIP]
> This is the **recommended approach for publishing a GitHub Release**. Each APK contains only the native libraries for its target architecture, so it weighs roughly half as much as the universal APK. Upload all three as release assets — GitHub will list them and let users pick the right one for their device.

> [!NOTE]
> Not sure which ABI your device uses? Connect it via USB and run:
> ```bash
> adb shell getprop ro.product.cpu.abi
> ```
> The most common answer on modern Android phones is `arm64-v8a`. For the emulator (`android-36.1` system image), the answer is typically `x86_64`.

---

### Option C — Universal APK

```bash
flutter build apk --release
```

Output file:
```
build/app/outputs/flutter-apk/app-release.apk
```

> [!CAUTION]
> The universal APK bundles native libraries for **all** architectures in a single file, making it significantly larger (~2× the size of a split APK). Only use this option if you need a single file that works on any device and file size is not a concern.

---

### Build flags reference

| Flag | Effect |
|---|---|
| `--release` | Enables release optimizations (tree shaking, no debug info, Dart AOT) |
| `--target-platform android-arm64` | Builds only for arm64-v8a |
| `--split-per-abi` | Generates one APK per architecture |
| `--build-name=X.Y.Z` | Overrides the version name shown to users (e.g. `1.0.2`) |
| `--build-number=N` | Overrides the version code used internally by Android |
| `--obfuscate --split-debug-info=<dir>` | Enables code obfuscation; saves debug symbols to `<dir>` |
| `--verbose` | Prints the full build log — useful for diagnosing Gradle errors |

> [!TIP]
> To bump the version for a new release without editing `pubspec.yaml`:
> ```bash
> flutter build apk --release --split-per-abi \
>   --build-name=1.0.2 \
>   --build-number=3
> ```

---

## Installing on a Device

### Via ADB (USB)

First, enable USB Debugging on your Android device: **Settings → Developer Options → USB Debugging**.

Then connect via USB and confirm the authorization prompt on your phone.

```bash
# Verify your device is detected
adb devices
# Should show your device serial number with "device" status (not "unauthorized")

# Install the arm64 APK
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Force reinstall if the app is already installed (keeps existing data)
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Uninstall first, then clean install (all data will be erased)
adb uninstall com.sm64cdpy.app
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

> [!WARNING]
> If ADB shows `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, the installed version was signed with a different key (common when switching between a Play Store build and a locally-signed one). You must uninstall with `adb uninstall com.sm64cdpy.app` first, but note that **all locally stored data (favorites list, settings) will be permanently erased**.

> [!NOTE]
> If `adb devices` shows your device as `unauthorized`, unlock your phone screen and look for an **"Allow USB Debugging?"** dialog. Tap **Allow**. If the dialog never appears, try a different USB cable or port — data cables are required (charge-only cables do not carry ADB traffic).

### Via Flutter run (development only)

```bash
# Run directly on a connected device (debug mode — slower, has inspector overlay)
flutter run

# Run in release mode on a connected device (matches final APK behavior)
flutter run --release

# Target a specific device if multiple are connected
flutter run -d <device-id>    # get device IDs from: flutter devices
```

> [!NOTE]
> `flutter run` without `--release` runs in debug mode, which includes the Flutter inspector overlay and is significantly slower due to JIT compilation. Always verify final behavior with `flutter run --release` before distributing a build.

---

## Useful Day-to-Day Commands

```bash
# List all available devices and emulators
flutter devices

# Clean build artifacts and re-fetch packages
# (fixes the vast majority of weird post-pull build errors)
flutter clean && flutter pub get

# Analyze the codebase for lint and type errors
flutter analyze

# Run unit/widget tests
flutter test

# Check which packages have newer versions available
flutter pub outdated

# Upgrade packages to the latest compatible versions (respects pubspec.yaml constraints)
flutter pub upgrade

# Upgrade including breaking changes — read the changelog first!
flutter pub upgrade --major-versions

# Show the full dependency tree
flutter pub deps

# Start an Android emulator
flutter emulators --launch <emulator-id>
flutter emulators   # list available emulators
```

> [!TIP]
> If a build fails after pulling new changes, always run `flutter clean && flutter pub get` first before anything else. The vast majority of post-pull errors are caused by stale build artifacts or a `pubspec.lock` that is out of sync with the updated `pubspec.yaml`.

> [!TIP]
> The bundled mod database used by the app on first launch lives at:
> ```
> assets/db/database_sm64coopdx.json
> ```
> The in-app **Reload database** feature downloads a fresh copy from this repo's `db/` directory at runtime, without requiring a rebuild.

---

## Troubleshooting

### `flutter pub get` fails with dependency conflicts

Make sure your Dart SDK version satisfies `^3.11.0`:

```bash
dart --version
# Dart SDK version: 3.11.4 (stable)
```

If it reports a version below `3.11.0`, upgrade Flutter:

```bash
flutter upgrade
```

### Build fails with Gradle errors

Try cleaning the Gradle cache first:

```bash
cd android
./gradlew clean
cd ..
flutter build apk --release --target-platform android-arm64
```

If that still fails, run with verbose output to see the exact error:

```bash
flutter build apk --release --target-platform android-arm64 --verbose
```

> [!WARNING]
> If Gradle reports a JDK compatibility error, verify that `JAVA_HOME` points to **JDK 17** and not a newer version. JDK 21+ can cause compatibility issues with the Gradle version used by this project:
> ```bash
> java -version
> # Must show: openjdk version "17.0.x"
> echo $JAVA_HOME
> # Example: /home/<user>/.sdkman/candidates/java/17.0.10-tem
>
> # If JAVA_HOME is wrong, fix it via SDKMAN:
> sdk use java 17.0.10-tem
> # Or tell Flutter directly:
> flutter config --jdk-dir="$HOME/.sdkman/candidates/java/17.0.10-tem"
> ```

### `flutter` command not found after setting up the environment

Check which binary your shell resolves:

```bash
which flutter
which -a flutter   # shows ALL matches on PATH
```

Make sure `$HOME/flutter/<version>/bin` appears **before** any system-managed Flutter installs (snap, apt, flatpak):

```bash
# Add to the very top of your ~/.zshrc or ~/.bashrc
export PATH="$HOME/flutter/3.41.6/bin:$PATH"
source ~/.zshrc
```

> [!CAUTION]
> Do **not** mix a manually installed Flutter with one installed via `snap` or `apt`. Having both on `PATH` causes unpredictable version conflicts. If `which -a flutter` shows multiple paths, remove or disable every Flutter installation except your manual one.

### `adb: command not found`

The `platform-tools` directory is not in your `PATH`. Add it:

```bash
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
source ~/.zshrc

# Verify
adb --version
```

> [!NOTE]
> You can also call `adb` by its full path without modifying `PATH`, useful for a quick test:
> ```bash
> ~/Android/Sdk/platform-tools/adb devices
> ```

### `sdkmanager` or `avdmanager` not found

The `cmdline-tools/latest/bin` directory is not in your `PATH`:

```bash
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
source ~/.zshrc
sdkmanager --version
```

### App crashes immediately on launch

Run in debug mode to capture the full stack trace:

```bash
flutter run
```

Common causes and fixes:

- **Missing asset** — run `flutter clean && flutter pub get` and rebuild
- **Hive initialization error** — corrupted local database; uninstall the app on the device and reinstall
- **Network permission missing** — verify `android/app/src/main/AndroidManifest.xml` includes `<uses-permission android:name="android.permission.INTERNET" />`

> [!CAUTION]
> Never distribute a debug build (`flutter run` without `--release`, or `flutter build apk --debug`) as a release. Debug builds include full source maps, run 3–5× slower, expose internal stack traces to the user, and may reveal sensitive path information about the developer's machine.

### Build tools version mismatch

If Gradle complains about missing build tools, verify what versions are installed:

```bash
ls ~/Android/Sdk/build-tools/
# Should include: 36.1.0
```

If `36.1.0` is missing, install it:

```bash
sdkmanager "build-tools;36.1.0"
```

> [!NOTE]
> Having multiple build-tools versions installed side by side is harmless. The reference environment has `28.0.3`, `30.0.3`, `35.0.0`, `36.0.0`, and `36.1.0` all installed at the same time. Flutter always selects the version declared in `android/app/build.gradle`.

---

---

# Español

## Tabla de contenidos

- [Prerrequisitos](#prerrequisitos)
- [Versiones requeridas](#versiones-requeridas)
- [Configuración del entorno en Linux](#configuración-del-entorno-en-linux)
- [Clonar el repositorio](#clonar-el-repositorio)
- [Configurar el entorno](#configurar-el-entorno)
- [Compilar el APK](#compilar-el-apk)
- [Instalar en un dispositivo](#instalar-en-un-dispositivo)
- [Comandos útiles del día a día](#comandos-útiles-del-día-a-día)
- [Solución de problemas](#solución-de-problemas)

---

## Prerrequisitos

Antes de comenzar, asegúrate de tener instalado lo siguiente en tu sistema:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal stable)
- [Android SDK](https://developer.android.com/studio) (vía Android Studio o las herramientas de línea de comandos)
- [Java Development Kit 17](https://adoptium.net/) (se recomienda OpenJDK Temurin 17)
- [Git](https://git-scm.com/)
- ADB (Android Debug Bridge) — incluido con el Android SDK

> [!IMPORTANT]
> Este proyecto fue construido y probado con **Flutter 3.41.6 (canal stable)** y **Dart 3.11.4**. Usar una versión más antigua de Flutter o Dart probablemente causará errores de resolución de dependencias o fallos de compilación. Verifica tu versión antes de continuar.

---

## Versiones requeridas

| Herramienta | Versión mínima | Probada en |
|---|---|---|
| Flutter | 3.41.6 (stable) | 3.41.6 |
| Dart SDK | ^3.11.0 | 3.11.4 |
| Android SDK | 36.1.0 | 36.1.0 |
| Build Tools | 36.1.0 | 36.1.0 |
| Android Platform | android-36 / android-36.1 | android-36.1 |
| NDK | 28.x (opcional) | 28.2.13676358 |
| Java (JDK) | 17 | OpenJDK Temurin 17.0.10 |
| Android objetivo | 7.0+ (API 24+) | — |

> [!NOTE]
> El `pubspec.yaml` declara `sdk: ^3.11.0`, lo que significa que cualquier versión del Dart SDK **3.11.0 o superior** (pero menor a 4.0.0) es compatible. Sin embargo, solo **3.11.4** ha sido probada activamente. Si experimentas comportamiento inesperado con una versión más nueva de Dart, abre un issue.

---

## Configuración del entorno en Linux

Esta sección documenta las variables de entorno y la configuración de `PATH` exactas utilizadas para desarrollar y compilar este proyecto en Linux. Estos valores son la línea de base de referencia — tus propias rutas pueden diferir ligeramente dependiendo de dónde instalaste cada herramienta.

### Estructura del Android SDK

El proyecto fue compilado contra el siguiente layout del Android SDK (ubicado en `$HOME/Android/Sdk`):

```
Android/Sdk/
├── build-tools/    36.1.0        ← requerido
├── cmdline-tools/  latest
├── emulator/
├── ndk/            28.2.13676358  (opcional, solo necesario para código nativo)
├── platform-tools/               ← contiene adb, fastboot
├── platforms/      android-36.1  ← requerido
├── sources/        android-36.1
└── system-images/  android-36.1  (para el emulador, opcional)
```

> [!NOTE]
> En el entorno de desarrollo hay múltiples versiones del SDK y NDK instaladas (`build-tools` del 28.0.3 al 36.1.0, `platforms` del android-30 al android-36.1, NDK del 25 al 28). Flutter seleccionará automáticamente las build tools y plataforma correctas. **No necesitas instalarlas todas** — solo `build-tools/36.1.0` y `platforms/android-36.1` son estrictamente requeridos.

### Variables de entorno requeridas

Agrega lo siguiente a tu archivo de configuración del shell (`~/.bashrc`, `~/.zshrc` o equivalente). Estos son los valores exactos usados en el entorno de compilación de referencia:

```bash
# Flutter SDK — apunta al directorio de tu instalación de Flutter
export PATH="$HOME/flutter/<version>/bin:$PATH"
# Ejemplo usado en este proyecto:
# export PATH="$HOME/flutter/3.41.6/bin:$PATH"

# Raíz del Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"

# Herramientas del Android SDK — los tres subdirectorios son necesarios
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# Java — administrado con SDKMAN en el entorno de referencia
# SDKMAN establece JAVA_HOME automáticamente al ejecutar: sdk use java 17.x.x-tem
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
```

> [!IMPORTANT]
> Flutter usa la variable de entorno `JAVA_HOME` para localizar el JDK. Si `flutter doctor` reporta una advertencia del JDK, verifica que `JAVA_HOME` apunte a una instalación de **JDK 17**:
> ```bash
> echo $JAVA_HOME
> java -version
> # Esperado: openjdk version "17.0.x" ...
> ```
> También puedes indicarle a Flutter explícitamente qué JDK usar:
> ```bash
> flutter config --jdk-dir="$HOME/.sdkman/candidates/java/current"
> ```

> [!TIP]
> El entorno de referencia usa [SDKMAN](https://sdkman.io/) para administrar las versiones de Java. Si tienes múltiples JDKs instalados, SDKMAN te permite cambiar entre ellos con:
> ```bash
> sdk list java               # Ver todas las versiones disponibles
> sdk use java 17.0.10-tem    # Cambiar a Temurin 17 para la sesión actual
> sdk default java 17.0.10-tem  # Establecer Temurin 17 como predeterminado permanente
> ```

### Verificar que todos los paths están configurados correctamente

Después de agregar las variables, recarga tu shell y ejecuta:

```bash
# Recargar la configuración del shell (ejemplo en zsh)
source ~/.zshrc

# Verificar que cada herramienta es accesible
flutter --version         # Flutter 3.41.6, Dart 3.11.4
java -version             # openjdk 17.0.x
adb --version             # Android Debug Bridge version x.x.x
sdkmanager --version      # (opcional) Android SDK Manager
```

> [!WARNING]
> Si `flutter` no se encuentra después de recargar el shell, asegúrate de que el directorio `bin` de Flutter esté **antes** que otras entradas en tu `PATH`. Un problema común es que un paquete de Flutter instalado por el sistema (ej. desde `snap` o `apt`) oculta tu versión instalada manualmente. Verifica qué binario se está usando:
> ```bash
> which flutter
> # Debe apuntar a tu instalación manual, ej.:
> # /home/<usuario>/flutter/3.41.6/bin/flutter
> ```
> Si apunta a `/snap/bin/flutter` o `/usr/bin/flutter`, mueve el `export` de Flutter al **principio** de tu `PATH` en la configuración del shell.

### Ejecutable de Chrome (para builds web, opcional)

Si planeas también compilar para web o usar las herramientas DevTools basadas en Chrome:

```bash
export CHROME_EXECUTABLE=$(which google-chrome)
```

> [!NOTE]
> Esto es opcional para builds solo de Android. `flutter doctor` puede advertir sobre esto si Chrome no se encuentra, pero no tiene ningún impacto en la compilación de APK.

### Bloque completo de referencia para `~/.zshrc`

Este es el bloque de entorno completo usado en la máquina de compilación de referencia. Cópialo y adáptalo a tu setup:

```bash
# Flutter SDK
export PATH="$HOME/flutter/3.41.6/bin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# Binarios de pub cache (herramientas instaladas con flutter pub global activate)
export PATH="$PATH:$HOME/.pub-cache/bin"

# Chrome (opcional, para builds web)
export CHROME_EXECUTABLE=$(which google-chrome)

# SDKMAN (administrador de versiones de Java — debe ir al final del archivo)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
```

> [!CAUTION]
> La línea de inicialización de SDKMAN **debe** permanecer al final de tu archivo de configuración del shell. Colocarla antes puede hacer que `java` resuelva a la versión incorrecta o que no se encuentre en absoluto, lo que rompe Gradle y por lo tanto toda la cadena de compilación de Android.

---

## Clonar el repositorio

```bash
git clone https://github.com/retired64/sm64cdpy.releases.git
cd sm64cdpy.releases
```

> [!TIP]
> Si solo quieres el código más reciente sin el historial completo de commits (clon más rápido), puedes usar:
> ```bash
> git clone --depth 1 https://github.com/retired64/sm64cdpy.releases.git
> cd sm64cdpy.releases
> ```

---

## Configurar el entorno

### 1. Verificar tu instalación de Flutter

```bash
flutter --version
```

Salida esperada (o más nueva):

```
Flutter 3.41.6 • channel stable • https://github.com/flutter/flutter.git
Framework • revision db50e20168
Engine    • revision 425cfb54d0
Dart      • version 3.11.4
DevTools  • version 2.54.2
```

> [!WARNING]
> Si tu versión de Flutter es **menor a 3.41.6**, actualízala antes de continuar:
> ```bash
> flutter upgrade
> ```
> **No** uses un build del canal dev o beta — este proyecto apunta únicamente al canal stable. Para verificar en qué canal estás:
> ```bash
> flutter channel
> # Debe mostrar: stable
> ```

### 2. Ejecutar Flutter doctor

```bash
flutter doctor -v
```

Todas las verificaciones de Android deben mostrar `[✓]`. Esta es la salida esperada en un entorno sano:

```
[✓] Flutter (Channel stable, 3.41.6)
[✓] Android toolchain - develop for Android devices (Android SDK version 36.1.0)
[✓] Chrome - develop for the web
[✓] Linux toolchain - develop for Linux desktop
[✓] Connected device (N available)
[✓] Network resources
```

> [!IMPORTANT]
> Si `flutter doctor` muestra `[!] Android toolchain` con una advertencia de licencias, ejecuta el siguiente comando y acepta **todos** los prompts presionando `y`:
> ```bash
> flutter doctor --android-licenses
> ```
> Debes aceptar todas las licencias antes de que cualquier build pueda completarse. Este paso solo se hace una vez.

> [!NOTE]
> La advertencia `[!] Linux toolchain` sobre `eglinfo` (del paquete `mesa-utils`) **no afecta** los builds de Android. Solo importa si compilas para Linux desktop. Puedes ignorarla con seguridad para este proyecto.

### 3. Instalar dependencias

```bash
flutter pub get
```

Esto descargará y enlazará todos los paquetes declarados en `pubspec.yaml`, incluyendo:

- `flutter_riverpod` + `riverpod_annotation` — gestión de estado
- `go_router` — navegación declarativa
- `hive_flutter` — almacenamiento local clave-valor (favoritos, ajustes)
- `cached_network_image` + `shimmer` — carga de imágenes con placeholders
- `http` — peticiones REST al catálogo de mods
- `file_picker`, `share_plus`, `path_provider` — importar/exportar favoritos en JSON
- `flutter_file_downloader` — descargas directas de mods
- `google_fonts`, `flutter_svg`, `lucide_icons_flutter` — componentes de UI
- `intl` — formato de fechas

> [!NOTE]
> `flutter pub get` también resolverá y bloqueará todas las dependencias transitivas en `pubspec.lock`. **No elimines `pubspec.lock`** si quieres un build reproducible. Hacer commit de este archivo garantiza que todos compilen con versiones idénticas de paquetes.

> [!TIP]
> Si ves un error de red durante `pub get`, verifica tu conexión a internet. También puedes ejecutar con salida verbose para ver exactamente qué paquete está fallando:
> ```bash
> flutter pub get --verbose
> ```

---

## Compilar el APK

### Opción A — APK solo arm64 (recomendado para la mayoría de dispositivos)

```bash
flutter build apk --release --target-platform android-arm64
```

Archivo de salida:
```
build/app/outputs/flutter-apk/app-release.apk
```

> [!TIP]
> Esta es la mejor opción si estás compilando para uso personal o para un dispositivo Android moderno específico. Casi todos los teléfonos Android desde 2017 en adelante usan arquitectura arm64 (AArch64). El APK resultante es más pequeño que el universal y comportalmente idéntico al APK split para arm64.

---

### Opción B — Split per ABI (recomendado para GitHub Releases)

```bash
flutter build apk --release --split-per-abi
```

Archivos de salida:
```
build/app/outputs/flutter-apk/
├── app-arm64-v8a-release.apk    ← teléfonos modernos (2017+) — sube este como principal
├── app-armeabi-v7a-release.apk  ← dispositivos 32-bit más viejos
└── app-x86_64-release.apk       ← emuladores / tablets x86
```

> [!TIP]
> Este es el **enfoque recomendado para publicar un GitHub Release**. Cada APK contiene solo las librerías nativas para su arquitectura objetivo, por lo que pesa aproximadamente la mitad que el APK universal. Sube los tres como assets del release — GitHub los listará y los usuarios podrán elegir el correcto para su dispositivo.

> [!NOTE]
> ¿No sabes qué ABI usa tu dispositivo? Conéctalo por USB y ejecuta:
> ```bash
> adb shell getprop ro.product.cpu.abi
> ```
> La respuesta más común en teléfonos Android modernos es `arm64-v8a`. Para el emulador (`android-36.1`), típicamente es `x86_64`.

---

### Opción C — APK universal

```bash
flutter build apk --release
```

Archivo de salida:
```
build/app/outputs/flutter-apk/app-release.apk
```

> [!CAUTION]
> El APK universal incluye las librerías nativas de **todas** las arquitecturas en un solo archivo, lo que lo hace significativamente más pesado (~2× el tamaño de un APK split). Usa esta opción solo si necesitas un archivo único que funcione en cualquier dispositivo y el tamaño del archivo no es una preocupación.

---

### Referencia de flags de compilación

| Flag | Efecto |
|---|---|
| `--release` | Activa las optimizaciones de release (tree shaking, sin info de debug, Dart AOT) |
| `--target-platform android-arm64` | Compila solo para arm64-v8a |
| `--split-per-abi` | Genera un APK por arquitectura |
| `--build-name=X.Y.Z` | Sobreescribe el nombre de versión visible para el usuario (ej. `1.0.2`) |
| `--build-number=N` | Sobreescribe el version code usado internamente por Android |
| `--obfuscate --split-debug-info=<dir>` | Activa obfuscación y guarda los símbolos de debug en `<dir>` |
| `--verbose` | Imprime el log completo del build — útil para diagnosticar errores de Gradle |

> [!TIP]
> Para subir la versión en un nuevo release sin editar `pubspec.yaml`:
> ```bash
> flutter build apk --release --split-per-abi \
>   --build-name=1.0.2 \
>   --build-number=3
> ```

---

## Instalar en un dispositivo

### Por ADB (USB)

Primero, habilita la Depuración USB en tu dispositivo Android: **Ajustes → Opciones de desarrollador → Depuración USB**.

Luego conéctalo por USB y confirma el prompt de autorización en tu teléfono.

```bash
# Verificar que tu dispositivo es detectado
adb devices
# Debe mostrar el número de serie con estado "device" (no "unauthorized")

# Instalar el APK arm64
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Forzar reinstalación si la app ya está instalada (conserva los datos)
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Desinstalar primero y luego instalar limpio (los datos se borrarán)
adb uninstall com.sm64cdpy.app
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

> [!WARNING]
> Si ADB muestra `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, la versión instalada fue firmada con una clave diferente (común al cambiar entre un build de Play Store y uno firmado localmente). Debes desinstalar primero con `adb uninstall com.sm64cdpy.app`, pero ten en cuenta que **todos los datos guardados localmente (lista de favoritos, ajustes) se borrarán permanentemente**.

> [!NOTE]
> Si `adb devices` muestra tu dispositivo como `unauthorized`, desbloquea la pantalla del teléfono y busca el diálogo **"¿Permitir depuración USB?"**. Toca **Permitir**. Si el diálogo nunca aparece, prueba con un cable USB diferente o un puerto diferente — los cables de solo carga no transmiten tráfico ADB.

### Por Flutter run (solo para desarrollo)

```bash
# Correr directamente en un dispositivo conectado (modo debug — más lento, tiene overlay)
flutter run

# Correr en modo release en un dispositivo conectado (idéntico al APK final)
flutter run --release

# Apuntar a un dispositivo específico si hay varios conectados
flutter run -d <device-id>    # obtén los IDs con: flutter devices
```

> [!NOTE]
> `flutter run` sin `--release` corre en modo debug, que incluye el inspector de Flutter y es significativamente más lento por la compilación JIT. Siempre verifica el comportamiento final con `flutter run --release` antes de distribuir un build.

---

## Comandos útiles del día a día

```bash
# Listar todos los dispositivos y emuladores disponibles
flutter devices

# Limpiar artefactos de build y volver a descargar paquetes
# (arregla la gran mayoría de errores raros después de hacer pull)
flutter clean && flutter pub get

# Analizar el código en busca de errores de lint y de tipos
flutter analyze

# Correr los tests unitarios/de widget
flutter test

# Verificar qué paquetes tienen versiones más nuevas disponibles
flutter pub outdated

# Actualizar paquetes a las últimas versiones compatibles (respeta los constraints del pubspec.yaml)
flutter pub upgrade

# Actualizar incluyendo cambios que rompen compatibilidad — ¡lee el changelog primero!
flutter pub upgrade --major-versions

# Mostrar el árbol de dependencias completo
flutter pub deps

# Iniciar un emulador Android
flutter emulators --launch <emulator-id>
flutter emulators   # listar emuladores disponibles
```

> [!TIP]
> Si una compilación falla después de hacer pull de cambios nuevos, ejecuta siempre `flutter clean && flutter pub get` primero antes de cualquier otra cosa. La gran mayoría de errores post-pull son causados por artefactos de build obsoletos o un `pubspec.lock` desincronizado con el `pubspec.yaml` actualizado.

> [!TIP]
> La base de datos de mods incluida en la app para el primer arranque se encuentra en:
> ```
> assets/db/database_sm64coopdx.json
> ```
> La función **Reload database** dentro de la app descarga una copia actualizada desde el directorio `db/` de este repositorio en tiempo de ejecución, sin necesidad de recompilar.

---

## Solución de problemas

### `flutter pub get` falla con conflictos de dependencias

Asegúrate de que tu versión del Dart SDK satisface `^3.11.0`:

```bash
dart --version
# Dart SDK version: 3.11.4 (stable)
```

Si reporta una versión por debajo de `3.11.0`, actualiza Flutter:

```bash
flutter upgrade
```

### El build falla con errores de Gradle

Prueba limpiar la caché de Gradle primero:

```bash
cd android
./gradlew clean
cd ..
flutter build apk --release --target-platform android-arm64
```

Si sigue fallando, ejecuta con salida verbose para ver el error exacto:

```bash
flutter build apk --release --target-platform android-arm64 --verbose
```

> [!WARNING]
> Si Gradle reporta un error de compatibilidad con el JDK, verifica que `JAVA_HOME` apunte al **JDK 17** y no a una versión más nueva. JDK 21+ puede causar problemas de compatibilidad con la versión de Gradle usada por este proyecto:
> ```bash
> java -version
> # Debe mostrar: openjdk version "17.0.x"
> echo $JAVA_HOME
> # Ejemplo: /home/<usuario>/.sdkman/candidates/java/17.0.10-tem
>
> # Si JAVA_HOME está mal, corrígelo con SDKMAN:
> sdk use java 17.0.10-tem
> # O indícaselo directamente a Flutter:
> flutter config --jdk-dir="$HOME/.sdkman/candidates/java/17.0.10-tem"
> ```

### El comando `flutter` no se encuentra después de configurar el entorno

Verifica qué binario resuelve tu shell:

```bash
which flutter
which -a flutter   # muestra TODAS las coincidencias en el PATH
```

Asegúrate de que `$HOME/flutter/<version>/bin` aparece **antes** de cualquier instalación de Flutter administrada por el sistema:

```bash
# Agrega al principio de tu ~/.zshrc o ~/.bashrc
export PATH="$HOME/flutter/3.41.6/bin:$PATH"
source ~/.zshrc
```

> [!CAUTION]
> **No** mezcles un Flutter instalado manualmente con uno instalado via `snap` o `apt`. Tener ambos en el `PATH` causa conflictos de versión impredecibles. Si `which -a flutter` muestra múltiples rutas, elimina o deshabilita cada instalación de Flutter excepto la tuya manual.

### `adb: command not found`

El directorio `platform-tools` no está en tu `PATH`. Agrégalo:

```bash
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
source ~/.zshrc

# Verificar
adb --version
```

> [!NOTE]
> También puedes llamar a `adb` por su ruta completa sin modificar el `PATH`, útil para una prueba rápida:
> ```bash
> ~/Android/Sdk/platform-tools/adb devices
> ```

### `sdkmanager` o `avdmanager` no se encuentran

El directorio `cmdline-tools/latest/bin` no está en tu `PATH`:

```bash
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
source ~/.zshrc
sdkmanager --version
```

### La app crashea inmediatamente al abrirse

Corre en modo debug para capturar el stack trace completo:

```bash
flutter run
```

Causas comunes y sus soluciones:

- **Asset faltante** — ejecuta `flutter clean && flutter pub get` y vuelve a compilar
- **Error de inicialización de Hive** — base de datos local corrompida; desinstala la app del dispositivo y vuelve a instalarla
- **Permiso de red faltante** — verifica que `android/app/src/main/AndroidManifest.xml` incluye `<uses-permission android:name="android.permission.INTERNET" />`

> [!CAUTION]
> Nunca distribuyas un build de debug (`flutter run` sin `--release`, o `flutter build apk --debug`) como si fuera un release. Los builds de debug incluyen source maps completos, son 3–5× más lentos en tiempo de ejecución, exponen stack traces internos al usuario y pueden revelar información sensible sobre las rutas del equipo del desarrollador.

### Error de versión incompatible de build tools

Si Gradle se queja de las build tools, verifica las versiones instaladas:

```bash
ls ~/Android/Sdk/build-tools/
# Debe incluir: 36.1.0
```

Si `36.1.0` no está presente, instálalo:

```bash
sdkmanager "build-tools;36.1.0"
```

> [!NOTE]
> Tener múltiples versiones de build-tools instaladas en paralelo es completamente inofensivo. El entorno de referencia tiene `28.0.3`, `30.0.3`, `35.0.0`, `36.0.0` y `36.1.0` instalados al mismo tiempo. Flutter siempre selecciona la versión declarada en `android/app/build.gradle`.

---

*Made with ❤️ for the SM64 Coop Deluxe community · Not affiliated with the SM64CoopDX team*