# SM64 Intro — integración del menú y las ranuras

## Referencias y criterio visual

Se revisaron las seis capturas locales de `screenshots-new-theme-inapired/`.
Son referencias visuales, no assets que deban distribuirse. Muestran una
estructura común: cabecera oscura, fondo saturado, paneles oscuros, letras HUD,
botones cuadrados con iluminación superior/izquierda y sombra inferior/derecha.
La selección usa dorado. La captura de mods muestra una ranura verde con Mario
para activo y una ranura desaturada para inactivo. También muestra truncamientos
y solapamientos: no se reproducen esos problemas de distribución en el manager.

El modo claro utiliza fondo dorado con variación de luz, cabecera marrón y
paneles opacos marrones. «Claro» describe el entorno iluminado; los paneles
conservan texto claro sobre fondo oscuro como las referencias. El oscuro usa
azul nocturno, paneles azul profundo y dorado menos intenso. Los colores de
acción verde/azul se reservan para ranuras y botones; errores mantienen sus
roles semánticos. La fuente de menú de ROM identifica secciones; la de diálogo
sirve para descripciones, con la escala legible ya corregida. Los títulos
principales conservan glifos HUD. Se preservan acentos mediante fallback.

## Integración completa

1. `AppThemeId.sm64Intro` persiste `sm64_intro`; no depende del orden del menú.
2. `sm64_intro_theme.dart` define ambas paletas, geometría y tratamiento.
3. `AppThemeCatalog` registra Retro Manga, Mario 64 y SM64 Intro.
4. `AppearanceSelector` presenta el nombre mediante las cinco traducciones ARB.
5. `AppearanceNotifier.selectThemeWithRom` exige el mismo conjunto privado v2
   completo para ambos diseños de Mario. Una importación previa se reutiliza.
   Cancelar/fallar conserva el tema anterior; solo la confirmación guarda Hive.
6. `RetroTheme` comparte fuentes, iconos y tamaños de Mario mediante `isMario`;
   `isIntro` distingue fondos dorados/azules y paneles sin la piedra opaca del
   tema anterior. Los controles usan el marco de piedra teñido de azul.
7. `ThemeBackdrop` aplica el fondo compartido a las pantallas del engine
   principal. Las tarjetas conservan sus fotos y las superficies semánticas
   conservan su contraste.
8. `MarioRomAssetsPanel` permite gestionar la misma importación con ambos temas.
9. `MarioGameToggle` conserva el contrato `value/onChanged`: ranura verde con
   Mario guardado al activar; Mario nuevo en gris al desactivar. Área de toque
   de 64×48, estado semántico toggled y bloqueo mientras no hay callback.
10. `GameModActivationPanel` sigue leyendo el estado confirmado del provider;
    el dibujo no escribe configuración ni adelanta visualmente el resultado.
    Permisos revocados, operaciones activas y errores siguen los flujos existentes.

No se cambian Android, extracción ROM, formato v2, mods del juego ni el overlay.
La ROM se selecciona como documento, no como carpeta. No se añade permiso,
almacenamiento compartido, caché de imágenes nueva ni recursos del juego al APK.
El servicio carga las mismas familias una vez por engine; cada diseño consulta
el mismo snapshot observable. El overlay conserva su tema fijo independiente.

## Validación

El catálogo ejecuta las pruebas existentes de contraste en ambos modos para
cada tema. Las pruebas de selección ejercitan éxito/cancelación para Mario 64 y
SM64 Intro. Se verifica además identidad persistida, reutilización de fuentes,
paneles sin textura opaca y dimensiones/estado confirmado de la ranura.
Termux no tiene Flutter/Dart; formato, generación de localización, análisis y
pruebas se ejecutan en Actions. Pendiente revisión física: menú de temas,
claro/oscuro/sistema, drawer, catálogo, detalle, Ajustes, Biblioteca, cambio de
mod, fallo de escritura y escala de texto aumentada. Las capturas permanecen
locales. No se fusiona main ni se publica una release.
