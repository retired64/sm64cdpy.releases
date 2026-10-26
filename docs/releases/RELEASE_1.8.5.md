# SM64CDPY 1.8.5 — preparación de la pantalla Jugador

Versión preparada en `main`: `1.8.5+24`. Esta guía reúne el alcance, los datos
de distribución y la puerta de salida; no crea el tag ni publica la release.

## Alcance

1. Añadir Jugador al drawer con edición de nombre y selección entre Mario,
   Luigi, Toad, Waluigi y Wario.
2. Editar los ocho grupos RGB del perfil: gorra, cabello, piel, guantes,
   overol, camisa, zapatos y emblema, con entrada hexadecimal y selector visual.
3. Mantener un borrador independiente hasta aplicar el perfil completo al juego.
4. Cargar y guardar presets compatibles en `user/palettes`.
5. Mostrar una vista 3D interactiva construida localmente desde la instalación
   del juego y la ROM USA conectada por el usuario, sin incluir esos recursos
   protegidos dentro del APK.
6. Actualizar personaje y colores sobre el mismo renderizador, permitir giro y
   conservar una vista compacta durante el desplazamiento sin recargas repetidas.
7. Guardar mediante el bloqueo ordenado de configuración, respaldo privado,
   relectura y verificación exacta que ya protege los controles de Biblioteca.

## Versión y distribución

| Campo | Valor |
|---|---|
| Pubspec / versionName | `1.8.5+24` / `1.8.5` |
| Build base | `24` |
| VersionCode arm32 / arm64 / x86_64 | `241` / `242` / `243` |
| APK arm32 | `Sm64CDPY-arm32.apk` |
| APK arm64 | `Sm64CDPY-arm64.apk` |
| APK x86_64 | `Sm64CDPY-x86_64.apk` |
| Tag previsto | `v1.8.5`, sin crear durante esta preparación |
| Actualización obligatoria | No: `forceUpdate: false` |
| Toolchain | Flutter 3.41.7, Dart 3.11.x, Java 17 |
| Android mínimo | API 24 |

`pubspec.yaml` es la autoridad de versión y build. El manifiesto canónico es
`release-manifests/v1.8.5.json`. Sustituir su `publishedAt` provisional por la
fecha real si la publicación se realiza otro día.

## Evidencia disponible

- [x] `flutter test`: 114 pruebas aprobadas después de integrar en `main`.
- [x] Compilación Kotlin y pruebas unitarias nativas correctas.
- [x] `flutter analyze lib`: sin errores ni warnings; quedan avisos informativos
  preexistentes fuera del alcance de Jugador.
- [x] Pruebas unitarias del perfil, serialización de colores y ciclo de vida de
  la vista previa.
- [x] Prueba física confirmada para cambio de personajes, paletas, scroll y
  conservación del renderizador.

## Puerta de salida

- [ ] Validar el manifiesto contra `pubspec.yaml` y generar previews EN/ES/PT-BR.
- [ ] Ejecutar el workflow de testing sobre el commit final de `main`.
- [ ] Descargar e instalar el APK arm64 firmado del workflow de testing.
- [ ] Verificar en al menos un dispositivo de gama baja y uno de gama media:
  carga inicial, giro, cambios rápidos, mini preview, background y reapertura.
- [ ] Verificar juego/carpeta/ROM ausentes, permiso SAF revocado y ROM no válida.
- [ ] Revisar nombre, presets, los ocho grupos de color y aplicación al juego.
- [ ] Confirmar secretos y las tres ABI antes de autorizar la publicación.
- [ ] Fijar la fecha definitiva, crear `v1.8.5` y publicar exclusivamente con el
  workflow oficial cuando exista autorización explícita.

La arquitectura, estados y límites del renderizador se documentan en
[PLAYER_3D_RENDERER.md](../PLAYER_3D_RENDERER.md).
