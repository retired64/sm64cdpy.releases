# Task Checklist Manager — Biblioteca e historial de instalaciones

> Roadmap aislado para diseñar e implementar una biblioteca local verificable
> sin comprometer la estabilidad de `main`.

| Campo | Valor |
|---|---|
| Proyecto | SM64CDPY — SM64CoopDX Mods Browser |
| Rama de trabajo | `historial-hive` |
| Estado | Fase 9 implementada; pendiente validación física |
| Creado | 2026-09-23 |
| Plataforma | Android 7.0+ |
| Alcance | Biblioteca, historial, detección de versión y verificación SAF |
| Fuera de alcance inicial | Sincronización cloud y desinstalación automática |

## Objetivo del producto

Convertir el catálogo en una biblioteca local comprensible. Después de una
instalación confirmada, el usuario debe poder saber qué contenido instaló, qué
versión conserva, si los archivos todavía existen, si hay una actualización y
qué acción es segura a continuación.

El sistema no debe confundir estos conceptos:

- una descarga terminada no equivale a una instalación;
- un Worker encolado no equivale a una instalación;
- un registro histórico no demuestra que los archivos continúen presentes;
- una coincidencia aproximada por nombre no identifica con certeza un mod;
- DynOS y Touch Controls comparten carpeta, pero conservan su tipo de catálogo;
- Hive puede acelerar la interfaz, pero no puede depender de un engine Flutter
  vivo cuando un Worker nativo termina en segundo plano.

## Resultado esperado

- Una sección **Biblioteca** accesible desde el drawer.
- Un resumen opcional de hasta tres instalaciones recientes en Home.
- Botones coherentes: Descargar, Instalando, Instalado, Actualizar, Verificar,
  Reinstalar o Seleccionar carpeta, según el estado real.
- Historial local de instalaciones, actualizaciones y reinstalaciones exitosas.
- Verificación contra las carpetas SAF seleccionadas.
- Recuperación después de cerrar la aplicación o matar el proceso.
- Estado coherente en catálogo, detalle, secciones exclusivas y overlay.
- Detección conservadora de contenido que existía antes de esta función.

## Decisiones de arquitectura resueltas antes de programar

- [x] Documentar formalmente las tres fuentes de estado:
  - WorkManager como autoridad de operaciones activas.
  - Recibo durable como evidencia de una instalación confirmada.
  - SAF como autoridad sobre la presencia actual de archivos.
- [x] Decidir el almacén canónico de recibos que Kotlin pueda escribir aunque
  Flutter esté cerrado.
  - Opción recomendada inicial: un recibo JSON atómico por artefacto dentro del
    almacenamiento privado de la aplicación.
  - Evaluar Room solamente si aparecen consultas o migraciones que justifiquen
    su coste adicional.
- [x] Definir si Hive se usará como proyección/cache de la Biblioteca o solo
  para el historial enriquecido de Flutter.
- [x] Prohibir que Hive sea la única evidencia de instalación.
- [x] Definir versión de esquema, migraciones y recuperación ante un recibo
  corrupto o perteneciente a una versión futura de la aplicación.
- [x] Definir política de retención del historial y una acción explícita para
  limpiarlo sin borrar archivos del juego.

## Modelo de identidad

- [x] Definir `contentKey = section + contentId` para el contenido lógico.
- [x] Mantener `artifactKey = section + contentId + fileId` para el archivo o
  variante concreta instalada.
- [x] Mantener la misma identidad de artefacto en la operación WorkManager.
- [x] No usar título, URL o nombre de ZIP como identidad principal.
- [x] Definir cómo representar una versión cuando el catálogo usa `N/A`, texto
  libre o formatos no semánticos.
- [x] Definir si dos artefactos del mismo contenido pueden coexistir.
- [x] Definir cuándo una instalación nueva reemplaza, actualiza o se añade a
  una instalación anterior.

## Contrato propuesto del recibo

- [x] Versionar el esquema del recibo.
- [x] Guardar `contentKey`, `artifactKey` y `operationKey`.
- [x] Guardar sección, ID del catálogo e ID del archivo seleccionado.
- [x] Guardar título, versión y nombre del artefacto como snapshots de
  presentación, no como identidad.
- [x] Guardar destino lógico: `mods` o `dynos`.
- [x] Guardar fecha de instalación y UUID del Worker que confirmó el resultado.
- [x] Guardar tipo de evento: instalación, actualización o reinstalación.
- [x] Guardar cantidad de archivos y forma del paquete detectada.
- [x] Guardar una huella compacta de rutas centinela para verificación.
- [x] Guardar procedencia: instalada por SM64CDPY o detectada externamente.
- [x] No guardar tokens, URLs privadas ni la URI SAF completa en datos
  exportables o visibles.

