# Task Checklist Manager — Port e integraciones Linux

> Roadmap operativo para convertir SM64CDPY en una aplicación Flutter para
> Linux sin degradar el producto Android ni duplicar el proyecto.

| Campo | Valor |
|---|---|
| Proyecto | SM64CDPY — SM64CoopDX Mods Browser |
| Rama de trabajo | `linux-port` |
| Estado | Fase 0 completa; Fase 1 pendiente |
| Creado | 2026-09-28 |
| Plataforma nueva | Linux desktop x64, inicialmente |
| Base estable | Android `1.8.2+21` |
| Objetivo | MVP Linux: catálogo, descarga, instalación y biblioteca verificable |
| Estrategia | Un repositorio, dominio compartido y backends por plataforma |

## 1. Objetivo del MVP

El MVP Linux permitirá navegar el catálogo completo, buscar, marcar favoritos,
descargar e instalar contenido en una instalación de SM64CoopDX y consultar una
biblioteca local coherente. El usuario no deberá conocer XDG, rutas internas,
permisos Unix, archivos temporales ni detalles del formato de los paquetes.

El primer MVP se considerará útil cuando una persona pueda:

1. abrir SM64CDPY en Linux;
2. detectar o elegir su directorio de datos de SM64CoopDX;
3. instalar un mod o pack DynOS con progreso y cancelación;
4. cerrar y volver a abrir SM64CDPY sin perder el estado confirmado;
5. comprobar desde Biblioteca qué contenido continúa presente;
6. recibir un error comprensible si la ruta, red o paquete falla.

El port no debe convertirse en una copia separada de Android. Catálogo,
identidad, localización, selectores de estado y componentes visuales se
mantendrán compartidos. Solo se sustituirán las capacidades realmente
dependientes del sistema operativo.

## 2. Principios que no se negocian

- [x] Desarrollar en `linux-port` hasta que Android y Linux pasen sus puertas de
  calidad.
- [x] Mantener un único repositorio y una única capa de dominio.
- [ ] No colocar comprobaciones `Platform.isLinux` dispersas dentro de cada
  tarjeta o pantalla.
- [ ] Toda capacidad específica se obtiene mediante un contrato y una
  implementación por plataforma.
- [ ] Android conserva Kotlin, WorkManager, SAF y el overlay como autoridades de
  su flujo vigente.
- [ ] Linux utiliza rutas reales y un coordinador portable sin fingir que tiene
  WorkManager o SAF.
- [ ] La UI consume la misma máquina de estados conceptual en ambas plataformas.
- [ ] Una descarga terminada nunca se presenta como instalación terminada.
- [ ] La instalación se prepara fuera del destino y se publica de forma atómica.
- [ ] Ninguna operación parcial debe dejar un mod válido en apariencia.
- [ ] El filesystem confirma presencia; Hive o un recibo solo aportan metadata.
- [ ] Las funciones no disponibles se ocultan o explican; nunca quedan botones
  rotos.
- [ ] Cada fase incluye regresión Android antes de marcarse completa.

## 3. Alcance del MVP Linux

### Incluido

- Catálogo general, VIP, DynOS, Touch Controls, OMM y Render96.
- Búsqueda, filtros, paginación, favoritos, temas e idiomas existentes.
- Bases integradas y actualización remota del catálogo.
- Autodetección de la ruta de datos de SM64CoopDX.
- Selección manual de la raíz de datos y destinos.
- Descarga con progreso, error y cancelación.
- Resolución de URLs indirectas antes de descargar.
- Instalación de ZIP, 7z y archivos sueltos compatibles con el flujo vigente.
- Destino `mods` para mods normales.
- Destino `dynos/packs` para DynOS y Touch Controls.
- Biblioteca con instalados, actualizaciones, detectados y recientes cuando la
  evidencia disponible permita cada clasificación.
- Apertura de carpetas desde la aplicación.
- Build Linux reproducible en CI.
- Artefacto portable inicial para pruebas.

### Fuera del primer MVP

