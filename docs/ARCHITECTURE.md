# Arquitectura actual

Revisado contra `1.7.0+18` el 2026-09-20.

## Alcance

SM64CDPY es una aplicación Flutter orientada exclusivamente a Android. Combina una interfaz Flutter, integración nativa Kotlin y trabajo persistente de Android. El directorio `linux/` es scaffold generado y no representa soporte de escritorio.

## Capas

| Área | Ruta | Responsabilidad |
|---|---|---|
| Núcleo | `lib/core/` | Constantes, rutas, tema y utilidades |
| Datos | `lib/data/` | Lectura de JSON, caché, modelos y repositorio |
| Dominio | `lib/domain/` | Entidades e interfaz del repositorio principal |
| Presentación | `lib/presentation/` | Pantallas, widgets y estado Riverpod |
| Servicios | `lib/services/` | OTA, resolución de URLs y puentes con Android |
| Overlay | `lib/overlay/` | UI flotante y puente con el engine principal |
| Android | `android/app/src/main/kotlin/mods/sm64cdpy/` | SAF, WorkManager, extracción y canales Flutter |

La arquitectura es deliberadamente híbrida: el catálogo principal utiliza entidades/repositorio; las colecciones pequeñas tienen datasources y providers directos.

## Arranque

`lib/main.dart` configura orientaciones, downloader, Hive, información de versión, eventos de instalación y el puente del overlay. Después crea el árbol Riverpod y `MaterialApp.router`.

Existe una segunda entrada, `overlayMain()`, usada por `floaty_chatheads`. Este engine no comparte memoria estática con el engine principal. La comunicación se realiza con `FloatyChatheads.shareData`/streams y el estado persistente debe viajar por almacenamiento o canales, nunca por la suposición de memoria común.

## Datos y persistencia

- Los catálogos iniciales viven en `assets/db/`.
- `db/` contiene las copias publicadas que consumen las actualizaciones remotas.
- Hive guarda preferencias de interfaz y favoritos usados por providers.
- SharedPreferences guarda flags que también necesitan servicios/puentes, como `auto_install_mods`.
- El plugin Kotlin guarda las URI SAF (`tree_uri`, `dynos_tree_uri`) en sus propias SharedPreferences nativas y conserva permisos persistentes del árbol.
- `BackgroundInstallService` mantiene una vista en memoria de trabajos activos; WorkManager sigue siendo la autoridad para su ejecución.

## Navegación y estado

GoRouter define un `ShellRoute` para las pantallas principales y una ruta de detalle fuera del shell. Riverpod administra catálogo, filtros, paginación, favoritos, tema e idioma.

## Límites importantes

1. El proceso o cualquiera de los engines puede ser recreado por Android.
2. Las variables estáticas no sincronizan el engine principal y el overlay.
3. Dos instalaciones pueden ejecutarse en paralelo; nombres de trabajo, archivos temporales y notificaciones deben ser únicos por mod/instancia.
4. Una URI SAF puede perder permisos y debe revalidarse antes de escribir.
5. Los eventos en memoria no sustituyen el estado persistido de WorkManager.

El checklist obligatorio para cambios de estado compartido está en [`../AGENTS.md`](../AGENTS.md).
