# floating-check-list.md — Panel Flotante (Overlay) SM64CoopDX Mods

> Ubicación: raíz del proyecto (`~/APPDUMP/source-code/floating-check-list.md`)
>
> **Cómo usarla (para la IA y para ti):**
> - Marca una tarea como hecha cambiando `- [ ]` por `- [x]` **solo** cuando
>   esté implementada, compilando, y verificada contra el código real o la
>   documentación oficial en `tools/context-floating-app/docs/` — no marques
>   algo como terminado solo porque "debería funcionar".
> - Si una tarea se bloquea o se pospone, no la marques como hecha: añade
>   una nota debajo con `> Nota:` explicando por qué.
> - No saltes de fase. Cada fase asume que la anterior está 100% marcada.
> - Cuando termines una fase completa, actualiza el checklist y haz commit
>   de este archivo junto con el código, para llevar historial real del
>   progreso.

---

## Fase -1 · Auditoría y fixes previos (bloqueante, antes de tocar overlay)

- [x] Leer completo `lib/` y documentar arquitectura real (state management, repos, datasources, servicios).
- [x] Leer completo `android/app/src/main/kotlin/mods/sm64cdpy/` y listar todos los `MethodChannel`/`EventChannel` existentes.
- [x] Confirmar `minSdk`, `targetSdk`, `compileSdk` actuales en `android/app/build.gradle.kts`.
- [x] **Fix: `eventSink` único en `ModInstallerPlugin.kt`.** Cambiado a `MutableList<EventSink>` con broadcast a todos los listeners.
- [x] **Estrategia de estado compartido entre isolates.** Favoritos migrados de Hive a SharedPreferences. Settings ya usan SharedPreferences. Datos de mods desde archivos JSON cacheados en disco.
- [x] Verificar docs en `tools/context-floating-app/docs/` — fetcheados `foreground_service_types.md`, `foreground_service_declare.md`, `add_to_app_android.md`, `overlay_permission_settings.md`.

---

## Fase 0 · Integración de `floaty_chatheads` + overlay funcional

### Migración desde código propio al paquete
- [x] Añadir `floaty_chatheads: ^2.0.0` a `pubspec.yaml`.
- [x] Añadir `WAKE_LOCK` a `AndroidManifest.xml`.
- [x] Eliminar código overlay propio: `android/.../overlay/` (5 archivos), `lib/overlay/` (3 archivos), métodos overlay en `ModInstallerPlugin.kt` y `mod_installer.dart`.
- [x] Limpiar strings ARB de overlay.
- [x] Crear `lib/overlay/overlay_main.dart` con `@pragma('vm:entry-point')` usando `FloatyOverlayApp.run()`.
- [x] Crear `lib/overlay/overlay_panel.dart` con widget `OverlayPanel` (placeholder).
- [x] Añadir `_OverlayToggle` en `settings_screen.dart` usando API `FloatyChatheads` (checkPermission, requestPermission, showChatHead, closeChatHead, isActive).
- [x] Build release OK (`flutter build apk --release --split-per-abi`).

### Validación de Fase 0
- [x] La burbuja aparece sobre el launcher u otra app.
- [x] La burbuja se puede arrastrar y hace snap al borde.
- [x] Al tocar la burbuja se expande el panel Flutter con el botón CLOSE.
- [x] El botón CLOSE cierra el panel y vuelve la burbuja.
- [x] Arrastrar la burbuja al objetivo de cierre (abajo) la despide.
- [x] El overlay sobrevive al cerrar la app (persistOnAppClose: true).
- [x] Toggle en Settings sincronizado: CLOSE o drag-to-dismiss apaga el switch.

---

## Fase 1 · Mensajería bidireccional + UI de mods

- [ ] Conectar `FloatyChatheads.shareData()` / `FloatyOverlay.shareData()` para comunicación app↔overlay.
- [ ] Crear ProviderScope propio en el overlay para Riverpod.
- [ ] Importar `ModRepositoryImpl` + datasources en el overlay.
- [ ] Adaptar UI de búsqueda (`catalogue_screen.dart`) al espacio reducido del panel.
- [ ] Mostrar resultados de búsqueda en el panel.

### Validación de Fase 1
- [ ] Buscar un mod desde el overlay devuelve los mismos resultados que la app.
- [ ] La UI del overlay es usable con el juego en primer plano.

---

## Fase 2 · Descarga e instalación desde el overlay

- [ ] Llamar `downloadAndInstallMod` / `installModBackground` desde el overlay (reutilizar `ModInstaller`).
- [ ] Suscribir el panel a `BackgroundInstallService.instance.events` para progreso.
- [ ] Verificar que WorkManager notificaciones siguen funcionando con overlay activo.
- [ ] Manejar cierre del panel durante descarga en curso.

### Validación de Fase 2
- [ ] Descargar e instalar un mod completo desde el overlay con el juego abierto.
- [ ] Cancelar descarga desde el overlay.
- [ ] Consumo de batería/CPU razonable en sesión larga (15-20 min).

---

## Fase 3 · Pulido (futuro)

- [ ] Favoritos accesibles desde el overlay.
- [ ] Historial de instalaciones.
- [ ] Animaciones de transición.
- [ ] Quick Settings.

---

## Registro de avance

| Fecha | Fase | Nota |
|-------|------|------|
| 2026-07-28 | Fase -1 | Auditoría. Fix eventSink → colección. Favoritos → SharedPreferences. Docs fetcheados. |
| 2026-07-28 | Fase 0 (v1) | Código propio: OverlayService, BubbleView, FlutterEngine manual. Panel no renderizaba (SurfaceView vs TextureView). |
| 2026-07-28 | Fase 0 (v2) | Migración a `floaty_chatheads`. Eliminadas ~400 líneas de código propio. Build OK. |