- Burbuja flotante equivalente a Android.
- Ejecución garantizada después de cerrar completamente la aplicación.
- Servicio systemd o daemon residente.
- Actualizador binario automático de SM64CDPY en Linux.
- Distribución simultánea en Snap, Flatpak, AppImage, Debian y RPM.
- Desinstalación física sin manifiestos completos de propiedad.
- Administración o distribución de ROM, ejecutable, claves o datos del juego.
- Soporte Windows o macOS como consecuencia accidental del port.
- Sincronización cloud de preferencias o biblioteca.

## 4. Rutas canónicas y detección

### 4.1 Directorio de datos del usuario

La raíz preferida de SM64CoopDX se resolverá de esta forma:

```text
1. Si XDG_DATA_HOME es absoluto y válido:
   $XDG_DATA_HOME/sm64coopdx

2. En caso contrario:
   $HOME/.local/share/sm64coopdx
```

Destinos derivados:

```text
mods              → <dataRoot>/mods
DynOS              → <dataRoot>/dynos/packs
Touch Controls     → <dataRoot>/dynos/packs
```

`path_provider` no decide por sí solo la ruta del juego: su directorio de
soporte pertenece a SM64CDPY, no necesariamente a SM64CoopDX. La ubicación del
juego requiere un `GameInstallationLocator` explícito.

### 4.2 Directorio junto al ejecutable

SM64CoopDX también puede leer contenido desde:

```text
<gameRoot>/mods
<gameRoot>/dynos/packs
```

Estas rutas serán una opción avanzada porque el ejecutable puede encontrarse
en un directorio de solo lectura o administrado por el sistema. Nunca se
preferirán silenciosamente sobre la ruta de datos del usuario.

### 4.3 Orden de decisión

- [ ] Leer una selección manual válida guardada previamente.
- [ ] Si no existe, evaluar la ruta XDG canónica.
- [ ] Confirmar que la raíz parece pertenecer a SM64CoopDX mediante señales
  conservadoras; no basta una carpeta vacía llamada `sm64coopdx`.
- [ ] Comprobar lectura y escritura de los destinos requeridos.
- [ ] Crear `mods` o `dynos/packs` solamente después de validar la raíz y con
  consentimiento implícito de una acción de instalación.
- [ ] Si no existe una raíz válida, permitir usar la aplicación como catálogo y
  mostrar una acción para localizarla.
- [ ] Permitir restablecer la detección automática.
- [ ] Diferenciar visualmente ruta detectada y ruta elegida.
- [ ] No guardar una ruta relativa ni una ruta que dependa del directorio desde
  el que se inició SM64CDPY.

### 4.4 Casos que deben contemplarse después del MVP

- Instalación de SM64CoopDX empaquetada como Flatpak.
- Instalación portable o compilada manualmente.
- `$HOME` no disponible o `XDG_DATA_HOME` relativo/inválido.
- Directorios montados en otra unidad.
- Symlinks legítimos dentro de la ruta elegida.
- Sistemas de archivos sensibles a mayúsculas y minúsculas.

No se codificará una ruta de Flatpak hasta validar el identificador y los
permisos reales de su paquete oficial o comunitario.

## 5. Arquitectura objetivo

```text
Pantallas / widgets
        │
        ▼
Providers y coordinadores compartidos
        │
        ▼
Contratos de dominio
  ├── InstallationBackend
  ├── OperationStore
  ├── InstallationReceiptRepository
  ├── InstallationVerifier
  ├── GameInstallationLocator
  └── PlatformCapabilities
        │
        ├── Android
        │     ├── MethodChannel
        │     ├── WorkManager
        │     ├── SAF
        │     └── recibos nativos vigentes
        │
        └── Linux
              ├── dart:io / filesystem
              ├── coordinador de operaciones
              ├── staging atómico
              └── recibos portables
```

### 5.1 Contrato común de operación

Ambos backends deben proyectar los estados ya comprendidos por la UI:

```text
requested
  → pending
  → downloading
  → installing
  → completed | failed | cancelling → cancelled
```

El contrato debe permitir:

- iniciar una descarga e instalación;
- instalar un archivo local;
- cancelar y esperar confirmación;
- observar eventos;
- consultar operaciones persistidas;
- reconciliar después de reiniciar;
- verificar destinos;
- leer recibos e historial;
- abrir o cambiar ubicaciones cuando la plataforma lo permita.

