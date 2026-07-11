# SM64CoopDX Mods Browser

[English](README.md) · **Español** · [Português](README_PT.md)

> Una app personal para Android que te permite explorar, buscar y gestionar mods de **SM64 Coop Deluxe** — no oficial, hecha con ❤️ para la comunidad.

![App sm64cdpy android](assets/app.webp)

<div align="center">

| Inicio | Inicio (Claro) | Popular | Popular (Claro) | Menú |
|:---:|:---:|:---:|:---:|:---:|
| <img src="ss/inicio.webp" width="150"> | <img src="ss/inicio-modoClaro.webp" width="150"> | <img src="ss/popular.webp" width="150"> | <img src="ss/popular-modoClaro.webp" width="150"> | <img src="ss/menu.webp" width="150"> |

| Mod. Detalles | Mod. Detalles (Claro) | Mod. Detalles (Claro 2) | Ajustes | Ajustes (Claro) |
|:---:|:---:|:---:|:---:|:---:|
| <img src="ss/mod-detalles.webp" width="150"> | <img src="ss/mod-detalles-modoClaro.webp" width="150"> | <img src="ss/mod-detalles-modoClaro2.webp" width="150"> | <img src="ss/ajustes.webp" width="150"> | <img src="ss/ajustes-modoClaro.webp" width="150"> |

</div>

![Platform](https://img.shields.io/badge/Platform-Android-green)
![Flutter](https://img.shields.io/badge/Flutter-3.41.6-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Min SDK](https://img.shields.io/badge/Min%20Android-7.0-orange)

---

## Inicio rápido

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

## 📥 Descarga

Ve a la sección de [**Releases**](https://github.com/retired64/sm64cdpy.releases/releases) y descarga el archivo `.apk` más reciente.

> **Solo Android.** Mínimo Android 7.0 (Marshmallow).

---

## ¿Qué es esto?

Es una app personal que hice para poder explorar y organizar los mods de SM64 Coop Deluxe desde mi celular, sin tener que abrir el navegador cada vez. Lee el catálogo público de mods sm64coopdx y lo presenta en una interfaz móvil limpia y rápida.

No es oficial. No tiene ninguna relación con el equipo de SM64CoopDX ni con los creadores de mods. Es solo un proyecto personal.

## ¿Qué puedes hacer con ella?

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

## Cómo instalar

1. Descarga el `.apk` desde la página de [Releases](https://github.com/retired64/sm64cdpy.releases/releases).
2. En tu teléfono Android, abre el archivo. Si te pide permiso para instalar desde fuentes desconocidas, acéptalo — esto es normal para apps que no vienen de la Play Store.
3. Instala y abre. Eso es todo.

## Cómo actualizar la lista de mods

La app viene con una copia local de la base de datos. Cuando se agregan mods nuevos al sitio oficial, puedes actualizar tu lista sin reinstalar:

1. Abre la app → toca el **ícono de menú** (arriba a la izquierda) → **Settings**.
2. Toca **Reload database**.
3. La app descarga la lista más reciente desde este repositorio y actualiza todo automáticamente.

## ¿Es segura?

Sí. La app no recopila ningún dato, no requiere cuenta, no muestra publicidad y no se comunica con ningún servidor fuera de este repositorio de GitHub (y solo cuando tú tocas Reload manualmente). Tus favoritos se guardan localmente en tu dispositivo.

---

## ⚠️ Aviso Legal

Esta app es un **proyecto personal no oficial**. No está asociada, respaldada ni aprobada por los desarrolladores de SM64CoopDX, Super Mario 64, Nintendo, ni por ningún creador de mods. Los nombres, imágenes y contenido mostrado pertenecen a sus respectivos autores.

---

## 📬 Contacto

¿Encontraste un error o tienes una sugerencia? Escríbeme por Discord.

[![Discord](https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.com/invite/thuhUH2WNX)

---

<div align="center">
  <sub>Hecha con ❤️ para uso personal · Sin afiliación oficial · <a href="https://github.com/retired64/sm64cdpy.releases/releases">Descargar el APK más reciente</a></sub>
</div>
