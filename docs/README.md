# Documentación de SM64CDPY

Este directorio es el punto de entrada técnico del proyecto. `1.8.5+24` ya se
publicó oficialmente; `1.8.6+25` está en desarrollo. Otros documentos
conservan su fecha y alcance de revisión explícitos.

| Documento | Propósito | Estado |
|---|---|---|
| [Release 1.8.3](RELEASE_1.8.3.md) | Alcance, notas localizadas y evidencia del lanzamiento oficial | Publicada; referencia histórica |
| [Preparación de release 1.8.4](RELEASE_1.8.4.md) | Versión/build y mejoras de fluidez de Biblioteca | Publicada; referencia histórica |
| [Rendimiento de Biblioteca](LIBRARY_PERFORMANCE.md) | Cargas diferidas, snapshot reutilizado, activación inmediata y consistencia SAF | Incluido desde 1.8.4; referencia técnica |
| [Preparación de release 1.8.5](RELEASE_1.8.5.md) | Versión/build, pantalla Jugador, vista 3D y puerta de publicación | Preparada en `main`; pendiente del workflow final |
| [Renderizador 3D de Jugador](PLAYER_3D_RENDERER.md) | Arquitectura, recursos locales, ciclo de vida y límites de la vista previa | Implementado; ampliar matriz física de GPU/WebView |
| [Rendimiento visual 1.8.6](PERFORMANCE_MINIMAL_1.8.6.md) | Tema Minimalista predeterminado, drawer, navegación, detalle y eliminación de SVG | Implementado; pendiente perfil físico |
| [Temas propios incluidos](../cuatom_themea.md) | Implementación, inventario Dart, persistencia y flujo Termux/Actions | Incluidos desde 1.8.3; referencia técnica |
| [Arquitectura](ARCHITECTURE.md) | Componentes, engines, persistencia y flujo de datos | Vigente |
| [Descargas y overlay](DOWNLOADS_AND_OVERLAY.md) | Flujo WorkManager/SAF, progreso y burbuja | Vigente |
| [Contrato de la base de mods](CATALOG_DATABASE_CONTRACT.md) | Esquema v2, identidad durable, resolutores y publicación segura | Vigente |
| [Estado del proyecto](PROJECT_STATUS.md) | Funciones, riesgos y próximos pasos | Vigente |
| [Task Checklist v1.7.0](SM64CDPY-v1.7.0-TASK-CHECKLIST.md) | Registro del plan de estabilización de la línea 1.7 | Referencia histórica |
| [Roadmap de Biblioteca e historial](INSTALLED-LIBRARY-ROADMAP.md) | Plan aislado para recibos, Hive, verificación SAF, overlay, descubrimiento y mantenimiento | Fases 0–8 completas; Fase 9 implementada y pendiente de validación física |
| [Roadmap de desinstalación segura 1.9.0](SAFE-UNINSTALL-v1.9.0-ROADMAP.md) | Manifiesto de propiedad, Worker SAF y experiencia de desinstalación | Futuro; fuera de 1.8.0 |
| [Biblioteca — investigación y contratos](INSTALLED-LIBRARY-PHASE-0.md) | Auditoría de catálogos/instalador, identidad canónica, recibo v1 y fixtures legales | Vigente para la rama `historial-hive` |
| [Checklist de propiedad intelectual y contenido](IP-CONTENT-RISK-CHECKLIST.md) | Evaluación preventiva, procedencia, permisos, retiradas y decisiones para app/web | Planificación; requiere criterio y revisión jurídica |
| [CI/CD](CI_CD.md) | Workflows, secretos y publicación | Vigente |
| [Compilación](../BUILDING.md) | Entorno y comandos de build | Vigente |
| [Archivo](archive/README.md) | Notas antiguas, referencias copiadas y prototipos | Histórico |

## Regla de mantenimiento

Cuando cambien versión mínima, dependencias, workers, canales de plataforma, persistencia, overlay o workflows, actualiza el documento correspondiente y la fecha de revisión del archivo. Las ideas y auditorías puntuales no deben presentarse como arquitectura vigente: deben añadirse al índice del archivo.

Última revisión: **2026-10-15**.

- [Activación de mods desde Biblioteca](GAME_MOD_ACTIVATION.md): contrato del juego, SAF, edición verificada, recuperación y pruebas.

- [Preparación de merge/release 1.8.3](RELEASE_1.8.3.md): alcance final, previews EN/ES/PT-BR, evidencia, checklist y publicación autorizada.
- [Mejoras de fluidez de Biblioteca 1.8.4](LIBRARY_PERFORMANCE.md): fuentes de demora, nueva política de carga/invalidación y límites de latencia SAF.


## Mario 64: recursos locales y menú original

Se integra la importación opcional de 15 texturas desde una ROM vanilla US del
usuario, sin modificar el juego ni incluir imágenes extraídas en el APK. Marcos,
selección, fondo de Biblioteca/Ajustes y contadores siguen el tema Mario; Retro y
overlay conservan su diseño. Plan, contrato, persistencia, cancelación y matriz
de pruebas en [MARIO_ROM_THEME.md](MARIO_ROM_THEME.md). Validado en [Testing #192](https://github.com/retired64/sm64cdpy.releases/actions/runs/38613827573): análisis, 83 tests Flutter,
APK arm64 y tests Kotlin correctos para `f23034a`. Sigue pendiente la matriz
física con ROM real; estos tests usan datos sintéticos y no una ROM del usuario.


## Reconstrucción Mario 64 v2 — nueva validación pendiente

Se sustituye la interpretación de 15 texturas débiles por 151 imágenes y tres
fuentes privadas derivadas de ROM: materiales opacos, cielos Clouds/BBH, cursor,
HUD, tipografías y marcos cuadrados. Se conectan todas las pantallas y widgets
principales. La selección de Mario coordina importación antes de guardar tema;
v1 conserva sus recursos mientras se pide reimportación. Contrato actual en
[MARIO_ROM_THEME.md](MARIO_ROM_THEME.md). La evidencia #192 valida v1, no este cambio v2.

- [SM64 Intro: diseño e integración](SM64_INTRO_THEME.md).

- [Conexión unificada de la carpeta del juego](UNIFIED_GAME_FOLDER.md).
