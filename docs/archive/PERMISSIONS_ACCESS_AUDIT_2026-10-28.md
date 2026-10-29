# Auditoría de permisos, accesos e instalación rápida

Fecha: 2026-10-28.
Repositorio: sm64cdpy.releases.
Rama: r2-phase6-flutter-fallback.
Commit inspeccionado: 9e8c6723542956f0056291c87f14b17428e0451d.
Estado: revisión estática; propuestas pendientes, sin correcciones funcionales.

## 1. Alcance y evidencia

Se revisaron la pantalla de permisos, servicios Dart, MethodChannel, solicitudes
Android, selección de escritura directa/SAF y estado de carpeta. Se consultó
documentación oficial de Android.

No se comprobó el APK instalado, su manifiesto final, el modelo del teléfono,
su Android ni su versión/build. No hubo pruebas físicas ni mediciones de
velocidad. El código fuente de una rama no demuestra qué contiene el APK
instalado. Esta entrega solo modifica documentación.

Las observaciones del usuario, hallazgos de código, hipótesis y propuestas
se distinguen a continuación. No se ejecutaron suites Flutter/Kotlin para
esta entrega documental.

## 2. Observación del usuario: solo ve notificaciones

El usuario indica que en Ajustes → Información de la app parece aparecer
únicamente el permiso de notificaciones. No encuentra rastro del permiso
«administrar todos los archivos». Se registra sin atribuir una causa definitiva.

### Diferencia importante entre categorías

En Android moderno, notificaciones y acceso amplio a archivos tienen mecanismos
distintos. El segundo es un acceso especial y no tiene que aparecer junto a los
permisos de ejecución de la ficha normal.

Ruta orientativa en Android 11+:
Ajustes → Aplicaciones → Acceso especial de aplicaciones →
Acceso a todos los archivos / Administrar todos los archivos → SM64CDPY.

Los nombres y ubicación varían según fabricante. La ausencia en la lista normal
no demuestra que el permiso falte en el APK. Si tampoco aparece en la lista
especial, hay que inspeccionar versión de Android, APK y comportamiento de Ajustes.

### Diferencias por Android en el código actual

| Sistema | Comportamiento |
|---|---|
| Android 7–9, API 24–28 admitidas por la app | WRITE_EXTERNAL_STORAGE tras acción opcional |
| Android 10, API 29 | SAF; supportsAllFilesAccess=false; no solicitud legacy ineficaz |
| Android 11+, API 30+ | MANAGE_EXTERNAL_STORAGE mediante Ajustes; consulta isExternalStorageManager |

minSdk es 24 en android/app/build.gradle.kts. No buscar el acceso especial
moderno en Android 10 como si utilizara el mismo flujo.

### Declaración y package comprobados

android/app/src/main/AndroidManifest.xml declara MANAGE_EXTERNAL_STORAGE,
POST_NOTIFICATIONS y WRITE_EXTERNAL_STORAGE con maxSdkVersion=28.
El applicationId configurado es mods.sm64cdpy.

Esto confirma el manifiesto fuente; no el manifiesto combinado de un APK
desconocido o de otra versión instalada.

## 3. Flujo vertical de instalación rápida

La tarjeta de PermissionsAccessScreen usa:
- fastInstallTitle: «Activar instalación rápida».
- permissionAllFilesDescription.
- allowed: snapshot?.allFiles.
- acción PermissionAccessService.requestAllFiles().

La acción sigue:
FastInstallAccess.request → canal mods.sm64cdpy/mod_installer →
requestAllFilesAccess → ModInstallerPlugin.requestAllFilesAccess.

Android 11+: abre ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION para el package.
Si no existe la actividad específica, intenta ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION.
Abrir Ajustes retorna false: no se trata como concesión.
Si ya está concedido, retorna true inmediatamente sin abrir Ajustes.

La consulta sigue:
PermissionAccessService.snapshot → supportsAllFilesAccess / hasAllFilesAccess →
SafZipExtractor.hasAllFilesAccess → Environment.isExternalStorageManager en 11+.

El centro vuelve a consultar al reanudar. El escritor se decide por operación:
openSink exige grant SAF y elige DirectTreeWriter o SafTreeWriter.

## 4. Hallazgos

### P-01. Nombre del permiso insuficientemente explícito

Prioridad alta de claridad.

La pantalla presenta el beneficio «Activar instalación rápida» sin identificar
expresamente en su descripción actual «acceso a todos los archivos».
El usuario descubre el nombre y alcance real al llegar a Android.

fastInstallDescription sí explica el acceso amplio, pero la tarjeta actual usa
permissionAllFilesDescription. El widget antiguo _FastInstallTile conserva aquel
texto; la búsqueda encontró su declaración/constructor, sin una instancia en
el árbol actual de Ajustes.

Propuesta: título «Acceso a todos los archivos» y explicación previa de finalidad,
alcance, opcionalidad y alternativa por carpeta.

### P-02. Permiso concedido no garantiza ruta rápida compatible

Prioridad alta funcional/semántica.

El centro usa snapshot.allFiles; no verifica elegibilidad del destino.

