# SM64CoopDX Mods Browser

**English** · [Español](README_ES.md) · [Português](README_PT.md)

> A personal Android app to browse, search, and manage mods for **SM64 Coop Deluxe** — unofficial, made with ❤️ for the community.

![App sm64cdpy android](assets/app.webp)

<div align="center">

| Home | Home (Light) | Popular | Popular (Light) | Menu |
|:---:|:---:|:---:|:---:|:---:|
| <img src="ss/inicio.webp" width="150"> | <img src="ss/inicio-modoClaro.webp" width="150"> | <img src="ss/popular.webp" width="150"> | <img src="ss/popular-modoClaro.webp" width="150"> | <img src="ss/menu.webp" width="150"> |

| Mod Details | Mod Details (Light) | Mod Details (Light 2) | Settings | Settings (Light) |
|:---:|:---:|:---:|:---:|:---:|
| <img src="ss/mod-detalles.webp" width="150"> | <img src="ss/mod-detalles-modoClaro.webp" width="150"> | <img src="ss/mod-detalles-modoClaro2.webp" width="150"> | <img src="ss/ajustes.webp" width="150"> | <img src="ss/ajustes-modoClaro.webp" width="150"> |

</div>

![Platform](https://img.shields.io/badge/Platform-Android-green)
![Flutter](https://img.shields.io/badge/Flutter-3.41.6-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)
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

## 📥 Download

Go to the [**Releases**](https://github.com/retired64/sm64cdpy.releases/releases) section and download the latest `.apk` file.

> **Android only.** Minimum Android 7.0 (Marshmallow).

---

## What is this?

This is a personal app I built so I could browse and organize mods for SM64 Coop Deluxe straight from my phone, without having to open a browser every time. It reads the public mod catalogue from mods sm64coopdx  and presents it in a clean, fast mobile interface.

It's not official. It's not affiliated with the SM64CoopDX team or any mod creator. It's just a passion project.

## What can you do with it?

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

## How to install

1. Download the `.apk` from the [Releases](https://github.com/retired64/sm64cdpy.releases/releases) page.
2. On your Android phone, open the file. If it asks for permission to install from unknown sources, allow it — this is normal for apps not downloaded from the Play Store.
3. Install and open. That's it.

## How to update the mod list

The app ships with a local snapshot of the database. When new mods get added to the official site, you can refresh your list without reinstalling:

1. Open the app → tap the **menu icon** (top left) → **Settings**.
2. Tap **Reload database**.
3. The app downloads the latest list from this repo and updates everything automatically.

## Is this safe?

Yes. The app does not collect any data, does not require an account, does not display ads, and does not communicate with any server other than this GitHub repo (only when you manually tap Reload). Your favourites are stored locally on your device.

---

## ⚠️ Disclaimer

This app is an **unofficial personal project**. It is not associated with, endorsed by, or approved by the developers of SM64CoopDX, Super Mario 64, Nintendo, or any mod creator. All mod names, images, and content displayed belong to their respective authors.

---

## 📬 Contact

Found a bug or have a suggestion? Reach me on Discord.

[![Discord](https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.com/invite/thuhUH2WNX)

---

<div align="center">
  <sub>Made with ❤️ for personal use · No official affiliation · <a href="https://github.com/retired64/sm64cdpy.releases/releases">Download latest APK</a></sub>
</div>
