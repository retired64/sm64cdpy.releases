# Plan de integración: Play 2P2

## Objetivo

Integrar una nueva entrada `Play 2P2` dentro de **GameTool** en el menú slide para crear o unirse a una sesión de SM64CoopDX mediante un código corto, manteniendo una experiencia fluida y permitiendo sustituir el backend temporal por el conector Cloudflare propio sin rehacer la pantalla.

Este documento parte del análisis técnico de `COOP_SESSION_ENGINE_ANALYSIS.md`. Separa explícitamente hechos observados en el APK, decisiones recomendadas para esta aplicación y puntos todavía no confirmados.

## Decisión principal

El objetivo seleccionado es implementar dentro de nuestro APK un cliente compatible con el protocolo observado. No se abrirá ni se necesitará la otra APK: un usuario de nuestra aplicación podrá crear una sala o unirse a una creada por la aplicación compatible, usando el mismo código y señalización.

La ruta recomendada mantiene tres piezas independientes:

1. **Pantalla y estado de sesión**, propios de Flutter.
2. **Motor local Android**, responsable del puente UDP, WebRTC y continuidad en segundo plano.
3. **Adaptador de señalización**, reemplazable: compatibilidad con el Worker actual o Cloudflare propio.

La primera versión del adaptador reproducirá el contrato compatible observado. Después, el conector propio podrá sustituirlo sin cambiar la pantalla, el puente UDP ni el flujo dentro del juego.

## Estado implementado en `play-2p2`

- Pantalla Flutter completa en `/game-tool/play-2p2`, enlazada desde ambos sistemas de navegación.
- Estado de sesión centralizado en Riverpod, con revisiones monotónicas para descartar eventos atrasados.
- Historial local limitado a cuatro códigos, sin duplicados.
- Motor de compatibilidad aislado en un WebView invisible y persistente, cargado desde assets locales; Flutter nunca ejecuta ni conoce el protocolo.
- Señalización cifrada compatible mediante el Worker observado, sin enviar códigos ni identificadores de sala a trackers públicos.
- Puente UDP nativo hacia SM64CoopDX, con puerto 7777, asignación alternativa para invitado, búfer acotado y liberación idempotente.
- Servicio Android de primer plano con WakeLock y WifiLock activos solo durante una sesión.
- Detección y apertura directa de `com.maniscat2.sm64coopdx`.
- WebView mantenido visible para Android solo mientras el puente está activo; fuera de una sesión conserva su ciclo de vida normal.
- Detención autónoma desde la notificación: el servicio libera sus locks aunque Flutter o su receptor ya no existan.
- Recuperación coherente: una pérdida del renderer o del Activity termina la sesión y publica un estado terminal; nunca conserva un falso estado conectado.
- Diagnóstico local con paquetes hacia/desde el juego, demora del puente y disponibilidad de señalización, actualizado una vez por segundo y sin direcciones IP.
- Normalización Crockford compatible (`I/L → 1`, `O → 0`, `U → V`) en Flutter y en el límite nativo.
- Acceso opcional y explícito a la exclusión de optimización de batería de Android 6+, con consulta del estado al volver a la aplicación.

La decisión de mantener WebRTC dentro del WebView local evita incorporar otra biblioteca nativa pesada y conserva el comportamiento del motor observado. UDP, ciclo de vida, notificación y recursos de segundo plano permanecen en Kotlin. El adaptador queda contenido en `assets/coop`, por lo que el futuro Worker propio podrá reemplazar la señalización sin cambiar la pantalla ni el puente del juego.

### Compatibilidad no significa dependencia de la APK

La aplicación original no necesita estar instalada. Lo que debe reproducirse es el contrato completo:

- normalización y derivación del código;
- identificación de la sala;
- mensajes WebSocket y su orden;
- cifrado de señalización;
- negociación ICE/STUN/TURN;
- parámetros del DataChannel;
- puente UDP y semántica host/invitado;
- reconexión y cierre.

