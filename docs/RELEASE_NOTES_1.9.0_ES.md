## SM64CDPY v1.9.0 — Juega en compañía, prepara tu ROM y navega en cinco idiomas

La versión 1.9.0 añade el flujo multijugador Jugar, preparación local de ROM, una guía completa de Cómo jugar, francés e italiano, descripciones de mods localizadas, contenido multimedia de mods y una interfaz Manga pulida con entrada más rápida a Biblioteca y Partidas guardadas mediante caché persistente.

### Jugar con amigos

- Jugar es un destino principal. Crea una sala o introduce un código de ocho caracteres, copia o comparte la invitación como texto y abre SM64CoopDX desde el mismo flujo.
- El puente Android usa un servicio en primer plano solo durante una sesión activa, libera bloqueos de red y CPU al detenerse y muestra diagnósticos de conexión, tráfico y recuperación sin exponer direcciones IP.
- El consentimiento de red es explícito y versionado. La exclusión de optimización de batería es opcional, iniciada por el usuario y se vuelve a comprobar al regresar de Ajustes de Android.
- Los códigos recientes se guardan localmente con un límite pequeño. Los fallos terminales detienen señalización, WebRTC, UDP y servicio antes de reintentar.

### Configuración y herramientas de ROM

- La nueva guía Cómo jugar usa tarjetas temáticas, navegación por capítulos y acciones contextuales para instalar el juego Android, preparar la ROM, elegir la carpeta e instalar el primer mod.
- Preparar ROM detecta z64, v64 y n64 por cabecera, valida el volcado USA esperado, convierte de forma nativa por bloques y verifica la copia exportada sin modificar el archivo original.
- El progreso, cancelación, reintento y errores accionables mantienen la interfaz fluida en dispositivos con poca memoria; las copias preparada y guardada externamente aparecen como estados distintos.

### Interfaz, contenido multimedia y rendimiento

- Retro Manga incorpora navegación deslizante compacta, controles coherentes de papel y tinta y personalización ampliada en Inicio, Catálogo, Popular, Favoritos, Biblioteca, detalle del mod, Jugador, Partidas, Preparar ROM y Jugar.
- Manga Deluxe añade tipografías, gráficos optimizados, fondo móvil opcional, bienvenida compacta, navegación temática y diseños propios para ROM, partidas y multijugador.
- La música ambiental, los sonidos del menú y los sonidos de tarjetas de Inicio tienen controles independientes y persistentes de activación y volumen, con valores predeterminados prudentes.
- Biblioteca y Partidas guardadas muestran un snapshot persistido al instante y lo validan en segundo plano. El perfil del Jugador también se restaura sin reconstrucciones visibles innecesarias.
- El detalle de mods admite imágenes normalizadas, miniaturas de video y reproducción externa de YouTube con estados de carga y error acotados.

### Idiomas y datos del catálogo

- Francés e italiano se suman a inglés, español y portugués brasileño en la interfaz Flutter, diagnósticos compartidos y notificaciones nativas de Android.
- Las descripciones de los mods incluyen traducciones precalculadas al español, portugués brasileño, francés e italiano. El inglés original sigue siendo la fuente y un icono temático alterna entre idiomas sin conexión; los catálogos antiguos vuelven de forma segura al inglés.
- El idioma elegido persiste entre aperturas. Fechas, números, paginación, cursos y categorías Render96 usan presentación localizada.
- Touch Controls muestra autoría en listados, detalles y favoritos, con Release Soon cuando la fuente no incluye autor.

### Antes de publicar

- Esta candidata no obliga a actualizar. La fecha del manifiesto es provisional hasta la publicación.
- Falta validar físicamente continuidad multijugador, ajustes de batería, proveedores de ROM, poco espacio, rotación, layouts en cinco idiomas, cambio de idioma en descripciones de mods, multimedia y los APK de las tres ABI.
- El idioma de la burbuja flotante y el flujo planificado de desinstalación segura no forman parte de la versión 1.9.0.