## Fase 0 — Investigación y fixtures

- [x] Crear muestras representativas, originales y legales de ZIP, 7z y
  archivos sueltos sin redistribuir mods de terceros.
- [x] Registrar para cada muestra las rutas antes y después de extraer.
- [x] Comprobar paquetes con una carpeta superior común.
- [x] Comprobar paquetes con varios archivos en la raíz.
- [x] Comprobar paquetes que contienen más de un mod.
- [x] Comprobar un mod Lua con `main.lua` y otro con `mod.lua`.
- [x] Comprobar un archivo `.lua`/`.luac` suelto.
- [x] Comprobar por código y catálogo DynOS, Touch Controls, OMM DynOS y
  Render96; la instalación física queda en la matriz manual posterior.
- [x] Identificar nombres duplicados, versiones ausentes y títulos que no
  coinciden con sus rutas.
- [x] Conservar fixtures pequeños y legales para pruebas automatizadas.

Evidencia y contratos: [Installed Library — Phase 0](INSTALLED-LIBRARY-PHASE-0.md).

**Motivo:** no se puede diseñar una huella verificable usando únicamente el
título o suponiendo que todos los archivos comprimidos producen una carpeta.

## Fase 1 — Propagar identidad y metadata de extremo a extremo

- [x] Extender la solicitud Flutter con sección, `contentId`, `fileId`, versión
  y destino sin romper operaciones persistidas de versiones anteriores.
- [x] Actualizar `BackgroundInstallService` y su serialización temporal.
- [x] Actualizar MethodChannel y datos de entrada de ambos Workers.
- [x] Preservar metadata durante todos los eventos de progreso.
- [x] Actualizar `OverlayBridge` y mensajes de `floaty_chatheads`.
- [x] Alinear las claves generadas por app principal y overlay.
- [x] Mantener compatibilidad de lectura con operaciones antiguas incompletas.
- [x] Añadir pruebas de colisión para mismo título y distinto contenido.

**Motivo:** el recibo solo será fiable si el Worker conoce la identidad real del
catálogo antes de comenzar, no si intenta reconstruirla después desde el título.

## Fase 2 — Manifiesto de escritura e instalación confirmada

- [x] Cambiar el resultado interno de extracción para obtener conteo y huella
  verificable, sin duplicar `SafZipExtractor`.
- [x] Definir centinelas para archivo suelto, carpeta única y múltiples raíces.
- [x] Limitar el tamaño de la huella para archivos con miles de entradas.
- [x] Escribir el recibo solamente después de completar todas las escrituras.
- [x] Usar escritura atómica: temporal, flush y reemplazo final.
- [x] No crear recibo en descarga completa sin instalación.
- [x] No crear recibo en fallo, cancelación o permiso SAF revocado.
- [x] Evitar carreras entre dos Workers paralelos.
- [x] Reconciliar un Worker `SUCCEEDED` cuyo evento no fue recibido por Flutter.
- [x] Definir tratamiento de éxito nativo con fallo posterior al guardar recibo.

**Motivo:** `install_completed` debe dejar evidencia aun cuando ambos engines
Flutter estén cerrados.

**Implementación:** `SafZipExtractor` devuelve un manifiesto acotado después
de cada escritura SAF confirmada. `ModInstallWorker` persiste el recibo nativo
antes de devolver `SUCCEEDED`; por ello la evidencia sobrevive aunque ningún
engine reciba el evento. El archivo se reemplaza con `AtomicFile`, `flush` y
`fsync`, bajo bloqueo de proceso. Una cancelación posterior restaura el recibo
anterior si el archivo aún pertenece al mismo Worker. Si los archivos se
copiaron pero el recibo falla, el Worker devuelve `FAILED`, no muestra la
notificación final y permite una reinstalación explícita. Las rutas síncronas
legacy sin identidad canónica continúan funcionando, pero deliberadamente no
fabrican recibos por título.

`eventKind` usa `reinstall` cuando ya existía el mismo `artifactKey` e
`install` para un artefacto distinto. `update` queda reservado para una fase
posterior que pueda demostrar la intención y comparar versiones sin confundir
la instalación voluntaria de una versión antigua con una actualización.

## Fase 3 — Repositorio de Biblioteca y proyección Hive

- [x] Crear un repositorio de dominio independiente de widgets y tarjetas.
- [x] Leer y validar recibos nativos al iniciar.
- [x] Diseñar una caja Hive separada y versionada si se confirma que aporta una
  mejora de arranque, ordenación o historial.
