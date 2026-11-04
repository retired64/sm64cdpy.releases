## SM64CDPY v1.9.2 — Descargas más resistentes y Jugador animado

La versión 1.9.2 integra la rama de fallback R2 en main: prioridad opcional del mirror, soporte del catálogo enriquecido, activación de Biblioteca coherente con el juego y vistas articuladas de los cinco personajes de Jugador.

### Descargas y catálogo

- Un mirror Cloudflare R2 válido puede recuperar una descarga original no disponible o con contenido inválido. Preferir mirror invierte el orden sin eliminar el origen como respaldo.
- La app, la descarga manual y el overlay comparten la resolución de fuentes; cambiar de fuente conserva la identidad de operación y la cadena de instalación en segundo plano.
- El lector conserva metadata opcional de artefactos y compatibilidad con catálogos anteriores. Elegir una fuente no cambia el artefacto que se instala.

### Activación desde Biblioteca

- Las descripciones Lua largas siguen el truncado de encabezados del juego en lugar de invalidar un mod que sí puede leerse.
- Los scripts desactivados ilegibles ya no bloquean selecciones ajenas; se mantienen las comprobaciones de incompatibilidades activas.
- Tras confirmar una escritura, los interruptores hermanos se actualizan desde la selección real. La activación sigue configurando el próximo inicio del juego.

### Jugador animado

- El visor local WebView/Three.js reconstruye la jerarquía articulada de los cinco personajes y reproduce reposo derivado de la ROM del usuario. Una animación opcional inválida vuelve a la pose de referencia.
- La superficie AndroidView estable y el escalado uniforme evitan redimensionar repetidamente el buffer durante el desplazamiento vertical lento.
- Ambos workflows prueban el motor JavaScript local y verifican el grafo de módulos anidados dentro de cada APK antes de subir artifacts. No se incluyen ROM ni recursos de personajes extraídos.

### Preparación del lanzamiento

- La candidata 1.9.2+30 mantiene paquete, configuración de firma, Android mínimo y nombres de APK por ABI. No obliga a actualizar.
- El estado fusionado aún necesita su propia build de testing y comprobaciones físicas de descargas, activación, gestos del visor y ciclo de vida. El éxito de la rama de origen no demuestra un APK nuevo de release.
- La fecha del manifiesto es provisional hasta publicar. Preparar esta candidata no publica tag, GitHub Release, anuncio Discord ni actualización del sitio.
