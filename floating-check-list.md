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

- [x] Leer completo `lib/` y documentar arquitectura real (state
      management, repos, datasources, servicios) — ver prompt de auditoría.
- [x] Leer completo `android/app/src/main/kotlin/mods/sm64cdpy/` y listar
      todos los `MethodChannel`/`EventChannel` existentes con su nombre
      exacto.
- [x] Confirmar `minSdk`, `targetSdk`, `compileSdk` actuales en
      `android/app/build.gradle.kts`.
- [x] **Fix: `eventSink` único en `ModInstallerPlugin.kt`.** Cambiarlo por
      una colección de sinks (o mecanismo de broadcast) para soportar el
      `EventChannel` de la app principal y el del overlay escuchando al
      mismo tiempo.
- [x] Decidir y documentar estrategia de estado compartido entre isolates
      (overlay usa su propio `ProviderScope`; qué datos, si alguno, se
      sincronizan vía `SharedPreferences`/Hive).
      > **Estrategia decidida e implementada:**
      > - **Favoritos**: migrados de Hive `Box<bool>` a SharedPreferences
      >   `setStringList('favourites', [...])` — seguro multi-isolate.
      > - **Settings (URIs SAF, auto_install)**: ya usan SharedPreferences — OK.
      > - **Tema/locale**: se quedan en Hive `settings` — el overlay no los
      >   comparte, tiene su propio tema en su `ProviderScope`.
      > - **Datos de mods**: cada isolate carga sus datasources desde archivos
      >   JSON cacheados en disco — sin conflicto.
      > - **Installs**: cada engine tiene su propia instancia de
      >   `ModInstallerPlugin` con sus propios observers de WorkManager. El
      >   overlay inicia y escucha sus propias descargas.
- [x] Verificar que `tools/context-floating-app/docs/` tiene descargados
      todos los documentos necesarios (`python cli.py list`); si falta
      alguno, correr `python cli.py fetch`.
      > **Documentos añadidos a config.yaml y fetcheados:**
      > - `foreground_service_types.md` (25 KB) — `specialUse` y otros tipos
      > - `foreground_service_declare.md` (3.4 KB) — declaración en manifest
      > - `add_to_app_android.md` (16 KB) — integración Flutter en Android
      > - `overlay_permission_settings.md` (131 KB) — `ACTION_MANAGE_OVERLAY_PERMISSION`

---

## Fase 0 · Permiso de overlay + burbuja nativa (sin Flutter)

### Permisos y manifest
- [x] Añadir `<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />`
      a `AndroidManifest.xml`.
- [x] Declarar `OverlayService` en el manifest con
      `foregroundServiceType` correcto para Android 14+ (verificar en
      `docs/android/foreground_services.md` si aplica `specialUse` y qué
      razón hay que declarar).
- [x] Declarar el permiso de foreground service correspondiente
      (revisar si `FOREGROUND_SERVICE_SPECIAL_USE` es necesario además
      del `FOREGROUND_SERVICE` que ya existe).

### Flujo de permiso (Kotlin + Flutter)
- [x] Crear `OverlayPermission.kt`: función para chequear
      `Settings.canDrawOverlays(context)`.
- [x] Crear intent hacia `Settings.ACTION_MANAGE_OVERLAY_PERMISSION` para
      solicitar el permiso.
- [x] Exponer `hasOverlayPermission` / `requestOverlayPermission` vía
      `MethodChannel` (reutilizar patrón de `hasNotificationPermission`
      / `requestNotificationPermission` ya existente en
      `ModInstallerPlugin.kt`).
- [x] Añadir UI en la pantalla de Settings de Flutter (`settings_screen.dart`)
      para solicitar el permiso y mostrar su estado actual.

### Foreground Service
- [x] Crear `OverlayService.kt` extendiendo `Service`.
- [x] Reutilizar el patrón de canal de notificación de
      `MainActivity.createNotificationChannel()` para la notificación
      persistente obligatoria del foreground service.
- [x] Implementar `onStartCommand`, `onDestroy`, y limpieza de la vista del
      `WindowManager` al detener el servicio.

### Burbuja nativa arrastrable
- [x] Crear `BubbleView.kt` (o layout XML simple) con ícono de la app.
- [x] Añadir la vista al `WindowManager` con
      `WindowManager.LayoutParams(TYPE_APPLICATION_OVERLAY, ...)`.
- [x] Implementar `OnTouchListener` para arrastrar (actualizar `x`/`y` de
      `layoutParams` en `ACTION_MOVE`, usando `updateViewLayout`).
- [x] Distinguir tap vs. drag (umbral de movimiento/tiempo) para poder
      diferenciar "mover burbuja" de "abrir panel".
- [x] Persistir la última posición de la burbuja (SharedPreferences) para
      restaurarla al reabrir.

### Validación de Fase 0
- [ ] La burbuja aparece sobre otra app (probar sobre el launcher, no
      solo dentro de la propia app).
- [ ] La burbuja se puede arrastrar por toda la pantalla sin trabarse.
- [ ] El servicio sobrevive al cambiar de app (probar abriendo el juego
      real, SM64CoopDX).
- [ ] El permiso se solicita correctamente en un dispositivo/emulador con
      Android 12+ y otro con Android 8-11 si es posible (el flujo cambió
      entre versiones — confirmar en `docs/android/overlay_permission_settings.md`).

---

## Fase 1 · Panel expandido con FlutterEngine

