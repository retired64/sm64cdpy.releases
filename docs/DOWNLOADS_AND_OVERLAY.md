# Descargas, instalación y overlay

Revisado contra `1.7.0+18` el 2026-09-20.

## Flujo de instalación

1. La UI comprueba la preferencia de instalación automática y la carpeta SAF.
2. `DownloadUrlResolver` normaliza el destino y resuelve assets de GitHub cuando corresponde.
3. `BackgroundInstallService.startDownloadAndInstall()` invoca el MethodChannel `mods.sm64cdpy/mod_installer`.
4. `ModInstallerPlugin` crea una cadena única de WorkManager: primero `ModDownloadWorker`, después `ModInstallWorker`.
5. El downloader sigue redirects, limita reintentos, verifica el tamaño cuando el servidor lo informa y publica porcentaje mediante `setProgress`.
6. El instalador copia archivos sueltos o extrae ZIP/7z hacia el árbol SAF.
7. El EventChannel `mods.sm64cdpy/mod_install_events` actualiza la UI y el overlay; ambos workers muestran notificaciones de primer plano cancelables.

Las cadenas usan un nombre derivado del mod con política `REPLACE`. Repetir la misma instalación reemplaza la anterior; mods distintos pueden avanzar en paralelo.

## Burbuja flotante

`floaty_chatheads` inicia `overlayMain()` en un engine Flutter separado. El panel puede buscar el catálogo y solicitar descarga/cancelación. `OverlayBridge` vive en el engine principal, recibe mensajes, inicia WorkManager y reenvía progreso al panel.

La preferencia `auto_install_mods` tiene SharedPreferences como fuente persistente y un caché `OverlayBridge._autoInstall` en el engine principal. El toggle de Settings escribe la preferencia y llama a `OverlayBridge.refreshAutoInstall()`. Este detalle no debe eliminarse: evita que el bridge opere con un valor antiguo.

## Permisos Android

- `SYSTEM_ALERT_WINDOW`: mostrar la burbuja.
- `POST_NOTIFICATIONS`: notificaciones en Android 13+.
- `FOREGROUND_SERVICE` y `FOREGROUND_SERVICE_DATA_SYNC`: workers visibles.
- `INTERNET`/`ACCESS_NETWORK_STATE`: catálogos y descargas.
- `REQUEST_INSTALL_PACKAGES`: actualización OTA del APK.
- Permisos SAF persistentes: escritura en las carpetas elegidas por el usuario.

## Estado conocido

El flujo está implementado y contiene correcciones para redirects múltiples, descargas truncadas, reintentos acotados, Android 14 y progreso de 7z. No existe todavía una prueba de integración automatizada que cubra recreación del proceso, dos mods simultáneos, cancelación, pérdida de permisos SAF o todos los niveles de Android soportados. Por eso el overlay permanece etiquetado como experimental.