SafZipExtractor.resolveDirectDir exige:
- proveedor com.android.externalstorage.documents;
- permiso amplio concedido;
- document ID primary:;
- directorio existente y escribible;
- grant SAF persistente de lectura/escritura;
- ruta aceptada por DirectInstallPaths.

DirectInstallPaths rechaza Android/, volúmenes secundarios, traversal, rutas
inválidas y alias mediante symlink.

Caso reproducible previsto: conceder acceso amplio y usar un destino secundario.
El centro indica «Permitido» bajo instalación rápida, pero el escritor usa SAF.
El dato del permiso puede ser correcto; la capacidad sugerida no queda comprobada.
No se encontró una afirmación literal de que el escritor directo esté activo.

Propuesta: separar permiso, elegibilidad de carpeta y modo real de la operación.

### P-03. «Administrar» no administra permisos ya concedidos

Prioridad media.

requestAllFilesAccess retorna true sin abrir ajustes si ya tiene autorización.
Por ello pulsar «Administrar» con acceso concedido no permite revisarlo/revocarlo.

Notificaciones tiene el mismo patrón: ensureNotificationPermission retorna true
si ya está permitido. La solicitud de batería también retorna sin abrir Ajustes
si ya existe exención.

Propuesta: separar request de openSettings. Usar «Conceder acceso» cuando falta
y «Abrir ajustes» para administrar incluso cuando está concedido.

### P-04. Errores convertidos en denegación o falta de soporte

Prioridad alta de diagnóstico.

PermissionAccessService._safe captura cualquier excepción y retorna false:
- consulta de granted fallida: puede mostrar «No permitido»;
- consulta de supported fallida: puede ocultar la tarjeta;
- error abriendo Ajustes: se pierde el motivo.

La tarjeta ignora el resultado de requestAllFiles. En Android moderno false
también significa que se abrió Ajustes, no necesariamente error o denegación.

Propuesta: separar unknown, loading, unsupported, denied, granted y error.
Distinguir resultado de apertura de estado concedido. Conservar diagnóstico y
mostrar un mensaje accionable cuando no se pudo abrir o consultar.

### P-05. Carpeta conectada no expresa todas las capacidades

Prioridad media.

La tarjeta usa connection.connected, mientras el modelo distingue fullAccess,
unified y errores. Existen conexiones heredadas limitadas a user/. La descripción
genérica puede sugerir más capacidad de la comprobada.

GameFolderNotifier.refresh conserva connection previa al capturar una excepción
y guarda error='access'. El centro no representa ese error: puede seguir mostrando
el estado positivo anterior sin verificación reciente.

Un error no prueba revocación, pero tampoco debe presentar la copia anterior como
recién verificada.

### P-06. Carga y opcionalidad mezcladas

Prioridad baja/media.

allowed==null muestra «Opcional · verificando estado». Opcionalidad es distinta
de carga. Las tarjetas aparecen mientras se desconoce compatibilidad porque la
condición es != false. La carpeta inicialmente parte de connected=false.

Propuesta: representar comprobación y error como estados propios, y opcionalidad
como propiedad independiente.

### P-07. Exención de batería tiene alcance más estrecho que unrestricted

Prioridad baja/media.

El centro denomina batteryUnrestricted al resultado de
PowerManager.isIgnoringBatteryOptimizations. Comprueba la exención concreta,
no todas las restricciones de batería de Android/fabricante.
Si falla la consulta, supported=false oculta la tarjeta.

Propuesta: nombrar y explicar la exención precisa; no prometer ejecución ilimitada.

## 5. Qué está correctamente implementado

- Android es autoridad; no hay cache Flutter del permiso amplio.
- Reconsulta al regresar de Ajustes.
- Abrir Ajustes no se toma como autorización.
- Android 10 conserva SAF sin solicitar permiso legacy ineficaz.
- Denegar acceso amplio mantiene disponible SAF.
- La ruta directa conserva requisito de grant de carpeta.
- Elegibilidad revisada por instalación.
- Rutas directas contenidas y destinos incompatibles rechazados.
- Existe DirectTreeWriter: la función no es inventada.
- Auto-install es una preferencia independiente, no un permiso.

No se midió velocidad física. No afirmar aceleración universal ni tiempos
concretos. Conceder acceso amplio no selecciona carpeta ni activa auto-install.

## 6. Documentación y alcance del permiso

FAST_INSTALLATION.md describe requisitos y opcionalidad, pero su referencia
a la antigua tarjeta que se oculta al conceder acceso no describe por completo
el centro actual. Reconciliar al corregir.

MANAGE_EXTERNAL_STORAGE permite acceso amplio a almacenamiento compartido.
No es root, no abre datos privados de otras apps ni elimina restricciones SAF.
La ruta directa de este proyecto es todavía más restrictiva: excluye Android/
y volúmenes secundarios.

## 7. Inspección posterior del dispositivo y APK

Recoger:
- modelo/fabricante y Android/API;
- versión/build, package y procedencia del APK;
- pantalla exacta de permisos consultada;
- aparición en Acceso especial → Todos los archivos;
- resultado de pulsar la tarjeta dentro de la app;
- proveedor/volumen de carpeta elegida, sin divulgar datos privados.