No es obligatorio que Linux fabrique UUID de WorkManager. Sí debe proporcionar
identificadores estables de operación con el mismo significado funcional.

### 5.2 Capacidades por plataforma

Un objeto único de capacidades controlará qué ofrece la interfaz:

| Capacidad | Android | Linux MVP |
|---|---:|---:|
| Catálogo y favoritos | Sí | Sí |
| Instalación automática | Sí | Sí |
| Instalación en background del SO | WorkManager | No |
| Continuar con ventana minimizada | Sí | Sí, mientras el proceso viva |
| Sobrevivir cierre completo | Sí | Recuperación/limpieza, no continuación |
| SAF | Sí | No aplica |
| Rutas XDG | No aplica | Sí |
| Overlay flotante | Sí | No |
| OTA APK | Sí | No |
| Abrir carpeta | Limitado | Sí |
| Notificación del sistema | Sí | Posterior/opcional |

La UI no debe intentar invocar capacidades marcadas como no disponibles.

### 5.3 Inicialización segura

El bootstrap actual inicializa servicios Android. Antes de compilar Linux se
debe separar:

- inicialización común: Flutter, errores, Hive, catálogo, tema y localización;
- inicialización Android: orientación móvil, OTA APK, EventChannel, bridge del
  overlay y downloader Android;
- inicialización Linux: ventana, localizador XDG, backend filesystem y
  reconciliación del diario portable.

Los imports de plugins exclusivamente Android deben aislarse mediante archivos
por plataforma o implementaciones registradas, no solo mediante una condición
de ejecución tardía.

## 6. Flujo de instalación Linux

### 6.1 Pipeline objetivo

```text
solicitud
  → resolver URL
  → crear operationId
  → descargar en cache/<operationId>/download
  → validar longitud, tipo y límites
  → extraer/copiar en staging/<operationId>/payload
  → validar manifiesto y forma del paquete
  → preparar reemplazo seguro
  → mover/publicar en destino
  → persistir recibo confirmado
  → emitir install_completed
  → limpiar temporales
```

### 6.2 Atomicidad

- [ ] Nunca extraer directamente dentro de `mods` o `dynos/packs`.
- [ ] Mantener descarga y staging aislados por `operationId`.
- [ ] Preferir que staging y destino final estén en el mismo filesystem cuando
  se necesite un `rename` atómico.
- [ ] Si hay contenido previo, preparar backup o transacción reversible antes
  del reemplazo.
- [ ] No borrar la versión anterior hasta confirmar la publicación nueva.
- [ ] Si el reemplazo falla, restaurar la versión anterior o declarar estado
  parcial explícito; nunca reportar éxito.
- [ ] Persistir el recibo solo después de confirmar el destino final.
- [ ] Limpiar backup cuando el recibo y el destino hayan quedado consistentes.

### 6.3 Cancelación

- [ ] Cambiar a `cancelling` al solicitar cancelación.
- [ ] Detener lectura de red o extracción cooperativamente.
- [ ] Esperar a que el ejecutor confirme la detención.
- [ ] Eliminar descarga, staging y backup que no sea necesario para restaurar.
- [ ] Confirmar `cancelled` únicamente al dejar el destino consistente.
- [ ] Ignorar progreso tardío perteneciente a la operación cancelada.
- [ ] Probar cancelación durante descarga, extracción, publicación y escritura
  del recibo.

### 6.4 Paralelismo

- [ ] Conservar `section + contentId + fileId` como identidad del artefacto.
- [ ] Derivar una clave única de operación independiente del título.
- [ ] Permitir operaciones distintas en paralelo.
- [ ] Serializar operaciones que escriban el mismo artefacto o ruta final.
- [ ] Evitar colisiones entre archivos que se llamen `mod.zip`.
- [ ] Probar dos mods, dos DynOS y misma URL/nombre simultáneamente.

### 6.5 Seguridad de archivos

Antes de publicar contenido se deben rechazar:

- rutas absolutas dentro de archivos comprimidos;
- componentes `..` que escapen del staging;
- symlinks o hardlinks que permitan escribir fuera del destino;
- dispositivos, sockets, FIFOs u otros archivos especiales;
- archivos truncados respecto a `Content-Length` cuando exista;
- archivos incompatibles disfrazados solo mediante extensión;
- cantidades, tamaños expandidos o relaciones de compresión fuera de límites;
- nombres que no puedan representarse de forma segura en el filesystem.

Los límites exactos se documentarán antes de habilitar instalación pública; no
se elegirán valores arbitrarios dentro de un widget.

## 7. Persistencia, recibos y Biblioteca

### Fuentes de verdad por plataforma

| Estado | Android | Linux |
|---|---|---|
| Operación activa | WorkManager | Coordinador/diario portable |
| Instalación confirmada | Recibo nativo | Recibo portable atómico |
| Presencia actual | Árbol SAF | Filesystem |
| Proyección de UI | Hive/Riverpod | Hive/Riverpod |

### Diario de operaciones Linux

- [ ] Guardar operación, identidad, fase, URL resuelta, temporales y destino.
- [ ] Escribir cambios de forma atómica.
- [ ] Al iniciar, distinguir operación activa imposible, publicación incompleta
  y limpieza pendiente.
- [ ] No reanudar una extracción desde un punto incierto.
- [ ] Reanudar una descarga solo si el cliente y servidor permiten validarla de
  forma segura; de lo contrario reiniciarla.
- [ ] Recuperar backups antes de eliminar evidencia de una transacción fallida.
- [ ] Retirar el diario solo después de alcanzar un terminal reconciliado.

### Recibos portables

- [ ] Conservar versión de esquema.
- [ ] Guardar `contentKey`, `artifactKey`, `operationKey`, sección y destino.
- [ ] Guardar versión, título y nombre solo como snapshots de presentación.
- [ ] Guardar manifiesto o huella suficiente para verificación y futura
  desinstalación segura.
- [ ] Guardar fecha, tipo de evento y procedencia.
- [ ] No guardar credenciales, tokens ni información innecesaria del usuario.
- [ ] Migrar esquemas sin invalidar silenciosamente una biblioteca completa.

### Descubrimiento

- [ ] Escanear `mods` y `dynos/packs` fuera del hilo de UI.
- [ ] Aplicar límites y cancelación a árboles grandes.
- [ ] Reconocer `main.lua`, `mod.lua` y las señales aprobadas en la fase de
  Biblioteca Android sin inferir autoría o versión inexistente.
- [ ] Vincular al catálogo solo con evidencia confiable.
- [ ] Presentar contenido no vinculado como detectado, no como instalado por
  SM64CDPY.
- [ ] No tratar `sav`, `profiles`, `assets` o archivos raíz del juego como mods.

## 8. Experiencia de escritorio

- [ ] Definir ancho mínimo de ventana razonable y diseño adaptable.
- [ ] Conservar navegación lateral sin depender de gestos móviles.
- [ ] Garantizar scroll por rueda y trackpad.
- [ ] Añadir foco visible y recorrido de teclado coherente.
- [ ] Activar acciones con Enter/Espacio y cerrar diálogos con Escape.
- [ ] Revisar menús emergentes para que no desborden la ventana.
- [ ] Usar tooltips donde un icono no sea autosuficiente.
- [ ] Permitir copiar rutas y detalles técnicos.
- [ ] Añadir “Abrir carpeta de mods”, “Abrir carpeta DynOS” y “Abrir contenido”.
- [ ] Decidir si “Abrir SM64CoopDX” requiere seleccionar un ejecutable; no
  buscar ni ejecutar binarios arbitrarios automáticamente.
- [ ] Ocultar Ajustes de burbuja, permiso de notificación Android y OTA APK.
- [ ] Sustituir textos SAF/móviles por lenguaje natural de carpetas y permisos.
- [ ] Validar escalado de texto y escalado fraccional del escritorio.

## 9. Dependencias y riesgos conocidos

La auditoría inicial debe clasificar cada paquete como:

```text
compatible Linux | reemplazable | aislable Android | bloqueante
```

Paquetes y áreas que requieren comprobación explícita:

- `floaty_chatheads`: exclusivamente Android; aislar overlay y bootstrap.
- `ota_update`: OTA de APK; no debe inicializarse en Linux.
- `flutter_file_downloader`: confirmar soporte o sustituirlo en el backend
  Linux por un cliente controlado.
- `file_picker`: validar selección de directorio en Linux.
- `path_provider`: usar para datos propios de SM64CDPY, no para asumir la ruta
  del juego.
- `shared_preferences` y `hive_flutter`: validar persistencia desktop.
- `device_info_plus`: usar solo donde aporte capacidad real.
- `share_plus`: decidir comportamiento desktop o esconder la acción.
- `url_launcher`: conservar mediante su implementación Linux.
- `jni`: investigar por qué aparece en los plugins FFI generados y evitar una
  dependencia Android accidental en el build Linux.

No se actualizarán dependencias solo para “hacer que compile” sin revisar el
impacto en Android y el lockfile.

## 10. Fases de implementación

## Fase 0 — Baseline, inventario y contratos

**Objetivo:** conocer el estado real antes de cambiar producción.

- [x] Ejecutar y registrar `flutter doctor -v` para Linux.
- [x] Ejecutar `flutter pub get` y regenerar plugins sin editar generados a mano.
- [x] Intentar build Linux inicial y clasificar todos los fallos.
- [x] Ejecutar baseline Android: análisis, tests y build de prueba.
- [x] Inventariar imports, plugins y servicios Android-only.
- [x] Inventariar todas las llamadas directas a `ModInstaller` y
  `BackgroundInstallService`.
- [x] Inventariar lectores/escritores de ajustes de carpetas, recibos e Hive.
- [x] Documentar el contrato de capacidades y backend.
- [x] Crear tests de contrato que puedan ejecutarse con un backend falso.
- [x] Decidir directorio privado de SM64CDPY para cache, diario y recibos.
- [x] Registrar riesgos y decisiones sin implementar aún instalación real.

**Criterios de salida:**

- El fallo inicial de Linux está reproducido y explicado.
- Android conserva un baseline verde.
- Existe un mapa completo de superficies que dependen de plataforma.
- Los contratos no mencionan WorkManager o SAF como conceptos universales.

## Fase 1 — Shell Linux y catálogo de solo lectura

**Objetivo:** abrir una aplicación Linux estable sin ofrecer acciones falsas.

- [ ] Separar bootstrap común, Android y Linux.
- [ ] Evitar imports/registro de overlay y OTA APK en Linux.
- [ ] Registrar backend Linux temporal de solo lectura/no disponible.
- [ ] Abrir Home, Catálogo, Favoritos y detalles.
- [ ] Validar carga local y remota de bases.
- [ ] Adaptar navegación, ventana y scroll básicos.
- [ ] Ocultar o deshabilitar acciones de instalación con explicación clara hasta
  la fase correspondiente.
- [ ] Confirmar que el cambio no modifica el bootstrap Android.

**Criterios de salida:** `flutter run -d linux` permite recorrer el catálogo sin
`MissingPluginException`, botones muertos ni errores continuos en consola.

## Fase 2 — Localizador de SM64CoopDX y Ajustes

**Objetivo:** resolver destinos Linux de forma automática y reversible.

- [ ] Implementar resolución XDG y fallback de HOME.
- [ ] Validar raíz, destinos y permisos.
- [ ] Añadir selección manual con picker compatible.
- [ ] Persistir override independiente de Android.
- [ ] Añadir restablecimiento a detección automática.
- [ ] Mostrar rutas efectivas y su origen en Ajustes.
- [ ] Implementar apertura de carpetas.
- [ ] Añadir estados: detectada, elegida, ausente, solo lectura e inválida.
- [ ] Probar rutas con espacios, Unicode y symlinks controlados.

**Criterios de salida:** en una instalación típica se detectan `mods` y
`dynos/packs`; si no existe, el usuario puede seleccionar una raíz sin romper el
catálogo.

## Fase 3 — Backend común y preservación de Android

**Objetivo:** desacoplar la UI antes de instalar archivos en Linux.