- [x] Hacer idempotente la importación de recibos mediante `artifactKey` y UUID.
- [x] Exponer estados con Riverpod: cargando, listo, parcial y error.
- [x] Ordenar eventos por fecha sin depender del orden físico del almacén.
- [x] Invalidar la proyección al instalar, actualizar, reinstalar, verificar,
  cambiar carpeta o recuperar permisos.
- [x] Manejar recibos corruptos sin impedir abrir la Biblioteca.
- [x] Definir limpieza y límite razonable del historial.
- [x] Añadir migraciones y pruebas de versiones de esquema.

**Motivo:** Hive es útil como proyección Flutter, pero el sistema no debe perder
una instalación terminada mientras Dart no estaba ejecutándose.

**Implementación:** Kotlin valida cada recibo, aísla archivos corruptos o de
esquema desconocido y devuelve los elementos sanos junto con incidencias. El
historial nativo conserva como máximo 500 eventos y puede limpiarse sin borrar
recibos ni archivos del juego. El repositorio de dominio reconstruye una caja
Hive exclusiva y versionada desde esa fuente nativa: deduplica recibos por
`artifactKey`, eventos por UUID del Worker y ordena por fecha UTC. Riverpod
expone `AsyncLoading`/`AsyncError` y datos `ready` o `partial`. La proyección se
sincroniza al arrancar, después de `install_completed` y al cambiar/limpiar una
carpeta; además existe una invalidación pública para el verificador de Fase 4.

## Fase 4 — Verificación SAF

- [x] Añadir una operación nativa de verificación por destino y centinelas.
- [x] Diferenciar `present`, `missing`, `unknown`, `folderNotSelected` y
  `permissionRevoked`.
- [x] No recorrer recursivamente ambas carpetas en cada render de tarjeta.
- [x] Hacer verificación rápida al abrir Biblioteca y bajo demanda por elemento.
- [x] Marcar como no verificados los registros al cambiar la URI de destino.
- [x] Mantener historial al limpiar una selección de carpeta.
- [x] Volver a verificar después de recuperar el permiso.
- [x] Definir una actualización controlada de toda la Biblioteca.
- [x] Limitar concurrencia y trabajo de I/O para evitar congelamientos.
- [ ] Probar proveedores SAF lentos y árboles grandes.

**Motivo:** el recibo explica qué ocurrió; SAF confirma qué sigue existiendo.

**Implementación:** Kotlin verifica únicamente las rutas centinela exactas de
cada recibo, sin recorrer recursivamente el árbol. Las verificaciones se
serializan, reutilizan directorios ya resueltos durante el lote y se ejecutan
fuera del hilo principal. El resultado distingue presencia, archivo ausente,
estado desconocido, carpeta no seleccionada y permiso revocado. Flutter conserva esos resultados en la
proyección Hive v2, permite refrescar todo el conjunto o un solo `artifactKey`
y descarta la proyección anterior al cambiar o limpiar una carpeta. Recibos e
historial no se eliminan por perder acceso SAF. La aceptación con proveedores
reales y árboles grandes sigue pendiente en dispositivo físico.

## Fase 5 — Selector canónico de estado y acciones

- [x] Crear un selector compartido que combine operación, recibo, verificación
  y versión del catálogo.
- [x] Mostrar Descargar cuando no exista instalación conocida.
- [x] Mostrar progreso y Cancelar durante una operación activa.
- [x] Mostrar Instalado únicamente con estado confirmado y verificable.
- [x] Mostrar Actualizar cuando la versión canónica sea distinta y la
  comparación sea confiable.
- [x] Mostrar Reinstalar cuando falten archivos registrados.
- [x] Mostrar Verificar cuando el estado sea desconocido.
- [x] Mostrar Seleccionar carpeta cuando falte acceso SAF.
- [x] Ofrecer Reinstalar como acción secundaria de un elemento instalado.
- [x] No afirmar que una versión es antigua si su formato no puede compararse.
- [x] Aplicar el selector a catálogo/detalle, VIP, DynOS, Touch Controls, OMM y
  Render96 en el engine principal.
- [x] Consumir el selector en overlay mediante snapshot entre engines (Fase 7).

**Motivo:** ninguna tarjeta debe inventar su propio criterio de “instalado”.

**Implementación:** `InstallationActionSelector` aplica precedencia estable:
operación WorkManager activa, recibo durable, verificación SAF y por último
comparación conservadora de versión. Solo versiones numéricas de hasta cuatro
componentes pueden producir `Actualizar`; texto libre, prereleases ambiguos o
versiones ausentes nunca se declaran antiguas. Riverpod combina las fuentes por
`InstallIdentity` y todas las superficies de descarga del engine principal
consumen la misma acción y ejecutor. Los archivos múltiples de detalle usan su
`fileKey` explícito para no compartir `artifactKey`. El overlay requiere un
snapshot cruzando engines y queda deliberadamente en la Fase 7.

