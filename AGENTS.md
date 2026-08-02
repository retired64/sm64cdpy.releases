Instrucción permanente para este proyecto — aplica esto ANTES de dar por
terminada cualquier tarea que toque estado compartido, no solo cuando te
lo pida explícitamente.

Contexto del proyecto: hay estado que vive en más de un lugar a la vez —
SharedPreferences como fuente de verdad, pero cacheado en variables
estáticas en memoria (OverlayBridge._autoInstall, BackgroundInstallService
._infoMap); dos engines de Flutter separados (main y overlay) que no
comparten memoria; y varios Workers de Android corriendo en paralelo con
IDs/notificaciones que pueden colisionar. El bug de auto-install (toggle
en Settings escribía en SharedPreferences, pero OverlayBridge nunca se
enteraba porque tenía su propio caché sin invalidar) es el ejemplo
canónico de esta clase — y es fácil que se repita en otro lugar sin que
nadie lo note hasta que un usuario lo reporta.

Cada vez que agregues, muevas, o toques CUALQUIER valor que se lea desde
más de un lugar del código (una preferencia, un flag, un estado
cacheado), corre este checklist antes de decir que terminaste:

1. IDENTIFICA TODOS LOS ESCRITORES Y LECTORES.
   Antes de tocar una preferencia/flag/estado, busca con grep TODOS los
   lugares que la escriben y TODOS los que la leen (no asumas que ya los
   conoces por el nombre de la tarea). Si hay más de un lector cacheando
   el valor en memoria (variable estática, campo de State, etc.), cada
   escritor tiene que poder invalidar/refrescar cada uno de esos cachés.

2. SI CACHEAS ALGO EN MEMORIA, PREGÚNTATE: "¿QUIÉN LO INVALIDA?"
   Un `static bool`/`static String`/etc. que se llena una vez en init() y
   nunca más se actualiza es una bandera roja automática. O bien: (a) el
   método que lo refresca es público y hay un call site real desde cada
   lugar donde el valor de origen cambia, o (b) no deberías cachearlo en
   memoria — leelo directo de la fuente cada vez (aceptable si no es un
   hot path; si sí lo es, usa (a)).

3. CRUCE DE ENGINES/ISOLATES: nunca asumas que una variable estática se
   comparte entre el engine principal y el engine del overlay — NO se
   comparten memoria. Cualquier estado que necesite viajar entre ambos
   tiene que pasar por algo multi-isolate-safe: SharedPreferences,
   MethodChannel/EventChannel, o el propio WorkManager. Antes de leer una
   variable estática desde código que corre en el overlay, confirma en
   qué engine vive esa clase.

4. IDs/CLAVES QUE SE REPITEN ENTRE INSTANCIAS PARALELAS: si algo puede
   correr más de una vez en simultáneo (dos descargas, dos Workers, dos
   notificaciones), cualquier ID/clave fijo compartido entre instancias
   es sospechoso — verifica que esté derivado de algo único por instancia
   (nombre del mod, workId), no una constante.

5. FUTURES SIN AWAIT: si agregas una llamada async dentro de una función
   que no la espera (fire-and-forget), dilo explícitamente en tu resumen
   aunque no sea un bug hoy — es la forma más común en que este tipo de
   desincronización se cuela sin que nadie lo note en el review.

6. BÚSQUEDA DE HERMANOS: cuando arregles un bug de esta clase en un
   archivo, busca con grep el mismo patrón (mismo tipo de caché estático,
   mismo tipo de ID fijo, mismo tipo de Future sin await) en TODO el
   proyecto, no solo en el archivo que te pedí tocar — no asumas, revisa,
   y dilo explícitamente en el resumen aunque la respuesta sea "no
   encontré ninguno más" (como ya hiciste bien la vez pasada con el punto
   3 del auto-install — seguí haciendo exactamente eso, así de explícito).

Cuando termines cualquier tarea que toque estado compartido, tu resumen
final DEBE incluir una sección "Verificación de sincronización de estado"
respondiendo: ¿qué otros lugares leen/escriben este mismo valor? ¿quedaron
todos sincronizados? ¿hay algún caché en memoria nuevo que no se invalida
automáticamente? Si la respuesta a la última es "sí, pero es intencional
porque X", decilo — no lo dejes implícito.