- [ ] Introducir contratos y selector de implementación por plataforma.
- [ ] Encapsular el MethodChannel vigente como backend Android.
- [ ] Adaptar coordinador y providers a los contratos.
- [ ] Conservar eventos, metadata e identidad canónica.
- [ ] Mantener reconciliación WorkManager intacta en Android.
- [ ] Conectar backend falso Linux para ejercitar estados.
- [ ] Revisar catálogo, detalle, VIP, DynOS, Touch Controls, OMM, Render96,
  Biblioteca y Home.
- [ ] Revisar overlay como consumidor Android, no como dependencia común.

**Criterios de salida:** pruebas Android existentes continúan pasando y tests
de contrato demuestran que la UI puede consumir un backend no Android.

## Fase 4 — Descarga Linux

**Objetivo:** descargar de forma observable y cancelable sin instalar aún.

- [ ] Reutilizar `DownloadUrlResolver` compartido.
- [ ] Implementar temporales aislados por operación.
- [ ] Emitir pending, progreso, completado de descarga, error y cancelación.
- [ ] Validar redirects, 4xx permanentes, reintentos acotados y truncamiento.
- [ ] Limitar concurrencia.
- [ ] Persistir diario mínimo para recuperación.
- [ ] Limpiar temporales terminales.
- [ ] Mantener auto-install desactivado como archivo descargado con acción
  posterior coherente.

**Criterios de salida:** descargar, cancelar y fallar no bloquea UI ni deja
estados activos falsos después de reiniciar.

## Fase 5 — Instalación transaccional Linux

**Objetivo:** publicar contenido completo en los destinos correctos.

- [ ] Implementar inspección segura de ZIP.
- [ ] Implementar 7z con una dependencia auditada o declarar temporalmente la
  limitación si no existe opción segura.
- [ ] Admitir archivos sueltos compatibles.
- [ ] Extraer en staging y generar manifiesto.
- [ ] Validar traversal, links, especiales y límites.
- [ ] Implementar publicación/reemplazo reversible.
- [ ] Guardar recibo atómico.
- [ ] Emitir progreso de instalación y resultado terminal.
- [ ] Implementar cancelación y rollback.
- [ ] Instalar correctamente en `mods` y `dynos/packs`.

**Criterios de salida:** éxito, fallo y cancelación dejan filesystem y recibos
coherentes; jamás se muestra éxito solo por terminar la descarga.

## Fase 6 — Biblioteca y reconciliación Linux

**Objetivo:** representar lo que realmente existe después de reiniciar.

- [ ] Implementar repositorio de recibos Linux.
- [ ] Verificar manifiestos contra filesystem.
- [ ] Reconciliar diario y transacciones incompletas al arrancar.
- [ ] Proyectar datos en Hive/Riverpod.
- [ ] Implementar descubrimiento conservador de contenido externo.
- [ ] Conectar estados de acciones al selector canónico.
- [ ] Validar instalados, actualizaciones, detectados y recientes.
- [ ] Mantener “Olvidar instalación” separado de borrar archivos.
- [ ] No habilitar desinstalación física sin propiedad completa.

**Criterios de salida:** Biblioteca refleja borrado manual, cambio de versión,
contenido externo y rutas inaccesibles sin inventar resultados.

## Fase 7 — Integración y pulido desktop

**Objetivo:** convertir el port funcional en una aplicación cómoda de Linux.

- [ ] Auditoría completa de teclado y foco.
- [ ] Auditoría de mouse, rueda y trackpad.
- [ ] Auditoría de ventana estrecha, amplia y maximizada.
- [ ] Revisar diálogos, menús y feedback global.
- [ ] Añadir apertura segura de rutas.
- [ ] Evaluar notificaciones Freedesktop sin hacerlas requisito del MVP.
- [ ] Añadir icono, nombre de aplicación y metadatos `.desktop`.
- [ ] Definir comportamiento al cerrar con operaciones activas.
- [ ] Mostrar confirmación si cerrar interrumpirá una operación.

**Criterios de salida:** ninguna acción principal depende de un gesto móvil y
la aplicación comunica claramente las limitaciones de segundo plano.

## Fase 8 — CI, artefacto y pruebas de distribución

**Objetivo:** producir builds reproducibles sin mezclar releases Android.

