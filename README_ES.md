# SM64CDPY — Navegador de mods para SM64CoopDX

[English](README.md) · **Español** · [Português do Brasil](README_PT.md)

SM64CDPY es un navegador y gestor de mods no oficial, orientado a Android, para
**SM64CoopDX**. Reúne el descubrimiento, descarga e instalación de contenido,
la integración con el juego y la actualización del catálogo en una interfaz
móvil.

El proyecto está retomando mantenimiento. Su versión declarada es **1.7.0+18**.
La burbuja flotante de la línea 1.7 está implementada, pero sigue siendo
experimental hasta completar pruebas en dispositivos Android reales.

![SM64CDPY para Android mostrando las pantallas de inicio, catálogo y detalle de un mod](assets/sm64cdpy-readme-banner.webp)

## Para qué sirve y cuál es su potencial

La aplicación busca ser un compañero móvil completo para SM64CoopDX, no solo
una lista de mods. Puede unir el proceso de encontrar contenido, descargarlo y
colocarlo en una carpeta accesible para el juego, mostrando el progreso de
descarga e instalación.

- Catálogo comunitario con búsqueda, categorías, filtros y favoritos.
- Gestor de descargas en segundo plano con progreso, cancelación y
  notificaciones.
- Instalador de ZIP, 7z y archivos sueltos mediante Storage Access Framework.
- Burbuja flotante accesible mientras el juego está abierto.
- Actualización de catálogos y de APK por arquitectura del dispositivo.
- Base para mejorar la instalación automática, recuperación tras cierres de
  Android y una experiencia más directa dentro del juego.

## Funciones actuales

- Catálogo principal, contenido popular y destacado.
- Secciones VIP, DynOS, controles táctiles, OMM Rebirth y Render96.
- Importación y exportación de favoritos en JSON.
- Interfaz en inglés, español y portugués brasileño; temas claro y oscuro.
- Actualización manual de bases JSON remotas.
- Selección persistente de carpetas con el selector de Android.
- Resolución de enlaces, incluidos assets de GitHub Releases.
- Descarga e instalación mediante WorkManager con progreso y cancelación.
- Copia de archivos sueltos y extracción de ZIP/7z.
- Lanzamiento de SM64CoopDX y actualización OTA de la aplicación.

## Burbuja flotante

El overlay utiliza un segundo engine de Flutter sobre el juego. Permite buscar,
solicitar o cancelar descargas y recibir el progreso reenviado por el engine
principal. Como ambos engines no comparten memoria y Android puede recrear el
proceso, todavía requiere pruebas de concurrencia, permisos y recuperación en
Android 7–16.

## Estado actual

- Catálogo, descargas, instalación y actualización OTA: implementados.
- Overlay: implementado, en estabilización y pruebas.
- Plataforma soportada: Android 7.0 o superior (`minSdk 24`).
- Pruebas automatizadas: todavía no hay suites `test/` o `integration_test/`.

Consulta [Estado y próximos pasos](docs/PROJECT_STATUS.md).

## Compilación rápida

Requiere Flutter **3.41.7**, Dart **3.11.x**, Java 17 y Android SDK.

```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter build apk --release --target-platform android-arm64 --split-per-abi
```

La guía completa está en [BUILDING.md](BUILDING.md) y el índice técnico en
[docs/README.md](docs/README.md).

## Repositorios locales de referencia

Komi Store, Floating Apps y otros repositorios clonados son ejemplos locales
para investigación. Están excluidos mediante `.gitignore`, no forman parte de
la aplicación y no deben subirse a GitHub ni entrar en el análisis o build del
proyecto. Solo están representados en el
[archivo documental](docs/archive/README.md).

## Privacidad y aviso

La app no tiene cuentas, publicidad ni telemetría. Usa Internet para catálogos,
descargas, actualizaciones y recursos externos; favoritos y preferencias se
guardan localmente.

Es un proyecto personal no oficial, sin afiliación con SM64CoopDX, Nintendo o
los autores de mods. El contenido pertenece a sus respectivos creadores.

[Releases](https://github.com/retired64/sm64cdpy.releases/releases) ·
[Discord](https://discord.com/invite/thuhUH2WNX)
