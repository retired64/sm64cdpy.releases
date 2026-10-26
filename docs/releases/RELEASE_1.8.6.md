# SM64CDPY 1.8.6 — preparación de rendimiento visual

Versión integrada en `main`: `1.8.6+25`. Esta guía reúne el alcance, los datos
de distribución y la puerta de salida; no crea el tag ni publica la release.

## Alcance

1. Mantener Retro Manga como diseño predeterminado y ofrecer Minimalista como
   opción ligera en Ajustes.
2. Dar a Minimalista un lenguaje estricto basado en espacio y tipografía, sin
   fondos pintados, sombras, inclinaciones ni contenedores neutros innecesarios.
3. Reducir el costo del drawer eliminando SVG, controladores por destino y
   rellenos decorativos en Minimalista.
4. Conservar el logo raster de la aplicación y trasladar los enlaces sociales
   a Enlaces y recursos.
5. Hacer inmediatos los cambios de ruta y retirar el fade interno y los vuelos
   Hero del detalle de mods.
6. Preservar los cuatro diseños, sus modos claro/oscuro y cualquier selección
   válida ya guardada.
7. Ofrecer una decisión única y no bloqueante para instalar automáticamente
   después de descargar, conservando las elecciones de versiones anteriores.
8. Reabrir Player desde modelos y fotogramas persistentes, evitando reconstruir
   el personaje desde la ROM cuando sus fuentes no cambiaron.
9. Mostrar inmediatamente el último snapshot confirmado de Mods del juego y
   DynOS mientras la verificación SAF continúa en segundo plano.

## Versión y distribución

| Campo | Valor |
|---|---|
| Pubspec / versionName | `1.8.6+25` / `1.8.6` |
| Build base | `25` |
| VersionCode arm32 / arm64 / x86_64 | `251` / `252` / `253` |
| APK arm32 | `Sm64CDPY-arm32.apk` |
| APK arm64 | `Sm64CDPY-arm64.apk` |
| APK x86_64 | `Sm64CDPY-x86_64.apk` |
| Tag previsto | `v1.8.6`, sin crear durante esta preparación |
| Actualización obligatoria | No: `forceUpdate: false` |
| Toolchain CI | Flutter 3.41.7, Dart 3.11.x, Java 17 |
| Android mínimo | API 24 |

`pubspec.yaml` es la autoridad de versión y build. El manifiesto canónico es
`release-manifests/v1.8.6.json`. Su `publishedAt` es provisional y debe
actualizarse si la publicación ocurre en otra fecha.

## Evidencia disponible

- [x] `flutter analyze lib --no-fatal-infos`: sin errores ni warnings; conserva
  23 avisos informativos preexistentes.
- [x] Pruebas focalizadas de Player y Biblioteca: 8 aprobadas tras el merge.
- [ ] La suite Flutter completa llega a 131 pruebas y queda detenida en el caso
  de diálogos iniciales; debe corregirse o aislarse antes del workflow final.
- [x] Cuatro pruebas Python del contrato de manifiestos aprobadas.
- [x] Manifiesto validado contra `pubspec.yaml`.
- [x] APK debug construido localmente.
- [x] Rama 1.8.6 fusionada en `main` junto con el catálogo remoto más reciente.

## Puerta de salida

- [ ] Probar drawer, detalle y Minimalista en al menos un Android de gama baja.
- [ ] Revisar los cuatro diseños en claro/oscuro, texto grande y pantalla estrecha.
- [x] Fusionar el trabajo 1.8.6 a `main` sin crear todavía el tag.
- [ ] Ejecutar el workflow de testing sobre el commit final de `main`.
- [ ] Descargar e instalar el APK arm64 firmado del workflow de testing.
- [ ] Confirmar secretos, firma y las tres ABI.
- [ ] Fijar `publishedAt`, crear `v1.8.6` y ejecutar el workflow oficial solo
  con autorización explícita.

El criterio visual y los cambios de rendimiento se documentan en
[PERFORMANCE_MINIMAL_1.8.6.md](../PERFORMANCE_MINIMAL_1.8.6.md).