- [ ] Crear workflow Linux independiente.
- [ ] Ejecutar format, analyze, tests y build Linux.
- [ ] Mantener workflow Android como puerta obligatoria de regresión.
- [ ] Publicar artefacto de testing, no release estable, durante la rama.
- [ ] Inspeccionar dependencias dinámicas con `ldd`.
- [ ] Probar bundle limpio en una máquina o contenedor compatible.
- [ ] Definir checksum y nomenclatura del artefacto.
- [ ] Elegir primer empaquetado: bundle `.tar.gz` o AppImage tras prueba.
- [ ] Documentar instalación, ejecución y rutas.

**Criterios de salida:** un usuario de prueba puede descargar el artefacto,
abrirlo y completar el flujo sin instalar el SDK de Flutter.

## Fase 9 — Candidato MVP y fusión

**Objetivo:** demostrar que Linux está listo y Android no retrocedió.

- [ ] Ejecutar matriz manual Linux completa.
- [ ] Ejecutar matriz Android afectada completa.
- [ ] Resolver diferencias de tema, localización y navegación.
- [ ] Actualizar `README.md`, `README_ES.md`, `README_PT.md`, arquitectura,
  CI/CD y estado del proyecto.
- [ ] Documentar funciones no disponibles en Linux.
- [ ] Preparar notas de versión sin prometer background persistente.
- [ ] Incorporar cambios recientes de `main` en `linux-port`.
- [ ] Revisar diff final y cambios de dependencias.
- [ ] Fusionar solo con CI Android + Linux verde y aprobación explícita.

## 11. Matriz de pruebas manuales Linux

### Rutas y permisos

- [ ] XDG configurado y ruta existente.
- [ ] XDG ausente y fallback en HOME.
- [ ] Raíz inexistente.
- [ ] Selección manual válida.
- [ ] Ruta con espacios y caracteres Unicode.
- [ ] Directorio de solo lectura.
- [ ] Ruta eliminada mientras la app está abierta.
- [ ] Restablecer detección automática.

### Descarga e instalación

- [ ] Auto-install activado y desactivado.
- [ ] Mods y DynOS/Touch Controls.
- [ ] ZIP, 7z y archivo suelto.
- [ ] 404, pérdida de red y recuperación.
- [ ] Archivo truncado o corrupto.
- [ ] Cancelar durante descarga.
- [ ] Cancelar durante extracción.
- [ ] Cerrar ventana durante una operación.
- [ ] Dos operaciones paralelas.
- [ ] Dos archivos con el mismo nombre.
- [ ] Reinstalar y actualizar contenido existente.

### Persistencia y Biblioteca

- [ ] Reiniciar después de éxito.
- [ ] Reiniciar después de cancelación.
- [ ] Reiniciar tras cierre inesperado durante staging.
- [ ] Borrar manualmente un mod y verificar.
- [ ] Instalar contenido fuera de SM64CDPY y detectar.
- [ ] Cambiar la raíz y reconciliar.
- [ ] Recibo corrupto o de esquema futuro.
- [ ] Árbol con muchos archivos sin congelar UI.

### Escritorio y accesibilidad

- [ ] Navegación completa solo con teclado.
- [ ] Foco visible.
- [ ] Texto ampliado.
- [ ] Tema claro y oscuro.
- [ ] Ventana mínima y maximizada.
- [ ] Escalado fraccional.
- [ ] Abrir carpetas y copiar detalles.

## 12. Regresión Android obligatoria por fase

- [ ] Arranque y navegación principal.
- [ ] Selección y limpieza de carpetas SAF.
- [ ] Auto-install on/off.
- [ ] Descarga e instalación con WorkManager.
- [ ] Cancelación durante descarga e instalación.
- [ ] Reconciliación después de cerrar/reabrir.
- [ ] Biblioteca, detectados, recientes y actualizaciones.
- [ ] DynOS y Touch Controls en destino compartido.
- [ ] Overlay: descarga, progreso, cancelación y final.
- [ ] OTA APK y selector ABI.
- [ ] Notificaciones Android permitidas y denegadas.

Un build Linux exitoso no compensa una regresión Android.

## 13. CI y estrategia Git

### Rama

