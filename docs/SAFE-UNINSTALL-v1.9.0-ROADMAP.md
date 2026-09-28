# Roadmap — Desinstalación segura para SM64CDPY 1.9.0

> Funcionalidad futura. No forma parte del alcance ni bloquea el lanzamiento de
> `1.8.0`.

## Objetivo

Permitir desinstalar contenido instalado por SM64CDPY sin borrar archivos
ajenos, compartidos o modificados por el usuario. **Olvidar instalación** seguirá
siendo una acción distinta que elimina únicamente metadata privada.

Los recibos actuales conservan hasta 32 rutas centinela para comprobar
presencia. No representan un manifiesto completo y, por sí solos, no autorizan
una eliminación física.

## Fase 1 — Manifiesto completo y propiedad

- Registrar todas las rutas escritas por cada instalación, no solo centinelas.
- Diferenciar archivos nuevos, reemplazados y directorios creados por la app.
- Guardar tamaño y huella suficiente para reconocer modificaciones posteriores.
- Mantener un índice `ruta → artefactos propietarios` para detectar solapamientos.
- Persistir el manifiesto atómicamente desde Kotlin junto al recibo confirmado.
- Conservar compatibilidad con recibos anteriores sin habilitarles una
  desinstalación insegura.

## Fase 2 — Worker de desinstalación SAF

- Crear un plan antes de realizar cualquier eliminación.
- Eliminar solo archivos de propiedad exclusiva que todavía coincidan con el
  manifiesto instalado.
- Conservar archivos modificados, compartidos o cuya propiedad sea dudosa.
- Eliminar únicamente directorios creados por la app y que hayan quedado vacíos.
- Hacer el proceso idempotente y recuperable tras fallo o cierre de la app.
- Publicar resultados `completed`, `partiallyCompleted` y `failed` con detalle
  accionable.

## Fase 3 — Experiencia, historial y sincronización

- Añadir **Desinstalar** como mantenimiento separado de **Reinstalar** y
  **Olvidar instalación**.
- Mostrar confirmación previa y resumen de archivos conservados al terminar.
- Registrar el evento de desinstalación y retirar el recibo activo solo cuando
  el resultado lo permita.
- Invalidar Biblioteca/Hive y sincronizar catálogo, detalle, secciones
  especiales y overlay.
- Para instalaciones antiguas sin manifiesto completo, ofrecer reinstalar
  primero para habilitar la desinstalación segura.

## Criterios mínimos de aceptación

- Ninguna eliminación se decide por título, nombre de carpeta o escaneo
  aproximado.
- Un archivo compartido o modificado se conserva.
- ZIP, 7z y archivos sueltos funcionan en Mods y DynOS.
- Una actualización conserva la cadena de propiedad de versiones sustituidas.
- Permiso SAF revocado, archivos ausentes y reintentos tienen salida segura.
- Aplicación principal y overlay terminan mostrando el mismo estado.