## Fase 6 — Pantalla Biblioteca y Home

- [x] Añadir ruta y entrada **Biblioteca** cerca de Favoritos en el drawer.
- [x] Diseñar estados vacío, cargando, error y permiso revocado.
- [x] Añadir vistas Instalados, Actualizaciones, Detectados y Recientes.
- [x] Permitir filtrar por sección y destino.
- [x] Mostrar versión instalada, fecha, verificación y acción disponible.
- [x] Añadir hasta tres instalaciones recientes en Home.
- [x] Ocultar el bloque de Home cuando no haya historial.
- [x] Permitir “Ver todo” sin duplicar listas completas en Home.
- [x] Mantener el diseño usable en pantallas pequeñas y con texto ampliado.
- [x] Añadir todas las cadenas a EN, ES, ES-419, PT y PT-BR.

**Motivo:** Biblioteca es una función permanente; Home solo debe ofrecer un
resumen compacto y no convertirse en una lista interminable.

**Implementado (2026-09-26):** la ruta `/library` consume directamente la
proyección reconciliada de recibos nativos y verificación SAF. Incluye estados
de carga, error, proyección parcial, carpeta ausente, permiso revocado y listas
vacías; filtros por sección/destino; navegación a la superficie de origen; y
verificación puntual sin convertir la tarjeta en fuente de verdad. Home muestra
como máximo tres eventos del historial y enlaza a la vista Recientes.

Las vistas Actualizaciones y Detectados existen con estados vacíos explícitos.
Actualizaciones no compara etiquetas no numéricas ni inventa candidatos fuera
del selector canónico de la Fase 5; Detectados no infiere instalaciones por el
nombre de una carpeta y se poblará únicamente con el escaneo confiable de la
Fase 8. Esta separación evita falsos positivos mientras deja estable el flujo
visual de Biblioteca.

**Prueba física completada (OPPO CPH2365, 2026-09-26):** acceso desde el drawer,
vista Instalados y vista Recientes confirmados con un recibo real. Durante la
prueba se detectó que “Abrir contenido” reemplazaba la ruta de Biblioteca al
usar `go` hacia un detalle que vive fuera del shell. El detalle general ahora
se apila con `push`, por lo que Atrás recupera Biblioteca y su drawer. Una
captura ADB posterior no registró `FATAL EXCEPTION`; el cierre previo no quedó
en el búfer de crashes. Al volver se confirmó otra inconsistencia: Biblioteca
tenía un `Scaffold` anidado que interceptaba `DrawerMenuButton` sin poseer un
drawer. Se sustituyó por `CustomScrollView` + `SliverAppBar`, usando directamente
el `Scaffold` canónico de `AppShell`, como Catálogo y las demás rutas hermanas.
La prueba de borrado físico y actualización también pasó: SAF proyectó
“No encontrado” y la acción “Reinstalar”. El APK final también confirmó el
drawer dentro de Biblioteca, la apertura del contenido y el regreso correcto a
la pantalla. Con ello queda cerrado el flujo crítico de navegación y
reconciliación de la Fase 6; la matriz ampliada de permisos y accesibilidad se
mantiene como regresión general previa al release.

## Fase 7 — Sincronización con el overlay

- [x] Enviar snapshot de instalaciones relevantes cuando se abra el panel.
- [x] Enviar cambios después de instalar, verificar o detectar actualización.
- [x] No leer Hive desde el segundo engine como si compartiera memoria.
- [x] Mostrar estado instalado/actualización usando la misma `artifactKey`.
- [x] Resolver el caso en que el overlay se abre antes de cargar la proyección.
- [x] Evitar duplicar toasts o resultados terminales entre engines.
- [x] Probar cierre y reapertura del panel durante una reconciliación.

**Motivo:** app y burbuja deben presentar la misma verdad aunque tengan engines
e isolates independientes.

**Implementado (2026-09-26):** `OverlayBridge` solicita una verificación SAF al
abrir el panel y envía un snapshot compacto y versionado por
`FloatyChatheads.shareData`. El segundo engine conserva esa proyección solo en
memoria, descarta respuestas antiguas mediante `requestId` y ejecuta el mismo
`InstallationActionSelector` usado por la app principal. Mientras llega la
primera proyección muestra Comprobando, sin inferir que el contenido falta.

