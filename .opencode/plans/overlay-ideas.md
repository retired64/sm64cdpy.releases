# Ideas de mejora — Overlay flotante SM64CDPY

---

## 1. Cancelar descarga desde el overlay

**Problema:** El usuario no puede cancelar una descarga en curso desde el overlay.

**Implementación:**
- En `_ModTileState`, agregar `onLongPress` al tile cuando `_isActive` sea true.
- Al hacer long-press, llamar al bridge vía `FloatyOverlay.shareData({'type': 'cancel_download', 'modTitle': title})`.
- En `OverlayBridge._onMessageFromOverlay`, caso nuevo `'cancel_download'`: hacer `BackgroundInstallService.instance.cancelMod(modName)`.
- Para dynos/touch: agregar mecanismo de cancelación del `FileDownloader` (requiere guardar el cancelToken de `downloadFile`).
- UI: snackbar "Download cancelled" + reset del tile a idle.

**Esfuerzo:** ~20 líneas.

---

## 2. Badge de descargas activas en la burbuja

**Problema:** El usuario no sabe si hay descargas en curso sin abrir el panel.

**Implementación:**
- `FloatyChatheads` soporta `updateBadge(int count)` o similar (verificar API exacta).
- En `OverlayBridge`, mantener contador `_activeDownloadCount`.
- Incrementar en cada `BgInstallStarted`, decrementar en `BgInstallCompleted`, `BgOperationCancelled`, `BgInstallError`.
- Llamar `FloatyChatheads.updateBadge(_activeDownloadCount)` al cambiar.
- Si la API no existe, usar `FloatyChatheads.setIcon()` para cambiar entre burbuja normal y burbuja con badge.

**Esfuerzo:** ~25 líneas + verificación de API de `floaty_chatheads`.

---

## 3. Indicador de favoritos en cada tile

**Problema:** El overlay solo permite buscar y descargar — no marca favoritos.

**Implementación:**
- Cada item tiene `mod.id` y `mod.section`. Los favoritos ya se persisten en SharedPreferences con prefijos (`vip_`, `dynos_`, `tc_`, `omm_`, mods normales usan su propio sistema).
- En `_ModTile`, agregar un ícono ⭐ a la izquierda del título.
- Al tocar la estrella, leer/escribir SharedPreferences directamente desde el overlay (es multi-isolate-safe).
- Estado visual: ⭐ teal si es favorito, gris `Colors.white24` si no.
- No necesita bridge — todo se maneja localmente en el overlay con `shared_preferences`.

**Esfuerzo:** ~20 líneas.

---

## 4. Pestaña "HISTORY" (últimos descargados)

**Problema:** Si el usuario quiere reinstalar un mod que ya bajó, tiene que volver a buscarlo.

**Implementación:**
- Agregar `OverlaySection.history` al enum.
- Mantener lista de últimos descargados en SharedPreferences (máx. 20).
- En `_onOverlayData`, cuando llega `install_progress` con `status: 'done'`, guardar `modTitle + section + url` en la lista.
- El tab HISTORY muestra esta lista ordenada por más reciente.
- Cada ítem tiene el botón ⬇ para re-descargar directamente.

**Esfuerzo:** ~50 líneas (enum + provider + UI del tab + persistencia).

---

## 5. Ordenar resultados

**Problema:** Los resultados siempre salen en el orden del datasource (alfabético por ID).

**Implementación:**
- Agregar `overlaySortProvider` con opciones: `name` (default), `date` (si el modelo tiene `addedAt`), `rating` (si tiene `rating`).
- Un pequeño dropdown o botón ciclador arriba de la lista: `A-Z ▼` → toca → `★ ▼` → toca → `🕐 ▼` → vuelve a `A-Z`.
- El sort se aplica en `overlayFilteredItems` después del filtro de búsqueda pero antes de la paginación.
- Solo aplicable para secciones que tengan los campos (ALL, VIP, OMM sí tienen rating/date; DYN también; TCH solo tiene `addedAt`).

**Esfuerzo:** ~30 líneas.

---

