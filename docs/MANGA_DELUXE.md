# Manga Deluxe — mapa de implementación

Revisión documental: 2026-10-26. El diseño está incluido en la línea 1.9.0;
este documento repara referencias que apuntaban a una guía inexistente.

## Componentes

- `lib/core/theme/app_theme_design.dart`: identidad persistida `manga_deluxe`.
- `lib/core/theme/app_theme_catalog.dart`: registro de diseños disponibles.
- `lib/core/theme/themes/manga_deluxe_theme.dart`: definición visual.
- `lib/presentation/providers/theme_provider.dart`: selección y persistencia de apariencia.
- `lib/presentation/providers/deluxe_visual_provider.dart`: opciones de movimiento e introducción.
- `assets/themes/manga_deluxe/`: recursos visuales empaquetados.
- `lib/services/ambient_music.dart` y `manga_menu_audio.dart`: servicios de audio compartidos.

## Límites de responsabilidad

La apariencia consume estado y presenta acciones. No es autoridad sobre
permisos, descargas, instalación ni recibos de Biblioteca. Las opciones visuales
no sustituyen el estado nativo de Android. El engine flotante es independiente;
no asumir que comparte providers con el principal.

Para las decisiones históricas de temas ver [CUSTOM_THEMES.md](CUSTOM_THEMES.md).
Para el alcance publicado ver [release 1.9.0](releases/RELEASE_1.9.0.md).
Las comprobaciones de apariencia y rendimiento requieren dispositivo físico;
esta reorganización documental no aporta nueva evidencia funcional.
