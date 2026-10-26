# SM64CDPY 1.9.0 — preparación de release

> Publicada como `v1.9.0`. Se conserva como referencia histórica.

Candidata integrada en `main`: **1.9.0+28**, tomando `v1.8.8` como base. Este
documento no crea el tag ni publica la release.

## Alcance consolidado desde 1.8.8

- **Jugar:** creación y unión por código corto, historial local acotado,
  invitación copiable/compartible como texto, apertura del juego, diagnósticos,
  consentimiento de red y acceso opcional a los ajustes de batería.
- **Motor de sesión Android:** WebView local aislado, señalización/WebRTC,
  puente UDP, servicio en primer plano, WakeLock/WifiLock solo durante la sesión,
  limpieza terminal y recuperación coherente.
- **Cómo jugar y ROM:** guía deslizable por capítulos; preparación local de ROM
  z64/v64/n64 aportada por el usuario, validación USA, conversión nativa acotada,
  cancelación, progreso y exportación SAF verificada.
- **Interfaz Manga:** menú slide de Retro Manga, nuevo Manga Deluxe, consistencia
  visual en las pantallas principales, gráficos WebP optimizados, música
  ambiental y sonidos de menú/tarjetas con controles independientes.
- **Carga percibida:** Biblioteca y Partidas guardadas muestran el último
  snapshot persistido y actualizan en segundo plano; el perfil de Jugador evita
  reconstrucciones visibles innecesarias.
- **Catálogo multimedia:** el detalle admite imágenes y miniaturas de video
  normalizadas; YouTube se abre mediante el manejador de URL de Android.
- **Descripciones localizadas:** traducciones precalculadas ES/PT-BR/FR/IT con
  icono temático para volver al inglés original, sin red ni IA en la app y con
  fallback seguro para catálogos antiguos.
- **Transiciones fluidas:** fade y deslizamiento cortos, sin escala de pantalla
  completa ni animación de la página anterior; el dock, los skeletons y las
  cargas iniciales no compiten con el cambio de pantalla.
- **Idiomas y créditos:** francés e italiano completos se suman a EN/ES/PT-BR,
  con selección persistente, notificaciones nativas localizadas y autoría de
  Touch Controls.
- **Android:** la aplicación se declara como juego mediante
  `android:appCategory="game"`.

## Distribución

| Campo | Valor |
|---|---|
| versionName / build | 1.9.0 / 28 |
| VersionCode arm32 / arm64 / x86_64 | 281 / 282 / 283 |
| Base comparada | v1.8.8 |
| Tag previsto | v1.9.0 (sin crear) |
| Manifiesto | release-manifests/v1.9.0.json |
| Actualización obligatoria | No |
| Android mínimo | API 24 |

Conservar `Sm64CDPY-arm64.apk`, `Sm64CDPY-arm32.apk` y
`Sm64CDPY-x86_64.apk`. El manifiesto es la autoridad para GitHub Releases,
Discord y la sincronización del sitio web. `publishedAt` está fechado para la
preparación del 24 de octubre de 2026 y debe ajustarse si la publicación ocurre
otro día.

## Validación completada antes del merge

- `flutter analyze lib`: sin problemas.
- `flutter test`: **520 pruebas aprobadas**.
- Pruebas de scripts: **16 aprobadas**, incluido el contrato de localización y el manifiesto.
- `./gradlew :app:compileDebugKotlin`: compilación correcta.
- `git diff --check`: limpio.
- Las advertencias Gradle restantes proceden de plugins externos del pub cache,
  no del código fuente de la aplicación.

## Puerta previa a la publicación

- Validar el manifiesto 1.9.0 contra `pubspec.yaml` y regenerar sus previews.
- Ejecutar una compilación Android después de añadir `appCategory="game"`.
- Revisar el diff final contra `v1.8.8`; la rama ya está integrada en `main` sin
  crear el tag.
- Ejecutar Testing en `main` y probar el APK arm64 firmado en un dispositivo
  físico de pocos recursos.
- Verificar sesiones host/invitado, regreso desde Ajustes de batería, cierre desde
  notificación, rotación, ROM/SAF, poco espacio, caché de Biblioteca/Partidas,
  multimedia, cambio de idioma en descripciones, fluidez de transiciones y
  layouts EN/ES/PT-BR/FR/IT.
- Confirmar la fecha, crear `v1.9.0` y lanzar el workflow oficial solo con
  autorización explícita.

## Exclusiones conocidas

- El idioma de la burbuja flotante no cambia en esta versión.
- La desinstalación segura documentada como roadmap no está incluida.
- La preparación de ROM no descarga, incluye, repara ni distribuye ROMs.