## 6. Feedback háptico al completar descarga

**Problema:** El jugador está en el juego y no mira el overlay. No sabe cuándo terminó la descarga.

**Implementación:**
- En `_onOverlayData`, cuando `_mapStatus(raw) == 'done'`, llamar `HapticFeedback.mediumImpact()`.
- La vibración se siente en el dispositivo sin necesidad de mirar la pantalla.

**Esfuerzo:** 1 línea.

---

## 7. Swipe-down para cerrar el panel

**Problema:** Para cerrar el panel hay que tocar la burbuja de nuevo. Un gesto de swipe sería más natural.

**Implementación:**
- Envolver el `Scaffold` en un `GestureDetector` con `onVerticalDragEnd`.
- Si el drag hacia abajo supera un umbral (~30% del panel), llamar `FloatyOverlay.hide()`.
- Verificar que `FloatyOverlay` tenga un método `hide()` o equivalente para colapsar a burbuja.
- Si no existe, usar `FloatyChatheads.collapseChatHead()` desde el bridge vía shareData.

**Esfuerzo:** ~20 líneas + verificación de API.

---

## 8. Opacidad ajustable del panel

**Problema:** El panel es 100% opaco y tapa completamente el juego.

**Implementación:**
- Agregar slider en el mini-settings del overlay (expandir el toggle AUTO actual o agregar un ícono ⚙ que abra un mini-panel de ajustes).
- Guardar opacidad en SharedPreferences: `overlay_opacity` (0.5 a 1.0, default 1.0).
- Envolver el `Scaffold` en un `Opacity` widget que lea el valor.
- También aplicable a la burbuja: `FloatyChatheads` puede soportar opacidad de la burbuja nativa.

**Esfuerzo:** ~30 líneas.

---

## 9. Personalizar ícono de la burbuja

**Problema:** La burbuja usa un ícono genérico por defecto. Sería mejor usar el ícono de la propia app (SM64CDPY) o el ícono del mod que se está descargando.

**Implementación:**
- `FloatyChatheads` expone `setChatHeadIcon(Widget)` o `setChatHeadIconAsset(String path)` para cambiar el ícono de la burbuja.
- Opción A — Ícono de la app: usar el asset `assets/icon/app_icon.png` (o el que corresponda) al inicializar la burbuja.
- Opción B — Ícono dinámico: al iniciar una descarga, cambiar el ícono de la burbuja a un badge animado (⚙ girando, o el ícono del mod si tiene `imageUrl`). Al completar, volver al ícono default.
- Si la API de `floaty_chatheads` no soporta íconos custom, se puede usar `setChatHeadTitle(String)` para poner un texto corto tipo "SM64" en la burbuja.
- Verificar en la documentación de `floaty_chatheads` qué métodos están disponibles para personalización visual.

**Esfuerzo:** ~15 líneas + verificación de API.

---

## Priorización sugerida

| # | Idea | Impacto | Esfuerzo | Orden |
|---|------|---------|----------|-------|
| 9 | Personalizar ícono burbuja | Alto | Bajo | **1** |
| 6 | Feedback háptico | Alto | Mínimo | **2** |
| 2 | Badge descargas activas | Alto | Bajo | **3** |
| 3 | ⭐ Favoritos | Medio | Bajo | **4** |
| 1 | Cancelar descarga | Alto | Medio | **5** |
| 5 | Ordenar resultados | Medio | Medio | **6** |
| 4 | HISTORY tab | Medio | Medio | **7** |
| 7 | Swipe-down cerrar | Bajo | Medio | **8** |
| 8 | Opacidad ajustable | Bajo | Medio | **9** |

---

## Notas técnicas

- Todas las ideas que requieren compartir estado overlay↔main usan `FloatyOverlay.shareData()`/`FloatyChatheads.shareData()`.
- Las ideas de solo UI (favoritos, opacidad, sort) se implementan 100% en el overlay sin tocar el bridge.
- `SharedPreferences` es multi-isolate-safe, se puede usar directamente desde el overlay sin pasar por el bridge.