Si existe código fuente con una licencia que autorice reutilización y redistribución, se podrá adaptar respetando sus avisos y condiciones. Si lo disponible procede de decompilación y no tiene licencia de reutilización, no debe copiarse literalmente: se implementará un cliente limpio a partir del comportamiento y del contrato documentado.

## Qué confirmó el análisis del APK

El análisis estático documenta el siguiente flujo:

- Código de sala de ocho caracteres Crockford Base32, presentado como `ABCD-1234`.
- Derivación PBKDF2-HMAC-SHA256 con la sal `coop-mod-loader/room/v2`, 600 000 iteraciones y 52 bytes de salida: 20 bytes para identificar la sala y 32 bytes para AES-GCM.
- Intercambio de señalización por WebSocket y SDP cifrado con AES-GCM.
- Transporte de juego mediante un DataChannel WebRTC no ordenado y no confiable, apropiado para reproducir datagramas UDP sin crear cola por paquetes atrasados.
- Puente Android entre WebRTC y el juego por loopback UDP, normalmente `127.0.0.1:7777`.
- En modo invitado, si `7777` ya está ocupado, el puente selecciona otro puerto local y lo comunica a la interfaz.
- Servicio de primer plano, WakeLock y WifiLock para sostener la conexión al cambiar al juego. El análisis estático no demuestra recuperación después de muerte del proceso.
- Detección y apertura del paquete `com.maniscat2.sm64coopdx`.

Evidencia de host y puente: `ev_c59f30b962680b94fb10bb87df0804239c3521a401a5b1c3dda16f6411efb2e8`, `ev_ec2ad5d070c723cfadf3515e8bd2203067cf0afae3213fb9274bde226510ca25`, `ev_8a17f384ce51cf83ae28561deaa065c9d7f99feba09d229c0cb6c7944688a763`.

Evidencia del invitado: `ev_fac78467ab23e2690ea2b61075e4b058134a034c378c368beb43a0a955265155`, `ev_c6f00f048eeca3d010a38d70bcfd7d67d764f25e2878477bbeff649bb9d7ac55`.

Evidencia de segundo plano y liberación de recursos: `ev_105c67a2ea8f378b6c1d1c6575fe03006f093125b1351a6dc0658b7544cf3ff7`, `ev_85747b2126f7fb5a1452072900639d3520b2547216877a7cfc263ef8f9cc4f97`, `ev_2b2376c3f18716e7768a51fb9f41591cc5a1759fcc3d6064de3a3fb627362e9`.

Evidencia de detección del juego: `ev_8722141ef671853382f709bf0b6ae16342bff77c623938347540b1548fc36c73`, `ev_ebca543792dc14d44d0a6a366f7134d82454884370ac485550337b2c8cb873cb`.

### Límites de esa evidencia

El análisis no confirma el código del Worker, su política de retención, límites, registros, disponibilidad ni contrato público. La prueba manual de aproximadamente 20 solicitudes por minuto confirma accesibilidad durante esa prueba, pero no demuestra que ese sea un límite contractual, permanente o igual para WebSocket, creación de salas y credenciales ICE. Antes de depender del endpoint hay que reproducir la prueba, guardar respuesta HTTP, cabeceras de rate limit, ventana temporal y comportamiento al excederla.

La URL expuesta permite intentar interoperabilidad, pero no ofrece por sí sola garantía de disponibilidad, autorización de uso, compatibilidad futura o capacidad. El cliente debe asumir que el Worker puede cambiar o desaparecer.

## Ubicación en la aplicación

### Ruta propuesta

`/game-tool/play-2p2`

### Navegación

- Añadir `Play 2P2` al grupo **GameTool** de `app_drawer.dart`.
- Añadir el mismo destino al grupo GameTool de `manga_navigation_bar.dart`.
- Registrar la ruta en `app_router.dart`.
- Mantener una única definición conceptual del destino para que drawer y menú slide no diverjan visualmente o en comportamiento.
- Añadir localizaciones para nombre, instrucciones, estados y errores; no incrustar textos en widgets.

