# Arquitectura actual

Revisado para la preparación de `1.8.3+22` en `custom-themes` el 2026-10-13; sin merge ni publicación.

## Alcance

SM64CDPY es una aplicación Flutter orientada exclusivamente a Android. Combina una interfaz Flutter, integración nativa Kotlin y trabajo persistente de Android. El directorio `linux/` es scaffold generado y no representa soporte de escritorio.

## Capas

| Área | Ruta | Responsabilidad |
|---|---|---|
| Núcleo | `lib/core/` | Constantes, rutas, tema y utilidades |
| Datos | `lib/data/` | Lectura de JSON, caché, modelos y repositorio |
| Dominio | `lib/domain/` | Entidades e interfaz del repositorio principal |
| Presentación | `lib/presentation/` | Pantallas, widgets y estado Riverpod |
| Servicios | `lib/services/` | OTA, resolución de URLs y puentes con Android |
| Overlay | `lib/overlay/` | UI flotante y puente con el engine principal |
| Android | `android/app/src/main/kotlin/mods/sm64cdpy/` | SAF, WorkManager, extracción y canales Flutter |

La arquitectura es deliberadamente híbrida: el catálogo principal utiliza entidades/repositorio; las colecciones pequeñas tienen datasources y providers directos.

## Arranque

`lib/main.dart` configura orientaciones, downloader, Hive, información de versión, eventos de instalación y el puente del overlay. Después crea el árbol Riverpod y `MaterialApp.router`.

Existe una segunda entrada, `overlayMain()`, usada por `floaty_chatheads`. Este engine no comparte memoria estática con el engine principal. La comunicación se realiza con `FloatyChatheads.shareData`/streams y el estado persistente debe viajar por almacenamiento o canales, nunca por la suposición de memoria común.

## Datos y persistencia

- Los catálogos iniciales viven en `assets/db/`.
- `db/` contiene las copias publicadas que consumen las actualizaciones remotas.
- Hive guarda preferencias de interfaz y favoritos usados por providers.
- SharedPreferences guarda flags que también necesitan servicios/puentes, como `auto_install_mods`.
- El plugin Kotlin guarda las URI SAF (`tree_uri`, `dynos_tree_uri`) en sus propias SharedPreferences nativas y conserva permisos persistentes del árbol.
- `BackgroundInstallService` mantiene una vista en memoria de trabajos activos; WorkManager sigue siendo la autoridad para su ejecución.

Las operaciones nuevas usan una identidad de dominio versionada:
`contentKey = v1|section|contentId` y
`artifactKey/operationKey = contentKey|artifactId`. El `artifactId` prioriza
IDs estables de la fuente y utiliza un SHA-256 determinista cuando el catálogo
no los publica. Título, filename, URL, posición en un array y destino son
metadata, no identidad. La metadata viaja por SharedPreferences, MethodChannel,
ambos Workers, reconciliación y EventChannel. Las operaciones antiguas sin este
contrato todavía pueden restaurarse usando su `modName` legacy, pero nunca se
convierten por aproximación en una identidad nueva.

Después de una instalación automática confirmada, el Worker escribe un recibo
JSON por `artifactKey` en almacenamiento privado. El recibo contiene identidad,
destino lógico, snapshot de presentación y un manifiesto de hasta 32 archivos
centinela; no contiene la URI SAF ni la URL de descarga. Se reemplaza de forma
atómica antes de que WorkManager publique `SUCCEEDED`, por lo que no depende de
que alguno de los dos engines Flutter permanezca vivo.

Al iniciar, `InstallationLibraryRepository` solicita a Kotlin una instantánea
validada. Los recibos dañados o de esquema desconocido se aíslan sin impedir
leer los demás. Hive usa una caja exclusiva `installation_library_v1` como
proyección reconstruible para ordenar y consultar; nunca sustituye al recibo
nativo. Los recibos se deduplican por `artifactKey`, el historial por UUID del
Worker y ambos se ordenan por fecha UTC. Riverpod expone la carga como estado
asíncrono listo, parcial o fallido y vuelve a sincronizar tras instalaciones o
cambios de carpeta. Un coordinador de proceso mantiene Hive actualizado aunque
la pantalla de Biblioteca todavía no se haya construido.

La presencia actual se resuelve por separado mediante un verificador SAF
nativo. Solo consulta las rutas centinela del recibo, serializa los lotes y
reutiliza directorios resueltos; no escanea recursivamente las carpetas en cada
render. Sus estados `present`, `missing`, `unknown` y `permissionRevoked` son
una proyección reemplazable en Hive v2. SAF es la autoridad de presencia; el
recibo y el historial sobreviven a una carpeta cambiada o permiso perdido.

