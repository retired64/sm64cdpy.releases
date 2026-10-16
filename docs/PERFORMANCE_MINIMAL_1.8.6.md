# Rendimiento visual y tema Minimalista — 1.8.6

Rama: `performance-minimal-1.8.6`, creada desde `main` después de 1.8.5.
Versión de desarrollo: `1.8.6+25`.

## Objetivo

Ofrecer una interfaz opcional de bajo costo para Android de gama baja y hacer
que Retro Manga sea fluido como diseño predeterminado, sin retirar Mario 64 ni
SM64 Intro. La optimización se concentra
primero en las dos rutas que mostraban mayor latencia perceptible: abrir el
drawer y entrar al detalle de un mod.

## Tema predeterminado

`retro_manga` vuelve a ser el diseño predeterminado porque las optimizaciones
del drawer y navegación eliminaron su latencia perceptible. `minimal` permanece
como alternativa de bajo costo en Ajustes. Usa colores planos, radio discreto, tipografía del sistema, borde
fino y cero sombra, inclinación, trama, franjas o painter de fondo. En este tema
los destinos del drawer son filas de texto sin iconos.

Una preferencia válida ya guardada no se migra: Minimalista, Retro Manga, Mario
64 y SM64 Intro se restauran normalmente. Preferencias ausentes o desconocidas
usan Retro Manga.

## Drawer

- Se sustituyeron todos los SVG por símbolos Material en los temas opcionales.
- Minimalista no construye iconos de destino.
- El encabezado recupera el logo raster de la app sin reintroducir SVG.
- Los enlaces sociales se retiraron del drawer y viven en Enlaces y recursos.
- Cada destino dejó de mantener un `AnimationController`, `ScaleTransition`,
  `AnimatedContainer` y `AnimatedDefaultTextStyle` propios.
- Selección y toque usan `InkWell` y decoración estática.
- Los botones sociales dejaron de tener controlador y escala individual.
- Se eliminaron la dependencia `flutter_svg` y 18 assets SVG del APK.
- Navegación, secciones, enlaces externos, versión y estado activo se conservan.

## Navegación y detalle

- `GoRouter` usa `NoTransitionPage`: no combina fade, escala de entrada y fade
  de salida al abrir una ruta.
- Detalle ya no ejecuta otro fade interno de 600 ms ni anima el color del app bar.
- Las imágenes de tarjeta y detalle dejaron de crear vuelos `Hero`.
- Imagen, descripción, changelog, favoritos, compartir e instalación conservan
  su comportamiento; el cambio es únicamente de presentación y composición.

## Persistencia y compatibilidad

Hive, clave `theme_id`, sigue siendo la fuente de verdad. `AppearanceNotifier`
es el único escritor y `themeDesignProvider` el lector reactivo. No se añadió
cache, réplica entre engines ni Future sin esperar. El overlay mantiene su tema
oscuro independiente y no lee esta selección.

## Validación

- [x] `flutter analyze lib --no-fatal-infos`: sin errores ni warnings.
- [x] 121 pruebas Flutter.
- [x] 4 pruebas Python del contrato de manifiestos.
- [x] Manifiesto `1.8.6+25` alineado con `pubspec.yaml`.
- [x] No quedan archivos SVG de interfaz ni dependencia `flutter_svg`.
- [ ] Perfilar apertura/cierre del drawer en dispositivo de gama baja.
- [ ] Medir tiempo desde toque hasta primer frame del detalle con imagen fría y cacheada.
- [ ] Revisar los cuatro diseños en claro/oscuro, texto grande y pantalla estrecha.

Los tests verifican que Minimalista desactiva fondos decorativos, tramas,
franjas, inclinación y sombras, y que los temas guardados continúan siendo
restaurables.
