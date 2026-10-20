# Rendimiento de Biblioteca — línea 1.8.4+

Revisión: 2026-10-15. Este documento describe los cambios de rendimiento en
`library-performance-1.8.4`; no afirma todavía una medición física de APK.

## Qué causaba la espera

La vista de Mods del juego y DynOS obtenía un snapshot nativo mediante SAF. Ese
snapshot enumera las dos rutas del juego, abre los Lua para leer sus cabeceras,
lee `sm64config.txt` y examina los packs DynOS. Al volver a montar el panel se
pedía otro snapshot aunque Riverpod conservaba el anterior. Además, el primer
render de Biblioteca inicializaba recibos e información de actualizaciones aun
cuando la sección activa era Mods del juego. Al cambiar un switch, Kotlin
volvía a escanear la biblioteca para validar el objetivo y generaba un snapshot
completo después de verificar la escritura.

Android ya ejecutaba esas operaciones fuera del hilo visual. El coste venía de
consultas SAF repetidas y de esperar el nuevo catálogo completo, no de hacer el
trabajo en el hilo de Flutter.

## Flujo optimizado

1. **Carga por sección.** Mods del juego y DynOS observan el provider de
   activación. Recibos se cargan al abrir Instalados, Historial o Actualizaciones;
   catálogos de comparación se consultan al abrir Actualizaciones. Los
   contadores que no estén en memoria aparecen cuando su sección se visita, sin
   iniciar esos escaneos al entrar a Mods del juego.
2. **Snapshot reutilizable.** El `AsyncNotifier` permanece vivo al cambiar de
   pestaña. El panel no fuerza una lectura al montarse: pide una actualización
   solo si al volver a montar el panel su snapshot tiene más de 30 segundos. La
   lista anterior permanece visible durante ese refresco. Cambiar la carpeta o
   completar una instalación invalida la frescura; reanudar con el panel activo
   fuerza una lectura y el gesto de refresco siempre solicita datos actuales.
3. **Validación de objetivo.** Para habilitar Lua, Kotlin resuelve por nombre
   exacto el primer origen según la precedencia del juego (user antes que la
   carpeta externa), lee solo la cabecera objetivo y los mods activos necesarios
   para validar incompatibilidades. Ya no enumera y analiza todos los mods para
   cada cambio. DynOS resuelve el pack con precedencia externa antes que user,
   como el juego. Deshabilitar permite retirar del config una directiva cuyo
   contenido ya no exista.
4. **Actualización visual inmediata.** Tras confirmar el cuadro de acción, el
   switch y los contadores usan un estado temporal local mientras Android guarda
   en segundo plano. La tarjeta no se bloquea ni sustituye el control por un
   spinner. Si la escritura falla, se descarta el estado temporal, se recupera
   el valor confirmado anterior y se muestra un error accionable.
5. **Respuesta compacta.** Kotlin conserva la copia de seguridad, comprueba que
   el config no cambió entre lectura y escritura, vuelve a comprobar que no haya
   Workers activos, escribe, sincroniza y relee los bytes. Devuelve el resultado
   del objetivo, sin escanear otra vez todos los mods y packs. Flutter mezcla
   esa confirmación con los metadatos ya visibles.
6. **Refresco completo donde corresponde.** La búsqueda, filtros, identidad,
   precedencia, historial de configuración y detalles siguen usando el snapshot
   validado. Refresco manual, reanudación con el panel activo, cambio de carpeta e
   instalación son los puntos que vuelven a enumerar contenido.
7. **Arranque cache-first.** Al reconstruir el proceso, Biblioteca presenta de
   inmediato la última proyección válida guardada en Hive y verifica recibos y
   SAF en segundo plano. La conexión inicial a la misma carpeta ya no se trata
   como un cambio de carpeta ni borra el snapshot de Mods del juego. Solo un
   cambio real posterior de `connectionKey` invalida esos datos. La primera
   ejecución, una carpeta nueva o un caché inválido conservan la carga normal.

La verificación recursiva del límite de tamaño Lua se mantiene al habilitar un
mod. Puede tardar más en carpetas grandes o proveedores SAF lentos; se ejecuta
fuera del hilo visual y el switch muestra el estado pendiente mientras corre.
No se salta esa comprobación para dar una respuesta rápida.

## Estado y ciclo de vida

- **Fuente de verdad de selección:** `sm64config.txt`, leído y editado por
  `GameModActivationStore` bajo `InstallationSafAccessCoordinator.lock`.
- **Estado presentado:** snapshot de `gameModActivationProvider`; para la
  operación visible, `_pendingEnabled` solo proyecta temporalmente el valor
  solicitado en `GameModActivationPanel`.
- **Confirmación:** solo el resultado nativo tras verificar los bytes se mezcla
  como valor confirmado. La UI anticipa la intención del usuario, pero un error
  borra esa proyección, mantiene el snapshot confirmado y muestra el fallo.
- **Invalidación:** cambios de carpeta e instalación marcan el snapshot como
  obsoleto. Si la app reanuda con Biblioteca abierta, el panel visible fuerza
  lectura; al volver a montarse, revalida si los datos tienen más de 30
  segundos. El gesto manual siempre vuelve a leer SAF.
- **Persistencia:** Hive contiene únicamente una proyección reconstruible para
  el primer frame. Los recibos nativos, `sm64config.txt` y el contenido SAF
  continúan siendo la fuente de verdad. La verificación sustituye la proyección
  cuando termina; un error transitorio conserva la última lista visible y deja
  disponible el refresco manual.
- **Engines:** esta gestión vive en el engine principal. La autoridad nativa y
  el archivo compartido evitan depender de memoria cruzada con el overlay.
- **Escrituras consecutivas:** los toques se reflejan inmediatamente y entran en
  una cola ordenada. La operación nativa sigue serializada con acceso SAF; la
  edición vuelve a comprobar el config y la actividad de WorkManager justo antes
  de escribir. Acciones destructivas de carpeta/restauración esperan a que la
  cola termine.

## Objetivo y límites de rendimiento

Al abrir de nuevo la aplicación o volver a Mods del juego o DynOS con un
snapshot reciente, la interfaz debe mostrar la lista sin esperar un nuevo
recorrido SAF. Después de aceptar la
confirmación, el switch debe reflejar el cambio en el primer frame disponible;
la validación continúa silenciosamente y solo interrumpe si falla. El tiempo de confirmación real depende del
proveedor SAF del dispositivo y del tamaño/estructura del mod; no se promete
que cada escritura física termine en menos de un segundo.

No hay una medición física de 1.8.4 todavía. Comparar en el mismo dispositivo:
primera entrada con muchos Lua y packs; volver a la vista antes/después de 30
segundos; habilitar/deshabilitar Lua y DynOS; mod Lua con árbol grande; cambio
de app instalada; reanudación tras editar el archivo desde el juego; permiso
revocado; instalación activa; fallo de escritura. Confirmar que la UI responde
enseguida, que el valor final coincide con `sm64config.txt` y que al fallar el
switch vuelve al estado anterior.
