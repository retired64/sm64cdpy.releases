# Descargas, instalación y overlay

Revisado contra `1.7.0+18` el 2026-09-20.

## Flujo de instalación

1. La UI comprueba la preferencia de instalación automática y la carpeta SAF.
2. `DownloadUrlResolver` normaliza el destino y resuelve assets de GitHub cuando corresponde.
3. `BackgroundInstallService.startDownloadAndInstall()` invoca el MethodChannel `mods.sm64cdpy/mod_installer`.
4. `ModInstallerPlugin` crea una cadena única de WorkManager: primero `ModDownloadWorker`, después `ModInstallWorker`.
5. El downloader sigue redirects, limita reintentos, verifica el tamaño cuando el servidor lo informa y publica porcentaje mediante `setProgress`.
6. El instalador copia archivos sueltos o extrae ZIP/7z hacia el árbol SAF.
7. El EventChannel `mods.sm64cdpy/mod_install_events` actualiza un provider global, la UI y el overlay; ambos workers muestran notificaciones de primer plano cancelables.
8. Al terminar, un coordinador global muestra el resultado aunque el usuario haya cambiado de pantalla. Android conserva una notificación de instalación completa en un canal de resultados independiente y visible, mientras los canales de progreso siguen siendo silenciosos.

Al recrear el proceso, Flutter carga los UUID persistidos, solicita una instantánea a WorkManager y vuelve a registrar los observers nativos. Los trabajos inexistentes se descartan; RUNNING, ENQUEUED, SUCCEEDED, FAILED y CANCELLED se traducen de nuevo al estado compartido.

Las cadenas usan una clave canónica derivada de sección, ID del contenido y archivo con política `REPLACE`. Repetir exactamente la misma instalación reemplaza la anterior; archivos o mods distintos pueden avanzar en paralelo. Los IDs de notificación se derivan del UUID de cada Worker.

El catálogo general resuelve una versión actual canónica antes de presentar descargas: prioriza la fecha de publicación válida, usa los componentes numéricos de versión como respaldo y conserva el orden de la fuente para empates. Las versiones sin archivos descargables se ignoran. Detalle y overlay consumen el mismo resolvedor, por lo que una descarga directa nunca selecciona accidentalmente un archivo histórico. Si la versión actual contiene varios archivos, el overlay ofrece un selector compacto.

## Burbuja flotante

`floaty_chatheads` inicia `overlayMain()` en un engine Flutter separado. El panel puede buscar el catálogo y solicitar descarga/cancelación. `OverlayBridge` vive en el engine principal, recibe mensajes, inicia WorkManager y reenvía progreso al panel. Ambos lados intercambian la misma clave canónica; la cancelación permanece en estado "cancelando" hasta que WorkManager la confirma.

La pantalla de detalle presenta únicamente la versión actual expandida. El historial se abre bajo demanda en una hoja inferior con `ListView.builder`, evitando que decenas o cientos de versiones aumenten el alto inicial o se construyan simultáneamente.

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