`InstallationActionSelector` es la política única que combina estas fuentes
con WorkManager y la versión solicitada por el catálogo. Una operación activa
siempre gana; `Instalado` requiere recibo más SAF presente; y `Actualizar` solo
se ofrece cuando una comparación numérica conservadora demuestra que el
catálogo es posterior. Los widgets renderizan la decisión y no reconstruyen
esta lógica localmente.

La fase de mantenimiento añade `InstallationVersionPolicy`: solo ordena
versiones numéricas punteadas y usa igualdad textual normalizada como fallback
sin atribuir precedencia a etiquetas arbitrarias. El índice de catálogo de
Biblioteca reutiliza las identidades canónicas de todas las secciones y omite
una actualización cuando no puede elegir con seguridad entre varios archivos.

Kotlin clasifica una instalación confirmada como `reinstall` si reemplaza el
mismo `artifactKey`, `update` si otro artefacto del mismo contenido tiene una
versión demostrablemente anterior, o `install` en los demás casos. Los recibos
anteriores sustituidos permanecen durables y conservan sus centinelas para
propiedad/descubrimiento; el recibo sustituto guarda esa relación incluso al
reinstalarse, pero la instantánea pública expone solo los activos. El historial
los presenta como reemplazados. Olvidar un contenido o retirar un
evento elimina únicamente metadata privada: ningún método de mantenimiento
borra archivos SAF.

El overlay consume esa misma política sin abrir Hive ni asumir memoria
compartida. Cada actualización del repositorio se anuncia en el engine
principal mediante un bus de invalidación que no conserva autoridad; el
`OverlayBridge` serializa una proyección versionada por el canal de
`floaty_chatheads`. El segundo engine mantiene únicamente la última respuesta
válida según `requestId`. Recibos nativos, SAF y WorkManager continúan siendo
las fuentes de verdad.

El descubrimiento de contenido previo o copiado por fuera de SM64CDPY vive en
una fuente separada. `InstallationDiscoveryScanner` recorre SAF únicamente al
abrir Biblioteca, al cambiar una carpeta o mediante refresco manual; nunca
durante cada render. El recorrido y la lectura de encabezados Lua están
acotados y se ejecutan fuera del hilo principal. Su caché nativa no es un
recibo: los hallazgos carecen deliberadamente de identidad de catálogo y solo
alimentan la vista Detectados de la proyección Hive v3. Un marcador Lua y sus
metadatos pueden elevar la confianza estructural, pero no autorizan a mostrar
Instalado ni Actualizar. DynOS y Touch Controls siguen siendo indistinguibles
por su carpeta física compartida.

## Navegación y estado

GoRouter define un `ShellRoute` para las pantallas principales y una ruta de detalle fuera del shell. Riverpod administra catálogo, filtros, paginación, favoritos, tema e idioma.

## Temas incluidos — rama custom-themes

Implementado el 2026-10-13; pendiente de Actions y matriz física. Ajustes separa
el diseño incluido (Retro Manga o Mario 64) del modo
claro/oscuro/sistema. `AppearanceNotifier` es el único escritor de `theme_id` y
`theme_mode` en Hive y publica una selección confirmada solo tras guardar.

`AppThemeDesign` y `AppThemeCatalog` definen paletas, formas, tipografía y
activación de decoración. `RetroTheme` conserva la API de acceso y ahora es una
ThemeExtension; los widgets Material y los personalizados comparten tokens.
MaterialApp y las barras leen la variante efectiva. No se recrean router ni
providers de operaciones por cambiar de diseño.

La raíz del overlay produce su ThemeData desde `RetroTheme.overlay()` y conserva
su política oscura fija, sin Hive ni mensajes nuevos de tema. El inventario de
cada Dart, el flujo y el procedimiento para añadir diseños están en
[cuatom_themea.md](../cuatom_themea.md). No se modificó Android nativo.

## Límites importantes

1. El proceso o cualquiera de los engines puede ser recreado por Android.
2. Las variables estáticas no sincronizan el engine principal y el overlay.
3. Dos instalaciones pueden ejecutarse en paralelo; nombres de trabajo, archivos temporales y notificaciones derivan de la identidad de artefacto/UUID, no del título.
4. Una URI SAF puede perder permisos y debe revalidarse antes de escribir.
5. Los eventos en memoria no sustituyen el estado persistido de WorkManager.

El checklist obligatorio para cambios de estado compartido está en [`../AGENTS.md`](../AGENTS.md).

### Presentación compartida de Ajustes

Los selectores de tema, modo e idioma reutilizan `SettingsExpansionGroup` y
`SettingsSelectionOption`, con animaciones de giro/expansión 200/220 ms. Mario 64
habilita superficies suaves únicamente en Ajustes mediante `softSettingsPanels`;
Retro mantiene su estilo. `LocaleSelector` espera el setter de idioma existente
antes de cerrar y controla loading local sin crear otra fuente persistente.
