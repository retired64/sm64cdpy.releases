# Task Checklist Manager — Biblioteca e historial de instalaciones

> Roadmap aislado para diseñar e implementar una biblioteca local verificable
> sin comprometer la estabilidad de `main`.

| Campo | Valor |
|---|---|
| Proyecto | SM64CDPY — SM64CoopDX Mods Browser |
| Rama de trabajo | `historial-hive` |
| Estado | Fases 0 y 1 completadas; Fase 2 pendiente de autorización |
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

- [ ] Cambiar el resultado interno de extracción para obtener conteo y huella
  verificable, sin duplicar `SafZipExtractor`.
- [ ] Definir centinelas para archivo suelto, carpeta única y múltiples raíces.
- [ ] Limitar el tamaño de la huella para archivos con miles de entradas.
- [ ] Escribir el recibo solamente después de completar todas las escrituras.
- [ ] Usar escritura atómica: temporal, flush y reemplazo final.
- [ ] No crear recibo en descarga completa sin instalación.
- [ ] No crear recibo en fallo, cancelación o permiso SAF revocado.
- [ ] Evitar carreras entre dos Workers paralelos.
- [ ] Reconciliar un Worker `SUCCEEDED` cuyo evento no fue recibido por Flutter.
- [ ] Definir tratamiento de éxito nativo con fallo posterior al guardar recibo.

**Motivo:** `install_completed` debe dejar evidencia aun cuando ambos engines
Flutter estén cerrados.

## Fase 3 — Repositorio de Biblioteca y proyección Hive

- [ ] Crear un repositorio de dominio independiente de widgets y tarjetas.
- [ ] Leer y validar recibos nativos al iniciar.
- [ ] Diseñar una caja Hive separada y versionada si se confirma que aporta una
  mejora de arranque, ordenación o historial.
- [ ] Hacer idempotente la importación de recibos mediante `artifactKey` y UUID.
- [ ] Exponer estados con Riverpod: cargando, listo, parcial y error.
- [ ] Ordenar eventos por fecha sin depender del orden físico del almacén.
- [ ] Invalidar la proyección al instalar, actualizar, reinstalar, verificar,
  cambiar carpeta o recuperar permisos.
- [ ] Manejar recibos corruptos sin impedir abrir la Biblioteca.
- [ ] Definir limpieza y límite razonable del historial.
- [ ] Añadir migraciones y pruebas de versiones de esquema.

**Motivo:** Hive es útil como proyección Flutter, pero el sistema no debe perder
una instalación terminada mientras Dart no estaba ejecutándose.

## Fase 4 — Verificación SAF

- [ ] Añadir una operación nativa de verificación por destino y centinelas.
- [ ] Diferenciar `present`, `missing`, `unknown` y `permissionRevoked`.
- [ ] No recorrer recursivamente ambas carpetas en cada render de tarjeta.
- [ ] Hacer verificación rápida al abrir Biblioteca y bajo demanda por elemento.
- [ ] Marcar como no verificados los registros al cambiar la URI de destino.
- [ ] Mantener historial al limpiar una selección de carpeta.
- [ ] Volver a verificar después de recuperar el permiso.
- [ ] Definir una actualización controlada de toda la Biblioteca.
- [ ] Limitar concurrencia y trabajo de I/O para evitar congelamientos.
- [ ] Probar proveedores SAF lentos y árboles grandes.

**Motivo:** el recibo explica qué ocurrió; SAF confirma qué sigue existiendo.

## Fase 5 — Selector canónico de estado y acciones

- [ ] Crear un selector compartido que combine operación, recibo, verificación
  y versión del catálogo.
- [ ] Mostrar Descargar cuando no exista instalación conocida.
- [ ] Mostrar progreso y Cancelar durante una operación activa.
- [ ] Mostrar Instalado únicamente con estado confirmado y verificable.
- [ ] Mostrar Actualizar cuando la versión canónica sea distinta y la
  comparación sea confiable.
- [ ] Mostrar Reinstalar cuando falten archivos registrados.
- [ ] Mostrar Verificar cuando el estado sea desconocido.
- [ ] Mostrar Seleccionar carpeta cuando falte acceso SAF.
- [ ] Ofrecer Reinstalar como acción secundaria de un elemento instalado.
- [ ] No afirmar que una versión es antigua si su formato no puede compararse.
- [ ] Aplicar el selector a catálogo, detalle, VIP, DynOS, Touch Controls, OMM,
  Render96 y overlay.