El bridge vuelve a publicar después de instalación confirmada, verificación
puntual, refrescos del repositorio y cambios de carpeta. Los resultados
terminales continúan siendo responsabilidad del coordinador global y las
notificaciones nativas; el snapshot no genera un segundo toast. También se
alineó el `fileKey` explícito del catálogo general, incluidas versiones con
varios archivos, para que detalle y overlay produzcan la misma `artifactKey`.

**Prueba física completada (2026-09-26):** se aprobaron los diez escenarios de
sincronización: instalado previo, mod multiversión, instalación desde overlay,
reflejo en Biblioteca, operación iniciada desde la app, cierre/reapertura con
trabajo activo, reapertura durante Comprobando, borrado físico con Reinstalar,
carpeta ausente con Seleccionar carpeta y ausencia de feedback terminal
duplicado. Con esta matriz la Fase 7 queda oficialmente cerrada.

## Fase 8 — Descubrimiento de instalaciones antiguas o externas

- [x] Adaptar de manera nativa la lectura limitada de encabezados Lua.
- [x] Buscar `main.lua`, después `mod.lua`, y archivos Lua raíz.
- [x] Extraer nombre, versión, categoría y autor solo cuando existan.
- [x] Limpiar códigos de color sin modificar los archivos del usuario.
- [x] Tratar DynOS y Touch Controls como tipos no inferibles solo por carpeta.
- [x] Definir niveles de confianza: exacto, probable y sin vincular.
- [x] No cambiar un botón del catálogo por una coincidencia ambigua.
- [x] Presentar elementos ambiguos como “Detectado en el dispositivo”.
- [x] Permitir vinculación manual futura sin hacerla requisito de la primera
  versión.
- [x] Ejecutar el escaneo al migrar, cambiar carpeta o por acción del usuario;
  nunca en cada reconstrucción de UI.

**Motivo:** la lógica del script Python ayuda a descubrir contenido, pero no
demuestra por sí sola qué entrada del catálogo lo originó.

**Implementado (2026-09-26):** `InstallationDiscoveryScanner` recorre los
árboles SAF fuera del hilo principal con topes de 4,000 documentos, 500
hallazgos, tres niveles de profundidad y 64 KiB leídos por encabezado. Prioriza
`main.lua`, luego `mod.lua` y finalmente Lua/Luac sueltos. Replica el contrato
de encabezados iniciales de SM64CoopDX, elimina códigos de color solo en la
proyección y extrae metadata opcional sin modificar archivos.

Los hallazgos se guardan en una caché nativa privada distinta de los recibos y
se importan a Hive v3 como proyección reconstruible. Las rutas centinela que ya
pertenecen a un recibo SM64CDPY se excluyen para no duplicar Instalados y
Detectados. `exacto` significa exclusivamente “marcador `main.lua`/`mod.lua`
con nombre explícito en su encabezado”; no significa coincidencia exacta con el
catálogo. `probable` conserva un marcador sin nombre y `sin vincular` representa
Lua suelto. Ninguno genera `contentKey`, `artifactKey`, recibo ni cambia botones
del catálogo. En la carpeta compartida DynOS/Touch Controls solo se conserva el
destino `dynos`; el tipo no se adivina.

El primer acceso a Biblioteca valida la caché por carpeta/permiso; cambiar o
limpiar una carpeta vuelve a descubrir y la acción Actualizar fuerza un nuevo
escaneo. Home solo consume la proyección existente y no recorre SAF durante el
arranque. Verificación y descubrimiento comparten un coordinador nativo de I/O,
y el escaneo se difiere si WorkManager está escribiendo una instalación para
no clasificar archivos parciales como externos. El límite alcanzado se comunica
en la UI.

**Validación física completada (2026-09-27):** la matriz de aceptación de la
fase pasó en dispositivo real. Se comprobó la detección de carpetas externas
con `main.lua`, la lectura de nombre/versión/autor/categoría, la limpieza visual
de códigos de color, el tratamiento conservador de Lua suelto, la ausencia de
duplicados entre Instalados y Detectados, el alta y baja mediante actualización
manual, el destino compartido DynOS sin inferir Touch Controls, la limpieza o
revocación de carpeta sin fallos, la exclusión de archivos parciales durante
una instalación activa y el comportamiento acotado ante árboles grandes. La
fase 8 queda cerrada sin convertir ningún hallazgo externo en recibo o identidad
de catálogo.

## Fase 9 — Actualizaciones, reinstalación y mantenimiento

- [x] Comparar versión instalada con la versión canónica del catálogo.
- [x] Usar coincidencia exacta como fallback cuando no exista SemVer válido.
- [x] Registrar instalación, actualización y reinstalación como eventos
  distintos sin duplicar el elemento lógico de Biblioteca.
