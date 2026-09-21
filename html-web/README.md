# Sm64CdPy Mods CoopDX64 — Landing page

Sitio estático (HTML/CSS/JS, sin build step). Abre `index.html` directo
en el navegador o súbelo tal cual a GitHub Pages / Cloudflare Pages.

## Estructura

```
index.html
css/
  variables.css   → tokens de color, modo claro/oscuro
  base.css        → reset + tipografía
  halftone.css    → fondo de puntos y franjas diagonales
  layout.css      → header, hero, secciones, footer
  components.css  → chips, tags, botones, tarjetas
  carousel.css    → carrusel de capturas
  animations.css  → animación de entrada + reveal on scroll
  responsive.css  → media queries
js/
  theme.js        → toggle claro/oscuro
  carousel.js     → lógica del carrusel
  main.js         → reveal on scroll
assets/
  images/         → las 6 capturas fusionadas (dark/light)
  fonts/          → tus 5 fuentes, sin integrar todavía
```

## Fuentes — ya integradas

De tus 5 archivos, 4 quedaron enganchadas en `css/variables.css`,
cada una con un rol distinto para no saturar la página:

| Fuente | Archivo | Uso |
|---|---|---|
| Typeface Mario 64 | `TypefaceMario64.otf` | Wordmark del header + título del hero (el único momento "grande" de la página) |
| Super Mario 286 | `3.ttf` | El resto de los headings (kickers, tarjetas, botones) — tiene acentos/ñ completos |
| SuperMario64Font | `4hudFont.otf` | Números tipo HUD (los "01/02/03" de las feature cards) |
| SM64 Text | `2.otf` | Las píldoras (`retro-tag`): Open Source, Android, nombres de sección, etc. |

`1.ttf` ("Mario64") quedó copiada en `assets/fonts/` sin usar: no
tiene acentos ni puntuación y se parece mucho a Typeface Mario 64,
así que meterla también solo sumaba ruido. Si igual la quieres en
algún lado puntual (sin acentos), agrega su `@font-face` en
`variables.css` siguiendo el mismo patrón que las otras cuatro.

El body (párrafos) se queda en la fuente del sistema — las 4 fuentes
de juego son pixel-ish y a tamaño de párrafo pierden legibilidad.

## Íconos — sprite

`assets/icons/sprite.svg` es tu archivo completo (trae Discord,
GitHub, YouTube, Telegram, TikTok, X, etc.). En `index.html` dejé
embebidos solo los 3 símbolos que usa esta página (YouTube, Discord,
GitHub) dentro de un `<svg style="display:none">` justo después de
`<body>` — así el `<use href="#id">` funciona también abriendo el
HTML directo con doble clic, sin depender de un servidor (referenciar
un `.svg` externo con `<use>` falla en algunos navegadores bajo
`file://`).

Si más adelante quieres sumar Telegram o TikTok a la sección de
Comunidad, copia el `<symbol>` correspondiente desde
`assets/icons/sprite.svg` al bloque embebido y agrega una tarjeta
`.community-card` más — incluye tu link real cuando lo tengas.

## Agregar la 7ª captura al carrusel

`js/carousel.js` es data-driven por la cantidad de `.carousel__slide`
que haya en el HTML. Para sumar una más:

1. Copia la imagen a `assets/images/`.
2. En `index.html`, duplica un bloque `.carousel__slide` dentro de
   `.carousel__track` con la nueva imagen y su texto.

No hay que tocar el JS ni el CSS.

## SEO, favicon y datos estructurados (nuevo)

Se agregó:
- Favicons completos en `assets/icons/favicon/` (16/32/180/192/512 + `.ico`) generados desde tu ícono amarillo, más `site.webmanifest`.
- Imagen de Open Graph/Twitter Card en `assets/images/og-banner.jpg` (tu banner largo).
- Meta tags SEO (`title`, `description`, `keywords`, `canonical`, `robots`) apuntando a las keywords `sm64cdpy`, `sm64cdpy android`, `sm64coopdx mod manager android`.
- Open Graph + Twitter Card completos.
- Datos estructurados JSON-LD (`SoftwareApplication`, `Person` del autor, `WebSite`, `FAQPage`) para mejorar cómo Google entiende y muestra el sitio (E-E-A-T: autor identificable, entidad clara, contenido de soporte real).
- Sección `#faq` visible en la página (debe coincidir siempre con el `FAQPage` del `<head>`).
- Barra de confianza (versión / tamaño / Android mínimo / última actualización) bajo el CTA del hero, y línea equivalente en el footer.
- `robots.txt` y `sitemap.xml` en la raíz.
- Fix del menú en mobile: antes los links del nav simplemente desaparecían bajo 600px sin alternativa; ahora hay una hamburguesa funcional (`js/nav.js`) que despliega el menú.

### ⚠️ Placeholder que DEBES reemplazar antes de publicar

- `TU-DOMINIO-AQUI.com` → tu dominio real (aparece en canonical, og:url, og:image, twitter:image, JSON-LD, `robots.txt` y `sitemap.xml`). Es el único dato que falta: no puedo saberlo hasta que elijas dónde vas a alojar el sitio.

Todo lo demás (versión, tamaño, Android mínimo, fecha de release, arquitecturas disponibles) ya son datos reales, verificados contra el release v1.6.2 en GitHub y tu `build.gradle.kts` (`minSdk = 24` → Android 7.0+):

- Versión: **1.6.2**
- Tamaño: **~22 MB** (build arm64)
- Android mínimo: **7.0+** (API 24)
- Última actualización: **28 jul 2026**
- Variantes: arm64 (recomendado), arm32, x86_64

No se inventaron ratings, número de descargas ni testimonios: Google penaliza datos estructurados o señales de confianza que no reflejan la realidad, así que esos campos solo deben agregarse con datos reales.

## Persistencia del tema

El toggle de tema arranca según `prefers-color-scheme` del sistema y
luego se guarda solo en memoria durante la sesión (no usa
`localStorage`). Si despliegas el sitio de verdad (GitHub Pages,
Cloudflare, etc.), puedes sumar un par de líneas en `js/theme.js`
para guardar la elección en `localStorage` y que persista entre
visitas.