**Motivo:** ninguna tarjeta debe inventar su propio criterio de “instalado”.

## Fase 6 — Pantalla Biblioteca y Home

- [ ] Añadir ruta y entrada **Biblioteca** cerca de Favoritos en el drawer.
- [ ] Diseñar estados vacío, cargando, error y permiso revocado.
- [ ] Añadir vistas Instalados, Actualizaciones, Detectados y Recientes.
- [ ] Permitir filtrar por sección y destino.
- [ ] Mostrar versión instalada, fecha, verificación y acción disponible.
- [ ] Añadir hasta tres instalaciones recientes en Home.
- [ ] Ocultar el bloque de Home cuando no haya historial.
- [ ] Permitir “Ver todo” sin duplicar listas completas en Home.
- [ ] Mantener el diseño usable en pantallas pequeñas y con texto ampliado.
- [ ] Añadir todas las cadenas a EN, ES, ES-419, PT y PT-BR.

**Motivo:** Biblioteca es una función permanente; Home solo debe ofrecer un
resumen compacto y no convertirse en una lista interminable.

## Fase 7 — Sincronización con el overlay

- [ ] Enviar snapshot de instalaciones relevantes cuando se abra el panel.
- [ ] Enviar cambios después de instalar, verificar o detectar actualización.
- [ ] No leer Hive desde el segundo engine como si compartiera memoria.
- [ ] Mostrar estado instalado/actualización usando la misma `artifactKey`.
- [ ] Resolver el caso en que el overlay se abre antes de cargar la proyección.
- [ ] Evitar duplicar toasts o resultados terminales entre engines.
- [ ] Probar cierre y reapertura del panel durante una reconciliación.

**Motivo:** app y burbuja deben presentar la misma verdad aunque tengan engines
e isolates independientes.

## Fase 8 — Descubrimiento de instalaciones antiguas o externas

- [ ] Adaptar de manera nativa la lectura limitada de encabezados Lua.
- [ ] Buscar `main.lua`, después `mod.lua`, y archivos Lua raíz.
- [ ] Extraer nombre, versión, categoría y autor solo cuando existan.
- [ ] Limpiar códigos de color sin modificar los archivos del usuario.
- [ ] Tratar DynOS y Touch Controls como tipos no inferibles solo por carpeta.
- [ ] Definir niveles de confianza: exacto, probable y sin vincular.
- [ ] No cambiar un botón del catálogo por una coincidencia ambigua.
- [ ] Presentar elementos ambiguos como “Detectado en el dispositivo”.
- [ ] Permitir vinculación manual futura sin hacerla requisito de la primera
  versión.
- [ ] Ejecutar el escaneo al migrar, cambiar carpeta o por acción del usuario;
  nunca en cada reconstrucción de UI.

**Motivo:** la lógica del script Python ayuda a descubrir contenido, pero no
demuestra por sí sola qué entrada del catálogo lo originó.

## Fase 9 — Actualizaciones, reinstalación y mantenimiento

- [ ] Comparar versión instalada con la versión canónica del catálogo.
- [ ] Usar coincidencia exacta como fallback cuando no exista SemVer válido.
- [ ] Registrar instalación, actualización y reinstalación como eventos
  distintos sin duplicar el elemento lógico de Biblioteca.
- [ ] Marcar recibos anteriores como reemplazados solo cuando sea seguro.
- [ ] No borrar archivos obsoletos de una versión anterior sin comprobar
  propiedad y solapamiento.
- [ ] Permitir retirar una entrada del historial sin borrar contenido.
- [ ] Posponer desinstalación hasta disponer de manifiestos de propiedad
  suficientemente precisos.

**Motivo:** una actualización puede dejar archivos antiguos; eliminar por nombre
o carpeta sin propiedad demostrada podría romper otros mods.

## Pruebas automatizadas requeridas

- [ ] Serialización y migración de recibos.
- [ ] Escritura atómica y recuperación de archivo corrupto.
- [ ] Idempotencia de importación a la proyección Flutter/Hive.
- [ ] Identidad con títulos iguales y artefactos diferentes.
- [ ] Estado de botón para cada combinación relevante.
- [ ] Comparación de versiones semánticas y no semánticas.
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

## Definición de terminado

La primera entrega estará terminada cuando una instalación confirmada sobreviva
al cierre del proceso, pueda verificarse en SAF, actualice todas las superficies
de UI con la misma identidad y nunca afirme “Instalado” basándose únicamente en
un título, una descarga terminada o un valor histórico de Hive.
