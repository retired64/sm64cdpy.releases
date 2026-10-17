# Prueba de iconos PNG en el drawer Retro Manga

Rama experimental: `test-retro-drawer-png-1.8.6`, derivada de
`performance-minimal-1.8.6`. No forma parte de la candidata 1.8.6 hasta que se
pruebe en hardware de bajos recursos.

## Construcción

- Retro Manga recupera los iconos ilustrados del drawer.
- Minimalista continúa sin iconos y Mario 64/SM64 Intro conservan sus símbolos
  Material, por lo que la prueba no altera sus contratos visuales.
- Los SVG históricos se rasterizaron una sola vez a PNG de 64 × 64, con canal
  alfa, paleta indexada de hasta 128 colores y metadatos eliminados.
- El lienzo se crea transparente antes de interpretar cada SVG; los 13 PNG
  fueron verificados con alfa real en sus esquinas para evitar recuadros blancos
  en el modo oscuro.
- Flutter solicita una decodificación acotada a 64 × 64 mediante `cacheWidth`
  y `cacheHeight`; no se añade `flutter_svg` ni parseo vectorial en ejecución.
- Los destinos siguen siendo widgets estáticos: no regresan los controladores,
  escalas ni contenedores animados que penalizaban la apertura del drawer.
- Biblioteca y Jugador ya utilizaban símbolos Material en el drawer histórico;
  se conservan porque son más baratos que añadir otros bitmaps.

## Peso

Los 13 PNG ocupan aproximadamente 15 KB de contenido (52 KB de bloques en el
sistema de archivos). Sustituyen cerca de 300 KB de SVG originales, incluido un
`favorites.svg` de aproximadamente 239 KB.

## Prueba recomendada

1. Abrir y cerrar el drawer diez veces después de un arranque frío.
2. Repetir después de navegar por Catálogo, Biblioteca y Detalle.
3. Comparar Retro Manga con Minimalista y observar tirones, tiempo al primer
   frame y memoria gráfica en un dispositivo de gama baja.
4. Revisar tema claro/oscuro y el estado activo de cada destino.

Si la apertura permanece fluida, esta variante puede incorporarse a la rama de
release. Si vuelve el retraso, basta descartar esta rama: la candidata base no
queda modificada.