- [x] Marcar recibos anteriores como reemplazados solo cuando sea seguro.
- [x] No borrar archivos obsoletos de una versión anterior sin comprobar
  propiedad y solapamiento.
- [x] Permitir retirar una entrada del historial sin borrar contenido.
- [x] Posponer desinstalación hasta disponer de manifiestos de propiedad
  suficientemente precisos.

**Motivo:** una actualización puede dejar archivos antiguos; eliminar por nombre
o carpeta sin propiedad demostrada podría romper otros mods.

**Implementado (2026-09-27):** una política compartida compara únicamente
versiones numéricas punteadas y acepta texto no semántico solo para igualdad
exacta, sin inventar un orden. Biblioteca construye un índice de artefactos
canónicos con las mismas identidades de detalle y overlay; la vista
Actualizaciones muestra solo coincidencias verificadas y omite variantes
multiarchivo ambiguas.

El Worker nativo clasifica cada éxito confirmado como `install`, `update` o
`reinstall`. Un recibo `update` persiste qué artefactos anteriores sustituye
solo cuando la versión nueva es demostrablemente posterior; una reinstalación
conserva esa relación. La proyección oculta los reemplazados, pero conserva sus
manifiestos como evidencia de propiedad y mantiene los eventos en Recientes.
Retirar o revertir el recibo nuevo restaura naturalmente el estado anterior sin
una transacción frágil entre archivos.

La Biblioteca permite olvidar una instalación completa o retirar un evento
individual del historial. Ambas acciones piden confirmación, modifican solo
metadata privada y vuelven a reconciliar la proyección; nunca eliminan archivos
del juego. Olvidar fuerza un nuevo descubrimiento para que el contenido físico
restante pueda aparecer como externo. La desinstalación continúa pospuesta.

La interfaz de Biblioteca adopta el mismo sistema visual del Catálogo: vistas y
filtros inclinados, contadores, hojas inferiores retro, cabecera con borde duro
y estados vacíos o parciales con jerarquía clara. Los filtros de sección y
carpeta también se aplican a Actualizaciones; antes se mostraban en esa vista
sin afectar sus resultados.

Falta la matriz física de actualización, reinstalación, downgrade voluntario,
mantenimiento individual, reapertura y sincronización con el overlay antes de
declarar cerrada la fase.

### Matriz física para cerrar la fase 9

- [ ] Instalar una versión anterior y confirmar que aparece en
  **Actualizaciones** cuando el catálogo ofrece una versión numérica posterior.
- [ ] Abrir la actualización desde Biblioteca y completar el flujo desde la
  pantalla de origen.
- [ ] Confirmar que la versión nueva queda como única instalación lógica y que
  Recientes distingue el evento **Actualizado**.
- [ ] Reinstalar esa versión y confirmar **Reinstalado** sin que reaparezca la
  versión sustituida.
- [ ] Cancelar o provocar un fallo de actualización y comprobar que el recibo
  anterior continúa siendo el vigente.
- [ ] Instalar voluntariamente una versión anterior después de una nueva y
  comprobar que no se etiqueta falsamente como actualización.
- [ ] Usar **Olvidar instalación**, confirmar que desaparece de Instalados,
  que ningún archivo físico se borra y que el escaneo puede mostrarlo como
  contenido externo.
- [ ] Quitar un solo evento de Recientes y confirmar que la instalación vigente
  y sus archivos permanecen intactos.
- [ ] Actualizar/reinstalar con la burbuja abierta y confirmar que ambos engines
  terminan mostrando el mismo estado.
- [ ] Abrir Biblioteca sin red y confirmar que un fallo al consultar el catálogo
  no oculta Instalados, Recientes ni Detectados.
- [ ] Revisar un mod con varios archivos de versión y confirmar que Biblioteca
  no propone una variante arbitraria.
- [ ] Comprobar que **Olvidar instalación** queda bloqueado mientras ese mismo
  contenido tiene una operación activa.

## Pruebas automatizadas requeridas

- [ ] Serialización y migración de recibos.
- [ ] Escritura atómica y recuperación de archivo corrupto.
- [ ] Idempotencia de importación a la proyección Flutter/Hive.
- [ ] Identidad con títulos iguales y artefactos diferentes.
- [ ] Estado de botón para cada combinación relevante.
- [x] Comparación de versiones semánticas y no semánticas.
- [ ] Verificación de archivo suelto, carpeta única y raíces múltiples.
- [ ] Permiso revocado, carpeta cambiada y archivo eliminado manualmente.
- [ ] Worker completado con Flutter cerrado.
- [ ] Dos instalaciones paralelas en destinos iguales y distintos.
- [ ] Mensajes de app principal y overlay con la misma identidad.
- [ ] Migración de operación antigua sin metadata nueva.