Pasos:
1. Confirmar Android 11+ antes de buscar el acceso especial moderno.
2. Revisar la lista especial además de Información de la app → Permisos.
3. Pulsar la tarjeta; registrar si abre pantalla específica, lista general,
   nada o error.
4. Volver sin conceder; verificar que no aparezca concedido.
5. Conceder y volver; comprobar estado.
6. Pulsar Administrar ya concedido; comprobar P-03.
7. Revocar desde Android y regresar; comprobar actualización.
8. Probar destino compatible/incompatible; el log «Direct file extraction»
   identifica la selección del escritor directo.
9. Inspeccionar el manifiesto final del mismo APK instalado.

Comandos de lectura opcionales desde equipo autorizado conectado al teléfono:

~~~sh
adb shell getprop ro.build.version.sdk
adb shell dumpsys package mods.sm64cdpy
adb shell appops get mods.sm64cdpy MANAGE_EXTERNAL_STORAGE
apkanalyzer manifest print /ruta/al/mismo.apk
~~~

No se ejecutaron aquí. Buscar versión, declaración y estado AppOp.
«default» o ausencia de registro no sustituye isExternalStorageManager ni prueba
por sí sola ausencia del permiso. No usar appops set para otorgarlo durante el
diagnóstico: alteraría el estado que se intenta observar.

Si no aparece en accesos especiales, investigar Android incompatible, package/APK
distinto, manifiesto final sin declaración o diferencias/fallos del fabricante.
Son hipótesis, ninguna confirmada por la observación disponible.

## 8. Propuesta pendiente y criterios de aceptación

- [ ] Identificar permiso real y alcance antes de solicitar.
- [ ] Separar consulta, solicitud y apertura de Ajustes.
- [ ] Estados loading/unknown/error/unsupported/denied/granted.
- [ ] Exponer elegibilidad del destino, sin equipararla al permiso.
- [ ] Representar errores de verificación de carpeta.
- [ ] Conservar SAF sin autorización amplia.
- [ ] Reconciliar textos/documentación e idiomas.
- [ ] Revisar engines principal y overlay.
- [ ] Pruebas de servicio/centro para errores, retorno, gestión y revocación.
- [ ] Matriz física 7–9/10/11+ según disponibilidad.

Aceptación: «Administrar» abre configuración o explica el fallo; conceder no
implica compatibilidad; errores no se etiquetan como denegaciones; revocación se
refleja al volver; usuario comprende alcance antes de salir a Ajustes.

## 9. Verificación de sincronización de estado

Quién escribe y lee:
- Usuario/Android modifican accesos especiales.
- PermissionAccessService y FastInstallAccess consultan.
- GameFolderStore guarda selección SAF; GameFolderNotifier proyecta estado.
- Instalador nativo reevalúa acceso y destino al escribir.

Fuente de verdad: Android, grants persistentes SAF y documentos reales.
No se certifica sincronización completa del overlay mediante revisión estática.

Caches: ninguno añadido. El provider de carpeta conserva proyección anterior
ante error; P-05 requiere representar su falta de verificación.

Futures no esperados: refresh del centro en init/resume y refresh independiente
de carpeta. Se conserva patrón de generación para descartar snapshots antiguos.
No se cambió código ni invalidación.

Hermanos revisados: notificaciones, batería, overlay en centro, carpeta
unificada/legacy, escritor directo/SAF y separación de auto-install.

## 10. Referencias de código

Rutas relativas a la raíz del repositorio:
- lib/presentation/screens/permissions_access_screen.dart
- lib/services/permission_access_service.dart
- lib/services/fast_install_access.dart
- lib/presentation/screens/settings_screen.dart
- lib/presentation/widgets/notification_permission_flow.dart
- lib/presentation/providers/game_folder_provider.dart
- lib/services/game_folder_service.dart
- android/app/src/main/AndroidManifest.xml
- android/app/build.gradle.kts
- android/app/src/main/kotlin/mods/sm64cdpy/ModInstallerPlugin.kt
- android/app/src/main/kotlin/mods/sm64cdpy/SafZipExtractor.kt
- android/app/src/main/kotlin/mods/sm64cdpy/DirectInstallPaths.kt
- android/app/src/main/kotlin/mods/sm64cdpy/GameFolderAccess.kt
- android/app/src/main/kotlin/mods/sm64cdpy/GameFolderStore.kt
- android/app/src/main/kotlin/mods/sm64cdpy/CoopSessionPlugin.kt
- lib/l10n/app_es.arb y app_es_419.arb
- docs/FAST_INSTALLATION.md

## 11. Fuentes oficiales consultadas

Consultadas el 2026-10-28:
- [Permisos especiales Android](https://developer.android.com/training/permissions/requesting-special):
  categoría separada, explicación previa y comprobación al reanudar.
- [Administrar todos los archivos](https://developer.android.com/training/data-storage/manage-all-files):
  declaración, solicitud, comprobación y límites.

La auditoría registra evidencia de esta fecha. Sus propuestas no son cambios
implementados ni sustituyen el backlog vigente.