- `main`: producto estable publicado.
- `linux-port`: integración progresiva del port.
- Ramas auxiliares, si hacen falta: `linux-port/<fase-o-tema>` y PR contra
  `linux-port`.

### Sincronización

- [ ] Traer periódicamente `main` a `linux-port` mediante merge explícito.
- [ ] Resolver cambios compartidos en la rama del port, no detener correcciones
  Android en `main`.
- [ ] Evitar cherry-picks duplicados de la misma corrección.
- [ ] No publicar releases Linux desde commits no fusionados salvo artefactos de
  testing claramente etiquetados.

### Puertas automáticas deseadas

```text
Común:
  dart format --output=none --set-exit-if-changed
  flutter analyze lib
  flutter test
  git diff --check

Android:
  workflow de testing vigente
  compilación APK arm64

Linux:
  flutter build linux --release
  tests de contratos/filesystem
  inspección del bundle
```

## 14. Riesgos principales y mitigación

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Plugins Android impiden compilar Linux | Alto | Imports/bootstraps por plataforma y matriz de capacidades |
| Refactor rompe WorkManager | Alto | Backend Android adaptador, tests y regresión por fase |
| Extracción escribe fuera del destino | Crítico | Staging, sanitización, rechazo de links/especiales y fixtures hostiles |
| Cancelación deja archivos parciales | Alto | Publicación atómica, journal y rollback |
| Ruta XDG incorrecta | Medio | Resolver estándar, validación y override manual |
| Cierre de app corta operaciones | Medio | Mensaje claro, confirmación y reconciliación; daemon fuera del MVP |
| Recibos Android y Linux divergen | Alto | Esquema/entidades compartidas y repositorios por plataforma |
| Biblioteca congela la UI | Medio | I/O fuera del hilo UI, límites, lotes y cancelación |
| Empaquetado no funciona entre distros | Medio | Bundle de testing, `ldd` y una distribución inicial acotada |
| Flatpak bloquea acceso | Medio | Tratarlo como fase posterior con permisos explícitos |

## 15. Decisiones pendientes

- [ ] Biblioteca ZIP elegida y estrategia 7z para Linux.
- [ ] Ubicación exacta del diario y recibos privados de SM64CDPY.
- [ ] Política de límites de archivo comprimido.
- [ ] Comportamiento de cierre con operaciones activas.
- [ ] Formato inicial de distribución.
- [ ] Soporte mínimo de Ubuntu/glibc y arquitectura de CPU.
- [ ] Si la versión Linux comparte numeración con Android o añade metadata de
  plataforma conservando una versión de producto común.
- [ ] Si el lanzamiento del juego entra en MVP o en una fase posterior.
- [ ] Política de actualización del propio binario Linux.

Cada decisión debe registrar motivo, alternativas y consecuencias. No se marca
una fase completa dejando una decisión necesaria implícita.

## 16. Definición de terminado del MVP

El MVP Linux estará terminado cuando:

- compile desde un checkout limpio;
- catálogo, favoritos, temas e idiomas funcionen;
- detecte o permita elegir una instalación de SM64CoopDX;
- instale mods y DynOS en sus destinos correctos;
- éxito, error y cancelación terminen sin estados falsos;
- una operación parcial no deje contenido publicado como completo;
- Biblioteca se reconcilie con el filesystem después de reiniciar;
- no invoque overlay, SAF, WorkManager u OTA APK en Linux;
- Android mantenga sus flujos y pruebas vigentes;
- exista un artefacto portable probado fuera del entorno de desarrollo;
- documentación y limitaciones sean públicas y precisas;
- todas las pruebas físicas pendientes estén registradas.

## 17. Registro de avance

| Fecha | Fase | Resultado | Evidencia / pendiente |
|---|---|---|---|
| 2026-09-28 | Preparación | Rama `linux-port` y roadmap creados | Fase 0 autorizada |
| 2026-09-28 | Fase 0 | Baseline, inventario, contratos y pruebas completados | Runtime Linux confirma canales Android ausentes; Fase 1 debe separar bootstrap |

Al completar cada fase se añadirá una entrada. Los checkboxes se actualizan con
evidencia real; compilar no equivale a haber realizado pruebas físicas.
