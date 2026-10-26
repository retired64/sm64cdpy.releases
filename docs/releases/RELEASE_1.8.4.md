# SM64CDPY 1.8.4 — preparación de Biblioteca más fluida

Rama de trabajo: `library-performance-1.8.4`, basada en `main` después del
lanzamiento oficial 1.8.3. Versión preparada: `1.8.4+23`. Esta guía acompaña la
implementación; no publica ni autoriza el merge a `main`.

## Alcance

1. Cargar datos de Biblioteca bajo demanda según la sección abierta, para que
   Mods del juego/DynOS no inicialicen recibos e información remota de
   Actualizaciones.
2. Reutilizar el snapshot de activación al navegar entre pestañas y evitar una
   lectura redundante cuando se monta otra vez el panel.
3. Revalidar snapshots tras cambio de carpeta, instalación, reanudación con Mods
   del juego activo, refresco manual o al volver a montar el panel con datos de
   más de 30 segundos.
4. Reflejar enseguida la selección visual tras la confirmación, guardar mediante
   una cola silenciosa y revertir con aviso si la operación nativa falla.
5. Validar directamente el Lua o pack solicitado, preservar precedencia de las
   dos rutas y devolver la confirmación de escritura sin reconstruir todo el
   catálogo.
6. Mantener la edición lossless de `sm64config.txt`, respaldo privado,
   verificación de bytes, exclusión durante instalaciones y comprobación del
   tamaño de Lua habilitado.

## Versión y distribución

| Campo | Valor |
|---|---|
| Pubspec / versionName | `1.8.4+23` / `1.8.4` |
| Build base | `23` |
| VersionCode arm32 / arm64 / x86_64 | `231` / `232` / `233` |
| Tag previsto | `v1.8.4`, sin crear durante esta preparación |
| Actualización obligatoria | No: `forceUpdate: false` |
| Toolchain | Flutter 3.41.7, Dart 3.11.x, Java 17 |
| Android mínimo | API 24 |

`pubspec.yaml` sigue siendo autoridad de versión/build. Reemplazar
`publishedAt` provisional en el manifiesto por la fecha real antes de publicar.

## Evidencia y puerta de salida

- [ ] Flutter analyze y pruebas en GitHub Actions.
- [ ] Build APK arm64 de testing.
- [ ] Compilación Kotlin y pruebas nativas.
- [ ] Comparación de tiempos y comportamiento en dispositivo Android real.
- [ ] Revisión de los cinco idiomas y preview de release.
- [ ] Rebase/merge revisado contra `main` antes de publicación.
- [ ] Tag, release y APKs solo mediante el flujo oficial autorizado.

No se afirma un objetivo físico de menos de un segundo. La respuesta visual es
inmediata; escritura, lectura de verificación y escaneo inicial dependen del
proveedor SAF. Detalle técnico y matriz: [LIBRARY_PERFORMANCE.md](../LIBRARY_PERFORMANCE.md).