## Matriz manual de aceptación

- [ ] Instalar un mod normal desde detalle.
- [ ] Instalar una versión anterior elegida manualmente.
- [ ] Instalar DynOS y Touch Controls en la carpeta compartida.
- [ ] Instalar OMM normal y OMM con destino DynOS.
- [ ] Instalar Render96 ZIP/7z según aplique.
- [ ] Instalar un archivo Lua suelto.
- [ ] Cerrar la app durante descarga y durante instalación.
- [ ] Reabrir y confirmar que Biblioteca se reconcilia.
- [ ] Iniciar desde overlay y comprobar el resultado en la app principal.
- [ ] Eliminar manualmente un archivo y verificar el cambio de estado.
- [ ] Cambiar la carpeta Mods y la carpeta DynOS.
- [ ] Revocar permisos SAF y recuperarlos.
- [ ] Instalar dos contenidos simultáneos con el mismo filename.
- [ ] Reinstalar y actualizar sin producir recibos lógicos duplicados.
- [ ] Probar tema claro/oscuro y EN/ES/PT-BR.
- [ ] Probar pantalla pequeña, orientación y escalado de texto.

## Fuera de alcance de la primera entrega

- [ ] Sincronización cloud del historial.
- [ ] Compartir historial entre dispositivos.
- [ ] Desinstalación recursiva basada solamente en nombres.
- [ ] Hash de todos los archivos de paquetes masivos.
- [ ] Escaneo continuo de las carpetas en segundo plano.
- [ ] Afirmar coincidencias de catálogo con baja confianza.

## Gates antes de integrar en `main`

- [ ] La rama está actualizada con `main` y no contiene ejemplos/repos externos.
- [ ] No hay falsos éxitos: solo `install_completed` genera recibo.
- [ ] Una descarga sin auto-install no aparece como instalada.
- [ ] Proceso muerto y reapertura conservan el resultado.
- [ ] Archivos borrados no permanecen indefinidamente como instalados.
- [ ] App y overlay presentan estados coherentes.
- [ ] No hay colisiones de identidad, recibos, temporales o notificaciones.
- [ ] Migraciones y rollback de datos están documentados.
- [ ] `flutter gen-l10n` pasa cuando se añadan strings.
- [ ] `flutter analyze lib` pasa sin incidencias.
- [ ] `android/gradlew -p android :app:compileDebugKotlin` pasa.
- [ ] Tests automatizados aplicables pasan.
- [ ] `git diff --check` pasa.
- [ ] La matriz manual mínima queda registrada en este documento.
- [ ] Arquitectura, descargas/overlay, estado del proyecto y changelog se
  actualizan antes del merge.

## Verificación de sincronización de estado

Esta sección debe completarse con evidencia antes de integrar en `main`.

- [ ] **Quién escribe:** Workers, repositorio, verificador SAF y acciones del
  usuario identificados explícitamente.
- [ ] **Quién lee:** providers, tarjetas, Biblioteca, Home y overlay listados.
- [ ] **Fuente de verdad:** WorkManager, recibos y SAF aplicados en su fase
  correspondiente sin competir entre sí.
- [ ] **Caches:** cajas Hive/proyecciones documentadas junto con todos sus
  mecanismos de invalidación.
- [ ] **Futures no esperados:** cada `unawaited(...)` revisado y con errores
  contenidos.
- [ ] **Implementaciones hermanas:** Mods, VIP, DynOS, Touch Controls, OMM,
  Render96, detalle y overlay revisados.

## Registro de avance y decisiones

Añadir una fila por sesión o decisión material. No marcar una fase completa sin
enlazar pruebas o commits cuando existan.