## Experiencia de la pantalla

### 1. Preparación

La pantalla debe aparecer inmediatamente, sin bloquearse mientras inspecciona el dispositivo. En paralelo comprueba:

- si SM64CoopDX está instalado;
- versión detectada, si Android permite consultarla;
- disponibilidad del motor local;
- conectividad de red;
- consentimiento de red vigente;
- existencia de una sesión recuperable.

Cada comprobación se representa individualmente. Un fallo no debe convertir toda la pantalla en un cargador.

### 2. Crear partida

- Botón principal **Crear partida**.
- Generación local del código; nunca esperar a la red para mostrar la estructura de la pantalla.
- Código grande con acciones Copiar y Compartir.
- Estado visible: preparando, esperando amigos, conectando, conectado o reconectando.
- Botón **Abrir SM64CoopDX** cuando el puente host esté listo.
- Instrucción contextual para iniciar `Host > Direct Connection > Host` dentro del juego.

### 3. Unirse

- Entrada con normalización automática a mayúsculas y formato `XXXX-XXXX`.
- Validación local antes de realizar solicitudes.
- Historial de hasta cuatro códigos recientes, sin duplicados.
- Tras conectar, mostrar el puerto local que debe usar el juego y el botón para abrirlo.
- Mensaje claro cuando el puerto estándar está ocupado y se asigna uno alternativo.

### 4. Sesión activa

- Rol: host o invitado.
- Número de amigos y estado de cada peer.
- Ruta de conectividad: directa o relay, sin revelar direcciones IP.
- Estado del juego: no instalado, cerrado, abierto o hospedando.
- Reconexión no bloqueante con intento actual y límite.
- Acción **Detener sesión**, siempre disponible y con liberación completa de recursos.
- Diagnóstico desplegable de señalización, tráfico del puente y demora, sin exponer IP, SDP ni el secreto de sala.

### 5. Batería y segundo plano

- La sesión funciona sin conceder acceso especial de batería; nunca se bloquea Crear o Unirse por no concederlo.
- En Android 6 o posterior, la pantalla consulta `PowerManager.isIgnoringBatteryOptimizations()` y muestra una acción opcional.
- La solicitud directa se realiza solo tras el toque del usuario mediante `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`; si el fabricante no ofrece esa Activity, se abre la lista general o los detalles de la aplicación.
- Al regresar desde Ajustes se vuelve a consultar Android en vez de asumir que el usuario concedió el acceso.
- La aplicación explica el costo: mejora la continuidad de una conexión persistente, pero puede aumentar el consumo de batería.

