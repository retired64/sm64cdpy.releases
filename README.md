# SM64CoopDX Mods Browser

> A personal Android app to browse, search, and manage mods for **SM64 Coop Deluxe** — unofficial, made with ❤️ for the community.

> Una app personal para Android que te permite explorar, buscar y gestionar mods de **SM64 Coop Deluxe** — no oficial, hecha con ❤️ para la comunidad.

![Platform](https://img.shields.io/badge/Platform-Android-green)
![Flutter](https://img.shields.io/badge/Flutter-3.41.6-blue)
![License](https://img.shields.io/badge/License-Personal-lightgrey)
![Min SDK](https://img.shields.io/badge/Min%20Android-7.0-orange)

---

## Quick start

```bash
# 1. Clone the repository
git clone --depth 1 https://github.com/retired64/sm64cdpy.releases.git
cd sm64cdpy.releases

# 2. Install dependencies
flutter pub get

# 3. Build (arm64 — recommended for most devices)
flutter build apk --release --target-platform android-arm64

# Output: build/app/outputs/flutter-apk/app-release.apk
```

## 📥 Download / Descarga

Go to the [**Releases**](https://github.com/retired64/sm64cdpy.releases/releases) section and download the latest `.apk` file.

Ve a la sección de [**Releases**](https://github.com/retired64/sm64cdpy.releases/releases) y descarga el archivo `.apk` más reciente.

> **Android only.** Minimum Android 7.0 (Marshmallow) / Solo Android. Mínimo Android 7.0.

---

## 🇺🇸 English

### What is this?

This is a personal app I built so I could browse and organize mods for SM64 Coop Deluxe straight from my phone, without having to open a browser every time. It reads the public mod catalogue from mods sm64coopdx  and presents it in a clean, fast mobile interface.

It's not official. It's not affiliated with the SM64CoopDX team or any mod creator. It's just a passion project.

### What can you do with it?

- **Browse the full catalogue** — every mod listed on the official site, all in one place.
- **Search instantly** — find any mod by name, author, or tag as you type.
- **Filter by category** — Characters, Game Modes, ROM Hacks, Visuals, Audio, Utilities, and more.
- **Sort mods** — by rating, downloads, or most recently updated.
- **See what's popular** — a dedicated screen with the most downloaded mods sorted from highest to lowest.
- **Save favourites** — tap the heart on any mod to save it. Your list stays saved even if you close the app.
- **Export & import favourites** — save your favourites list as a `.json` file and restore it anytime, even after reinstalling or switching devices.
- **Mod detail screen** — full description, screenshots, tags, stats, update history, and direct download links.
- **Update the database** — tap *Reload database* in Settings to pull the latest mod list directly from this GitHub repo. No need to reinstall the app.
- **Light & Dark theme** — choose your preferred look or let it follow your system.
- **Bilingual** — the app interface includes a bilingual Disclaimer screen (English / Spanish).

### How to install

1. Download the `.apk` from the [Releases](https://github.com/retired64/sm64cdpy.releases/releases) page.
2. On your Android phone, open the file. If it asks for permission to install from unknown sources, allow it — this is normal for apps not downloaded from the Play Store.
3. Install and open. That's it.

### How to update the mod list

The app ships with a local snapshot of the database. When new mods get added to the official site, you can refresh your list without reinstalling:

1. Open the app → tap the **menu icon** (top left) → **Settings**.
2. Tap **Reload database**.
3. The app downloads the latest list from this repo and updates everything automatically.

### Is this safe?

Yes. The app does not collect any data, does not require an account, does not display ads, and does not communicate with any server other than this GitHub repo (only when you manually tap Reload). Your favourites are stored locally on your device.

---

## Español

### ¿Qué es esto?

Es una app personal que hice para poder explorar y organizar los mods de SM64 Coop Deluxe desde mi celular, sin tener que abrir el navegador cada vez. Lee el catálogo público de mods sm64coopdx y lo presenta en una interfaz móvil limpia y rápida.

No es oficial. No tiene ninguna relación con el equipo de SM64CoopDX ni con los creadores de mods. Es solo un proyecto personal.

### ¿Qué puedes hacer con ella?

- **Explorar el catálogo completo** — todos los mods del sitio oficial, en un solo lugar.
- **Buscar al instante** — encuentra cualquier mod por nombre, autor o etiqueta mientras escribes.
- **Filtrar por categoría** — Personajes, Modos de Juego, ROM Hacks, Visuales, Audio, Utilidades, y más.
- **Ordenar mods** — por calificación, descargas o los actualizados más recientemente.
- **Ver lo más popular** — una pantalla dedicada con los mods más descargados, del mayor al menor.
- **Guardar favoritos** — toca el corazón en cualquier mod para guardarlo. Tu lista se conserva aunque cierres la app.
- **Exportar e importar favoritos** — guarda tu lista como archivo `.json` y restáurala cuando quieras, incluso después de reinstalar o cambiar de dispositivo.
- **Pantalla de detalle del mod** — descripción completa, capturas, etiquetas, estadísticas, historial de actualizaciones y enlaces de descarga directa.
- **Actualizar la base de datos** — toca *Reload database* en Ajustes para descargar la lista de mods más reciente directamente desde este repositorio. Sin necesidad de reinstalar.
- **Tema claro y oscuro** — elige cómo se ve la app o deja que siga la configuración de tu sistema.
- **Bilingüe** — la pantalla de Aviso Legal está disponible en inglés y español con un botón de traducción.

## Inicio Rapido

```bash
# 1. Clonar el repositorio
git clone --depth 1 https://github.com/retired64/sm64cdpy.releases.git
cd sm64cdpy.releases

# 2. Instalar dependencias
flutter pub get

# 3. Compilar (arm64 — recomendado para la mayoría de dispositivos)
flutter build apk --release --target-platform android-arm64

# Salida: build/app/outputs/flutter-apk/app-release.apk
```

### Cómo instalar

1. Descarga el `.apk` desde la página de [Releases](https://github.com/retired64/sm64cdpy.releases/releases).
2. En tu teléfono Android, abre el archivo. Si te pide permiso para instalar desde fuentes desconocidas, acéptalo — esto es normal para apps que no vienen de la Play Store.
3. Instala y abre. Eso es todo.

### Cómo actualizar la lista de mods

La app viene con una copia local de la base de datos. Cuando se agregan mods nuevos al sitio oficial, puedes actualizar tu lista sin reinstalar:

1. Abre la app → toca el **ícono de menú** (arriba a la izquierda) → **Settings**.
2. Toca **Reload database**.
3. La app descarga la lista más reciente desde este repositorio y actualiza todo automáticamente.

### ¿Es segura?

Sí. La app no recopila ningún dato, no requiere cuenta, no muestra publicidad y no se comunica con ningún servidor fuera de este repositorio de GitHub (y solo cuando tú tocas Reload manualmente). Tus favoritos se guardan localmente en tu dispositivo.

---

## ⚠️ Disclaimer / Aviso Legal

This app is an **unofficial personal project**. It is not associated with, endorsed by, or approved by the developers of SM64CoopDX, Super Mario 64, Nintendo, or any mod creator. All mod names, images, and content displayed belong to their respective authors.

Esta app es un **proyecto personal no oficial**. No está asociada, respaldada ni aprobada por los desarrolladores de SM64CoopDX, Super Mario 64, Nintendo, ni por ningún creador de mods. Los nombres, imágenes y contenido mostrado pertenecen a sus respectivos autores.

---

## 📬 Contact / Contacto

Found a bug or have a suggestion? Reach me on Discord.

¿Encontraste un error o tienes una sugerencia? Escríbeme por Discord.

[![Discord](https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.com/invite/thuhUH2WNX)

---

<div align="center">
  <sub>Made with ❤️ for personal use · No official affiliation · <a href="https://github.com/retired64/sm64cdpy.releases/releases">Download latest APK</a></sub>
</div>

