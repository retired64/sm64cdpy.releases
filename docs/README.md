# Documentación de SM64CDPY

Este directorio es el punto de entrada técnico del proyecto. Los documentos de la tabla siguiente se contrastaron con el código de la versión `1.7.0+18`.

| Documento | Propósito | Estado |
|---|---|---|
| [Arquitectura](ARCHITECTURE.md) | Componentes, engines, persistencia y flujo de datos | Vigente |
| [Descargas y overlay](DOWNLOADS_AND_OVERLAY.md) | Flujo WorkManager/SAF, progreso y burbuja | Vigente |
| [Estado del proyecto](PROJECT_STATUS.md) | Funciones, riesgos y próximos pasos | Vigente |
| [Task Checklist v1.7.0](SM64CDPY-v1.7.0-TASK-CHECKLIST.md) | Plan incremental para estabilizar y publicar la pre-release | Activo |
| [Roadmap de Biblioteca e historial](INSTALLED-LIBRARY-ROADMAP.md) | Plan aislado para recibos de instalación, Hive, verificación SAF y estados de catálogo | Fases 0–1 completadas en `historial-hive` |
| [Biblioteca — investigación y contratos](INSTALLED-LIBRARY-PHASE-0.md) | Auditoría de catálogos/instalador, identidad canónica, recibo v1 y fixtures legales | Vigente para la rama `historial-hive` |
| [CI/CD](CI_CD.md) | Workflows, secretos y publicación | Vigente |
| [Compilación](../BUILDING.md) | Entorno y comandos de build | Vigente |
| [Archivo](archive/README.md) | Notas antiguas, referencias copiadas y prototipos | Histórico |

## Regla de mantenimiento

Cuando cambien versión mínima, dependencias, workers, canales de plataforma, persistencia, overlay o workflows, actualiza el documento correspondiente y la fecha de revisión del archivo. Las ideas y auditorías puntuales no deben presentarse como arquitectura vigente: deben añadirse al índice del archivo.

Última revisión contra el código: **2026-09-23**.