| Fecha | Fase | Cambio o decisión | Motivo | Validación | Commit/issue |
|---|---|---|---|---|---|
| 2026-09-23 | Planificación | Se creó la rama `historial-hive` y este roadmap | Aislar una función transversal y evitar riesgos en `main` | Revisión documental pendiente | — |
| 2026-09-23 | Fase 0 | Auditoría de catálogos/instalador, contrato de identidad y recibo v1, política de sentinelas y fixtures ZIP/7z/sueltos | Evitar identidad por título, filename o índices mutables antes de propagar metadata | Listados ZIP/7z, JSON auditado y `git diff --check` | — |
| 2026-09-23 | Fase 1 | Identidad canónica versionada propagada por pantallas, overlay, SharedPreferences, MethodChannel, Workers, reconciliación y eventos | Eliminar colisiones por títulos/índices y preparar recibos nativos sin crearlos aún | 8 tests Flutter, `flutter analyze lib`, `compileDebugKotlin` y `git diff --check` | — |
| 2026-09-24 | Fase 2 | Manifiesto SAF acotado y recibo JSON privado por artefacto, escrito atómicamente antes de `SUCCEEDED` | Conservar evidencia aunque Flutter esté cerrado y evitar éxito final sin persistencia | 6 tests Kotlin, `compileDebugKotlin`, `flutter analyze lib` y `git diff --check` | — |
| 2026-09-25 | Fase 3 | Lector nativo validado, historial durable limitado, repositorio de dominio, proyección Hive v1 y estado Riverpod | Recuperar instalaciones tras process death sin convertir Hive en autoridad | 7 tests Flutter, 6 tests Kotlin, `flutter analyze`, `compileDebugKotlin` y `git diff --check` | — |
| 2026-09-25 | Fase 4 | Verificador SAF acotado por centinelas, cuatro estados, refresco global/individual y proyección Hive v2 | Confirmar presencia física sin escaneos recursivos ni bloquear la UI | 17 tests Flutter, 6 tests Kotlin, `flutter analyze` y `compileDebugKotlin`; dispositivo pendiente | — |
| 2026-09-26 | Fase 5 | Selector canónico y botones coherentes en detalle/VIP/DynOS/Touch Controls/OMM/Render96 | Evitar “instalado” basado en un Worker terminado, dobles toques y actualizaciones falsas | 23 tests Flutter y `flutter analyze`; overlay transferido a Fase 7 | — |
| 2026-09-26 | Fase 6 | Biblioteca con Instalados/Actualizaciones/Detectados/Recientes, filtros, resumen en Home y navegación coherente | Hacer visible el estado durable y verificable sin convertir el historial ni Hive en autoridad física | Prueba física en OPPO CPH2365: drawer, detalle y regreso, recibo instalado, recientes y reconciliación “No encontrado” tras borrado externo | — |
| 2026-09-26 | Fase 7 | Snapshot versionado de Biblioteca hacia el segundo engine y selector canónico en cada tarjeta del overlay | Evitar estados divergentes entre app y burbuja sin compartir memoria ni convertir Hive en autoridad | 25 tests Flutter, análisis estático y matriz física de 10 escenarios aprobados | — |
| 2026-09-27 | Fase 8 | Escaneo SAF acotado de Lua externo, parser de encabezados, caché nativa separada, proyección Hive v3 y vista Detectados | Descubrir contenido previo/manual sin fabricar recibos ni inferir identidad de catálogo | Suite Flutter completa (29 tests), suite Kotlin completa (9 tests), análisis estático, compilación Kotlin y matriz física completa aprobada | — |
| 2026-09-27 | Fase 9 | Índice canónico de catálogo, actualizaciones verificadas, eventos install/update/reinstall, reemplazo lógico y mantenimiento no destructivo | Completar el ciclo de versiones sin borrar archivos cuya propiedad o solapamiento no esté demostrado | Suite Flutter completa (35 tests), suite Kotlin completa (14 tests), análisis estático y compilación Kotlin; dispositivo pendiente | — |
| 2026-09-26 | Corrección física Fases 4–5 | La ausencia deliberada de carpeta ahora conduce a Seleccionar carpeta; navegación a Ajustes reemplaza la ruta de detalle; el Worker registra y retira archivos nuevos de una instalación cancelada | Las pruebas físicas detectaron “Verificar” sin efecto, navegación vacía y mods nuevos parcialmente extraídos | Compilación/tests automatizados y repetición física pendientes | — |
| 2026-09-26 | Endurecimiento de cancelación | El rollback SAF es idempotente, serializado y no propaga errores del proveedor de documentos | Dos pruebas físicas iniciales cerraron el proceso; después de corregir observers, dos cancelaciones retiraron los parciales en 8–15 s sin errores de rollback | `logcat` físico en OPPO CPH2365 confirmado | — |
| 2026-09-26 | Corrección de crash al repetir operación | Todos los observers de WorkManager aceptan la emisión transitoria `null` producida cuando `REPLACE` retira la fila anterior | `logcat` capturó NPE antes de entrar al null-check Kotlin; el nuevo APK soportó dos cancelaciones y una instalación final de la misma identidad | Kotlin/Flutter sin errores y matriz física repetida correctamente | — |

## Definición de terminado

La primera entrega estará terminada cuando una instalación confirmada sobreviva
al cierre del proceso, pueda verificarse en SAF, actualice todas las superficies
de UI con la misma identidad y nunca afirme “Instalado” basándose únicamente en
un título, una descarga terminada o un valor histórico de Hive.