Android indica que esta exclusión debe reservarse para casos en los que Doze rompe una función central y que incluso una aplicación exenta conserva otras restricciones. Referencias oficiales: [Doze y App Standby](https://developer.android.com/training/monitoring-device-state/doze-standby) y [`ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`](https://developer.android.com/reference/android/provider/Settings#ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).

## Máquina de estados

La UI no debe deducir el estado a partir de varios booleanos. El motor publicará una instantánea inmutable:

```text
idle
  ├─ preparing
  │    ├─ waiting
  │    ├─ connecting
  │    └─ failed
  ├─ connected
  │    ├─ reconnecting
  │    └─ stopping
  └─ stopped
```

Datos mínimos de la instantánea:

- `sessionId`, distinto para cada ejecución y usado para rechazar callbacks antiguos;
- `mode`: host o join;
- `phase`;
- código normalizado solo mientras la sesión lo necesite;
- puerto UDP local;
- peers conectados;
- ruta directa/relay/desconocida;
- estado del juego;
- error tipado y recuperable;
- marcas de tiempo para diagnóstico local sin datos sensibles.
- contadores acumulados de paquetes y demora del puente, reiniciados al iniciar cada sesión.

## Contratos propuestos

Los nombres definitivos deben ajustarse a las convenciones existentes al implementar. La separación necesaria es:

### `CoopSessionEngine`

- iniciar host;
- unirse con código;
- detener;
- recuperar sesión activa;
- abrir el juego;
- emitir instantáneas de estado.

### `SignalingAdapter`

- registrar sala;
- publicar oferta/respuesta/candidatos cifrados;
- recibir eventos;
- obtener configuración ICE efímera;
- cerrar y eliminar estado temporal.

### `GameUdpBridge`

- reservar puerto local;
- enviar datagramas al juego;
- observar datagramas del juego;
- cambiar de peer sin recrear innecesariamente la UI;
- cerrar sockets de forma idempotente.

La pantalla solo conoce `CoopSessionEngine`. No conoce URLs, Worker, claves TURN, sockets ni detalles de WebRTC.

## Reparto Flutter/Android

### Flutter

- composición visual y accesibilidad;
- máquina de presentación derivada de la instantánea del motor;
- código e historial reciente;
- consentimiento y ayuda;
- navegación y localización.

### Android nativo

- sockets UDP y loopback;
- WebRTC/DataChannel;
- servicio de primer plano y notificación;
- WakeLock y WifiLock limitados a una sesión activa;
- detección/apertura del juego;
- finalización coherente si Android destruye el Activity, el FlutterEngine o el renderer; una sesión WebRTC en memoria no se presenta como recuperable después de perder esos procesos.

Mantener transporte y sockets en Android evita depender del ciclo de vida de widgets y reduce pausas cuando Flutter pasa a segundo plano al abrir el juego.

## Estrategia de interoperabilidad mientras se crea Cloudflare propio

### Etapa temporal seleccionada — Cliente compatible integrado

La nueva pantalla ejecutará el motor dentro de nuestra aplicación y hablará con el Worker observado. No requerirá instalar ni abrir la aplicación externa. El objetivo de aceptación es interoperabilidad cruzada en ambos sentidos:

1. Nuestra aplicación crea el código y la aplicación externa se une.
2. La aplicación externa crea el código y nuestra aplicación se une.
3. En ambos sentidos, los datagramas llegan al juego sin transformaciones.

Inicialmente debe habilitarse solo en builds de prueba hasta confirmar el contrato completo y realizar pruebas cruzadas reales.

Condiciones mínimas:

- activación explícita solo en builds de prueba durante la validación;
- URL inyectada por configuración, nunca dispersa por la UI ni compilada dentro de widgets;
- interruptor remoto/local para desactivarlo;
- aviso de que es infraestructura de terceros sin garantía;
- sin claves, SDP, IP o códigos en logs;
- pruebas de compatibilidad completas: derivación, cifrado, mensajes, WebRTC, UDP y recuperación.

Cambiar solamente la URL no basta: la compatibilidad depende de todo el contrato criptográfico y de señalización. Tampoco se debe programar el cliente suponiendo que el límite observado de 20 solicitudes por minuto es oficial; el estado debe manejar explícitamente respuestas `429`, desconexiones y backoff con jitter.

### Etapa definitiva — Cloudflare propio conservando compatibilidad

- Worker como entrada autenticada y emisor de credenciales TURN de corta vida.
- Durable Object por sala para señalización WebSocket y presencia efímera.
- WebRTC directo cuando sea posible; TURN solo cuando NAT/firewall lo requiera.
- TTL de sala, límites de peers, rate limiting y cierre explícito.
- ningún secreto TURN incluido en el APK.

Cuando el backend propio esté listo, habrá que decidir si conserva exactamente el protocolo compatible o si introduce una versión nueva. La opción más segura es negociar `protocolVersion`: mantener una ruta compatible para clientes anteriores y usar una ruta propia versionada para nuevas funciones.

Cloudflare documenta que Durable Objects puede coordinar clientes WebSocket y recomienda la API de hibernación para conservar conexiones mientras el objeto duerme. Cloudflare TURN exige generar credenciales con caducidad desde backend y mantener la clave de largo plazo en servidor. Fuentes: [Durable Objects y WebSockets](https://developers.cloudflare.com/durable-objects/best-practices/websockets/), [generación de credenciales TURN](https://developers.cloudflare.com/realtime/turn/generate-credentials/) y [servicio TURN](https://developers.cloudflare.com/realtime/turn/).

## Etapas de implementación

### Fase 0 — Contrato y prototipo visual

- ruta y entradas de navegación;
- pantalla completa con estados simulados;
- modelo de estado y errores;
- consentimiento de red;
- historial local de códigos;
- pruebas de widgets, formato y accesibilidad.

Resultado: se valida UX sin red, WebRTC ni servicio en segundo plano.

### Fase 1 — Integración local con el juego

- detección y apertura de SM64CoopDX;
- puente UDP nativo host/join;
- asignación de puerto alternativo;
- canal Flutter/Android con métodos y eventos versionados;
- pruebas instrumentadas con datagramas binarios.

Resultado: la app habla con una instancia local del juego sin depender de Internet.

### Fase 2 — Transporte WebRTC

- DataChannel no ordenado/no confiable;
- configuración ICE inyectable;
- cifrado y vectores deterministas;
- señalización local de laboratorio;
- reintento, ICE restart y rechazo de eventos obsoletos.
- pruebas cruzadas contra la aplicación compatible como host y como invitado.

Antes de añadir una dependencia WebRTC debe elegirse y aprobarse una de estas rutas:

1. WebRTC nativo Android detrás del canal de plataforma: mejor control del segundo plano, mayor trabajo nativo y tamaño binario.
2. `flutter_webrtc`: prototipo más rápido, pero añade una dependencia y exige validar que sobreviva correctamente al cambio hacia el juego.

### Fase 3 — Cloudflare propio

- Worker + Durable Object;
- protocolo versionado;
- salas efímeras sin SDP persistente;
- credenciales TURN por sesión y corta duración;
- límites, métricas anónimas y protección contra abuso;
- ambientes separados de desarrollo y producción.

Resultado: backend controlado, reemplazable y sin secretos dentro del APK.

### Fase 4 — Segundo plano y endurecimiento

- servicio de primer plano solo durante la sesión;
- notificación con acción detener;
- WakeLock/WifiLock adquiridos tarde y liberados temprano;
- recuperación tras recreación de Activity y proceso;
- consulta y solicitud opcional de exclusión de optimización de batería;
- comportamiento ante pérdida/cambio de red;
- validación en Android 14+.

Android exige declarar el tipo de servicio de primer plano apropiado; `specialUse` requiere además describir el caso mediante una propiedad del servicio. Fuente: [tipos de foreground service](https://developer.android.com/develop/background-work/services/fgs/service-types).

La recuperación implementada no intenta reconstruir WebRTC después de muerte del proceso: cierra de forma terminal y pide iniciar otra sesión. La recuperación transparente exigiría persistir secretos y renegociar identidad/peers, lo que no está demostrado por el APK y sería menos seguro que un cierre claro.

### Fase 5 — Pruebas físicas y lanzamiento gradual

- Wi-Fi/Wi-Fi, Wi-Fi/datos y datos/datos;
- NAT restrictivo con TURN;
- pantalla apagada y cambio de aplicación;
- dispositivos con 2–4 GB de RAM;
- cierre inesperado, reconexión y detención manual;
- compatibilidad de versiones del juego;
- telemetría local/exportable sin información sensible.

## Rendimiento en gama baja

- Pantalla inmediata con estado persistido y verificación posterior.
- Un único stream de instantáneas, con actualizaciones agrupadas; no reconstruir toda la pantalla por cada paquete.
- Ningún datagrama del juego atraviesa el árbol de widgets ni se guarda en Hive.
- Sockets y cifrado fuera del isolate de UI.
- Historial pequeño y lecturas locales sin escaneos al entrar.
- Sin blur, partículas ni animaciones continuas en esta pantalla.
- Frecuencia visual de métricas limitada; el motor puede procesar paquetes sin publicar cada evento.
- Liberación idempotente para evitar servicios, locks o sockets huérfanos.

## Persistencia

### Permitido persistir

- hasta cuatro códigos recientes si el usuario lo acepta;
- última función utilizada: crear/unirse;
- consentimiento y versión del texto aceptado;
- instantánea no sensible de una sesión activa para recuperación;
- configuración del ambiente sin secretos.

### No persistir

- clave AES derivada;
- SDP u ofertas/respuestas;
- credenciales TURN;
- IP de peers;
- datagramas del juego;
- logs con el código completo.

Los códigos recientes deben poder borrarse individualmente o en conjunto. En diagnóstico, mostrar como máximo una forma enmascarada.

## Seguridad y privacidad

- Tratar el código de sala como secreto compartido.
- CSPRNG para generar códigos; nunca `Random()` no criptográfico.
- Comparaciones y validaciones antes de abrir recursos nativos.
- Límite de intentos y peers por sala.
- Versión de protocolo negociada antes de intercambiar tráfico.
- AAD de AES-GCM que incluya versión y tipo de mensaje para evitar confusión entre mensajes.
- Secretos Cloudflare exclusivamente en backend.
- Consentimiento claro antes de contactar señalización, STUN o TURN.
- Mensajes de error útiles sin revelar internals o datos de red.

## Pruebas obligatorias

### Unitarias

- normalización y rechazo del código;
- vectores PBKDF2 y AES-GCM conocidos;
- transición completa de la máquina de estados;
- callbacks tardíos rechazados por `sessionId`;
- deduplicación y límite del historial;
- errores tipados y recuperación.

### Android/instrumentación

- bytes UDP preservados exactamente;
- host en 7777 y join con puerto alternativo;
- creación y cierre repetidos sin fuga de sockets;
- notificación, stop y liberación de locks;
- detección del paquete del juego;
- recreación de Activity y proceso.

### Integración

- conexión directa;
- fallback TURN;
- ICE restart;
- pérdida de señalización después de establecer P2P;
- cambio Wi-Fi/datos;
- expiración/renovación de credenciales;
- incompatibilidad de versión controlada.

## Criterios de aceptación

- La pantalla abre de inmediato y nunca queda en blanco o congelada.
- Crear/unirse tiene estados claros, cancelables y recuperables.
- El juego recibe los mismos datagramas que salen del peer remoto.
- La sesión continúa al abrir el juego y Android muestra una notificación honesta.
- Detener libera WebRTC, sockets, servicio y locks aunque se invoque más de una vez.
- No existen secretos Cloudflare en el APK.
- La URL de señalización puede cambiar sin modificar widgets ni lógica del juego.
- Una sala creada en nuestra aplicación acepta a la aplicación compatible y viceversa.
- Un fallo o rate limit del Worker produce backoff y un error recuperable, nunca un bucle agresivo.
- El backend compatible puede desactivarse o reemplazarse sin publicar otra arquitectura de pantalla.

## Decisiones pendientes antes de implementar código funcional

1. Elegir WebRTC nativo o una dependencia Flutter.
2. Confirmar si la primera entrega se distribuirá solo como build interna o como beta explícita con dependencia del Worker de terceros.
3. Definir el contrato versionado del Worker/Durable Object propio.
4. Definir máximo de peers y duración esperada de una sesión.
5. Confirmar versiones compatibles de SM64CoopDX y el flujo exacto dentro del juego.
6. Decidir si el historial de códigos estará activado por defecto o requerirá consentimiento.

## Recomendación ejecutiva

Implementar primero Fase 0 y Fase 1; después construir el adaptador compatible y validarlo mediante una matriz cruzada host/invitado contra la otra aplicación. Durante esa validación, mantenerlo en builds internas y medir respuestas, desconexiones y límites reales del Worker. Solo después decidir si la dependencia temporal es suficientemente estable para una beta explícita.

De esta forma, cuando el conector propio esté listo, el cambio queda contenido en `SignalingAdapter`; la pantalla, el estado, el historial, el puente UDP y la integración con SM64CoopDX permanecen iguales.