- [ ] Crear entrypoint Dart secundario `lib/overlay/overlay_main.dart`
      marcado con `@pragma('vm:entry-point')`.
- [ ] Crear `overlay_app.dart` con un `ProviderScope` propio y un widget
      mínimo de prueba (ej. un texto o botón).
- [ ] Crear `OverlayFlutterHost.kt`: instanciar `FlutterEngine`, ejecutar
      el entrypoint del overlay, y cachearlo con
      `FlutterEngineCache.getInstance().put(...)`.
- [ ] Evaluar uso de `FlutterEngineGroup` en vez de `FlutterEngine`
      aislado, para compartir recursos con la app principal si ambas
      corren a la vez (ver `docs/flutter/add_to_app.md`).
- [ ] Crear `FlutterView`, adjuntarlo al engine, y añadirlo al
      `WindowManager` con sus propios `LayoutParams` (distintos a los de
      la burbuja).
- [ ] Implementar la transición: tap en burbuja → oculta burbuja / muestra
      panel, y botón de cerrar panel → vuelve a mostrar burbuja.
- [ ] Manejar destrucción correcta del `FlutterEngine` al cerrar el panel
      o detener el servicio (evitar fugas de memoria).

### Validación de Fase 1
- [ ] El panel Flutter se renderiza correctamente sobre el juego.
- [ ] Cerrar y reabrir el panel varias veces no genera fugas de memoria
      visibles (revisar con Android Studio Profiler).
- [ ] El proceso no crashea al rotar pantalla o cambiar configuración
      mientras el panel está abierto.

---

## Fase 2 · Canal de comunicación Service ↔ Panel

- [ ] Crear `OverlayChannels.kt` con nombres de canal dedicados (ej.
      `mods.sm64cdpy/overlay_bridge`), distintos de
      `sm64cdpy/launcher` y `mods.sm64cdpy/mod_installer` ya existentes.
- [ ] Crear `overlay_bridge.dart` en Flutter con el `MethodChannel`
      correspondiente.
- [ ] Implementar comando `closeOverlay`.
- [ ] Implementar comando `expandPanel` / `collapsePanel`.
- [ ] Implementar comando `resizePanel` (si el panel tendrá distintos
      tamaños/estados, según lo discutido: burbuja → panel chico →
      lista de resultados).

### Validación de Fase 2
- [ ] Los comandos desde Flutter afectan correctamente el estado nativo
      del overlay (probar cada uno manualmente).

---

## Fase 3 · Reutilizar el buscador de mods

- [ ] Confirmar que el fix del `eventSink` (Fase -1) está en producción
      antes de empezar esta fase.
- [ ] Importar/usar `ModRepositoryImpl` y los datasources existentes
      dentro del `ProviderScope` del overlay, sin duplicar código.
- [ ] Adaptar/crear una versión reducida de la UI de búsqueda
      (`catalogue_screen.dart` como referencia) optimizada para el
      espacio pequeño del panel flotante.
- [ ] Verificar que las llamadas de red de los datasources no dependen de
      ningún estado en memoria exclusivo de la app principal.

### Validación de Fase 3
- [ ] Buscar un mod desde el overlay devuelve los mismos resultados que
      buscarlo desde la app normal.
- [ ] La búsqueda funciona con el juego corriendo en primer plano (sin
      lag perceptible que afecte el juego).

---

## Fase 4 · Reutilizar descarga e instalación

- [ ] Llamar `downloadAndInstallMod` / `installModBackground` desde el
      overlay tal cual existen hoy en `ModInstaller` — cero lógica nueva
      de descarga.
- [ ] Suscribir el panel del overlay a `BackgroundInstallService.instance.events`
      (o al stream equivalente) para mostrar progreso.
- [ ] Confirmar que las notificaciones de descarga/instalación
      (`ModDownloadWorker`, `ModInstallWorker`) siguen funcionando igual
      con el overlay activo.
- [ ] Manejar el caso de cerrar el panel/burbuja mientras hay una
      descarga en curso (no debe cancelarla; `WorkManager` sigue
      corriendo independientemente de la UI).

### Validación de Fase 4
- [ ] Descargar e instalar un mod completo desde el overlay, con el juego
      corriendo, sin salir del juego en ningún momento.
- [ ] Cancelar una descarga desde el overlay funciona igual que desde la
      app principal.
- [ ] Verificar consumo de batería/CPU razonable con el overlay + juego
      corriendo simultáneamente durante una sesión larga (15-20 min).

---

## Fase 5 · Pulido (futuro, no bloqueante para el MVP)

- [ ] Mods instalados / activar-desactivar mods desde el overlay.
- [ ] Favoritos accesibles desde el overlay.
- [ ] Historial de instalaciones.
- [ ] Quick Settings (acceso rápido a configuración sin abrir la app
      completa).
- [ ] Animaciones de transición burbuja ↔ panel.

---

## Registro de avance

| Fecha | Fase | Nota |
|-------|------|------|
| 2026-07-28 | Fase -1 | Auditoría completa. Fix eventSink → colección de sinks. Favoritos migrados a SharedPreferences. Docs fetcheados. |
| 2026-07-28 | Fase 0 | SYSTEM_ALERT_WINDOW + FOREGROUND_SERVICE_SPECIAL_USE. OverlayService.kt, BubbleView.kt, OverlayPermission.kt. UI toggle en settings_screen.dart. Build release OK. |
