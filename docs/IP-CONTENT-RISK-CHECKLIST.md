# Checklist de propiedad intelectual y contenido — SM64CDPY

> Documento de planificación y decisión. No constituye asesoría jurídica ni
> certifica que el proyecto cumpla las leyes de una jurisdicción determinada.
> Antes de una distribución amplia, monetización o publicación en una tienda,
> conviene obtener una revisión profesional de propiedad intelectual.

| Campo | Estado de referencia |
|---|---|
| Proyecto | SM64CDPY — aplicación Android y sitio web oficial |
| Alcance | Marca, catálogo, descargas, mods, imágenes, textos y respuesta a reclamaciones |
| Evaluación revisada | Riesgo práctico bajo-medio (`2.5–3/10`), sujeto a mantener el modelo descrito |
| Objetivo | Convertir el proyecto en un gestor independiente de contenido autorizado y trazable |
| Última revisión | 2026-09-27 |

## 1. Contexto y criterio

SM64CDPY no incluye ni instala ROMs, claves, firmware, SM64CoopDX, su port para
Android ni una copia completa de un juego de Nintendo. Tampoco solicita una ROM,
comprueba que exista ni enseña a obtener archivos del juego: su alcance comienza
en el catálogo de mods y termina en las carpetas de contenido elegidas por el
usuario. El catálogo principal contiene principalmente código Lua publicado por
la comunidad para SM64CoopDX; DynOS y otros recursos pueden incluir archivos
creados por sus autores con herramientas como Blender. La aplicación conserva
título, autor, fechas, versiones y procedencia, y recupera las descargas desde
la fuente publicada para cada recurso. Estas diferencias son importantes frente
a servicios dedicados a piratería.

La revisión no requiere certificar jurídicamente miles de mods uno por uno. El
control proporcionado debe basarse en la procedencia y moderación de la fuente,
con una comprobación directa para catálogos curados por SM64CDPY y una vía para
corregir o retirar excepciones. El código, modelos, voces comunitarias, imágenes
y descripciones siguen perteneciendo a sus respectivos autores aunque no sean
material de Nintendo.

El caso de James «Archbox» Williams no debe interpretarse como una condena por
crear mods o moderar una comunidad. La sentencia de 2026 fue dictada en rebeldía
en un asunto que atribuía al demandado la operación y promoción de servicios que
distribuían copias no autorizadas de juegos de Nintendo Switch. Sirve como
recordatorio de la respuesta agresiva de Nintendo frente a distribución y
facilitación de piratería, pero no es jurídicamente equivalente a SM64CDPY.

Un aviso de «proyecto no oficial» ayuda a evitar confusión sobre afiliación,
pero no concede derechos sobre marcas, imágenes, música, modelos, código,
descripciones ni archivos de terceros.

## 2. Límites que el proyecto no debería cruzar

- [ ] No incluir, alojar, enlazar deliberadamente ni ayudar a localizar ROMs.
- [ ] No distribuir ejecutables que incorporen datos protegidos del juego.
- [ ] No incluir claves, firmware, BIOS ni credenciales de servicios.
- [ ] No ofrecer herramientas o instrucciones cuyo propósito sea eludir medidas
      tecnológicas de protección.
- [ ] No incorporar en el futuro flujos de ROMs o parches de ROM dentro del
      gestor de mods sin una revisión jurídica y técnica separada.
- [ ] No aceptar música, voces, modelos, texturas u otros recursos extraídos de
      juegos comerciales sin permiso verificable.
- [ ] No presentar el proyecto como oficial, aprobado, asociado o patrocinado
      por Nintendo, Super Mario 64 o SM64CoopDX.
- [ ] No vender mods ni vincular donaciones, suscripciones o acceso «VIP» con
      contenido de terceros no autorizado.

Si una funcionalidad futura necesita cualquiera de estos elementos, detener la
implementación y solicitar revisión jurídica antes de publicarla.

## 3. Checklist prioritario de producto

### P0 — Antes de una publicación o promoción amplia

- [ ] Revisar el catálogo y retirar entradas que sean ROMs, compilaciones con
      datos del juego, material de elusión o paquetes de procedencia dudosa.
- [ ] Auditar primero las secciones mantenidas directamente por SM64CDPY: VIP,
      DynOS, Touch Controls y cualquier fuente que no sea el catálogo oficial de
      SM64CoopDX.
- [ ] Confirmar por escrito si SM64CoopDX permite reutilizar su catálogo,
      descripciones, estadísticas, imágenes y enlaces.
- [ ] Sustituir recursos de marca por identidad visual original cuando no sean
      necesarios para indicar compatibilidad.
- [ ] Comprobar que el icono, el banner, las capturas y el sitio no usen arte,
      personajes, logotipos o tipografías oficiales como identidad propia.
- [ ] Revisar el nombre y subtítulo público para que `SM64` describa
      compatibilidad y no parezca el nombre de una aplicación oficial.
- [ ] Publicar un canal de contacto funcional para titulares de derechos y
      autores de mods.
- [ ] Poder desactivar remotamente una entrada reclamada sin esperar una nueva
      versión del APK.
- [ ] Solicitar una consulta breve con un abogado de propiedad intelectual que
      considere las jurisdicciones relevantes para el desarrollador, hosting y
      distribución.

### P1 — Procedencia y autorización del catálogo

- [ ] Definir una política pública de contenido aceptado y rechazado.
- [ ] Guardar para cada mod un identificador estable, autor, fuente original,
      URL de publicación, licencia y fecha de revisión.
- [ ] Registrar si existe permiso expreso para enlazar, redistribuir o mantener
      un espejo del archivo.
- [ ] Distinguir claramente entre enlace al autor y archivo alojado por
      SM64CDPY.
- [ ] Conservar hash y versión del archivo revisado para detectar sustituciones
      posteriores en una URL existente.
- [ ] Añadir estados internos: `pendiente`, `verificado`, `restringido`,
      `retirado` y `bloqueado`.
- [ ] No interpretar disponibilidad pública como licencia para redistribuir.
- [ ] No interpretar atribución o crédito como sustituto del permiso.
- [ ] Solicitar al remitente que declare que tiene autoridad para publicar el
      contenido y que identifique dependencias o recursos de terceros.
- [ ] Mantener las evidencias de autorización en un registro privado; no
      incorporar correos, datos personales ni documentos confidenciales al
      repositorio público.

### P1 — Descargas y almacenamiento

- [ ] Preferir fuentes controladas por el autor del mod.
- [ ] Evitar espejos propios salvo que exista permiso explícito y conservado.
- [ ] Mostrar autor y fuente antes de iniciar una descarga.
- [ ] Bloquear inmediatamente URLs retiradas, incluso en catálogos antiguos ya
      descargados por la aplicación.
- [ ] Aplicar una lista remota firmada o verificable de contenido bloqueado.
- [ ] Evitar que fallos o redirecciones conviertan una URL aprobada en una
      descarga desde un dominio no revisado.
- [ ] Si en el futuro se usa Cloudflare R2, tratar cada archivo alojado allí
      como una redistribución directa y exigir evidencia de permiso.

### P1 — Aplicación, web y presentación pública

- [ ] Mantener visible que SM64CDPY es independiente y no oficial.
- [ ] Usar una redacción precisa: la aplicación obtiene archivos desde fuentes
      externas; no afirmar que «no redistribuye» sin revisar jurídicamente el
      significado aplicable al flujo de descarga directa.
- [ ] No sugerir que todos los mods son seguros, legales o aprobados; comunicar
      solamente lo que el proceso de revisión pueda demostrar.
- [ ] Crear páginas accesibles de Política de contenido, Propiedad intelectual,
      Solicitud de retirada, Privacidad y Términos de uso.
- [ ] Mantener coherentes esas páginas entre la aplicación y `sm64cdpy.org`.
- [ ] Revisar también metadatos SEO, Open Graph, textos de GitHub Releases y
      descripciones de tiendas; el aviso no debe vivir únicamente dentro de la
      aplicación.
- [ ] Verificar los requisitos de propiedad intelectual de Google Play antes de
      preparar su ficha o enviar una versión.

### P2 — Canal específico de corrección y retirada

- [ ] Añadir «Reportar este mod» en la pantalla de detalle.
- [ ] Añadir «Solicitar corrección o retirada» en la aplicación y el sitio web.
- [ ] Incluir automáticamente título, identificador, versión y fuente del mod,
      sin adjuntar datos personales del usuario innecesariamente.
- [ ] Dirigir la solicitud a un canal administrado por SM64CDPY.
- [ ] Mantener el contacto general por Discord mientras no exista el formulario
      específico.
- [ ] Permitir desactivar una entrada reclamada sin esperar una nueva versión
      del APK.

## 4. Flujo propuesto para incorporar un mod

```text
Propuesta o descubrimiento
  -> identificar autor y fuente original
  -> declarar licencia, permisos y contenido de terceros
  -> revisar archivo y procedencia
  -> rechazar ROM/elusión/recursos extraídos no autorizados
  -> registrar evidencia y hash
  -> aprobar y publicar
  -> supervisar cambios o reclamaciones
  -> mantener, restringir o retirar
```

### Criterios mínimos de aprobación

- [ ] Se conoce al autor o responsable de la publicación.
- [ ] La fuente original es verificable.
- [ ] El derecho a enlazar o redistribuir está documentado según corresponda.
- [ ] El archivo no contiene una copia completa del juego ni material de
      elusión.
- [ ] Las dependencias y recursos de terceros están identificados.
- [ ] La ficha atribuye correctamente sin insinuar respaldo oficial.
- [ ] Existe una vía real para retirar el contenido.

Si alguno de estos puntos no puede comprobarse, la decisión predeterminada debe
ser dejar la entrada pendiente, enlazar únicamente a una página informativa o
no publicarla.

## 5. Solicitudes de retirada y respuesta a incidentes

### Información que debe poder recibir el proyecto

- Identidad y datos de contacto del reclamante.
- Obra, marca o contenido afectado.
- URL, identificador y versión exacta de la entrada reclamada.
- Explicación de la titularidad o autorización para actuar.
- Declaraciones y firma que requiera la legislación aplicable.

### Procedimiento operativo

- [ ] Acusar recibo sin admitir responsabilidad.
- [ ] Preservar privadamente la solicitud y la versión del catálogo afectada.
- [ ] Desactivar preventivamente el enlace cuando la reclamación sea plausible
      o exista riesgo inmediato.
- [ ] Evitar borrar evidencias necesarias para investigar el origen.
- [ ] Contactar al autor o proveedor del mod sin exponer datos privados del
      reclamante indebidamente.
- [ ] Solicitar asesoría antes de presentar una contranotificación o rechazar
      formalmente una reclamación.
- [ ] Documentar la resolución: restaurado, corregido, retirado o bloqueado.
- [ ] Bloquear reincidencias y URLs alternativas del mismo archivo cuando sea
      necesario.
- [ ] Si llega una carta, citación o demanda, no ignorarla; conservarla y
      remitirla inmediatamente a asesoría jurídica.

## 6. Registro de decisiones

Usar esta tabla para decidir gradualmente sin presentar tareas opcionales como
obligaciones ya aprobadas:

| Fecha | Medida evaluada | Decisión | Motivo/evidencia | Responsable | Revisión |
|---|---|---|---|---|---|
| — | — | Pendiente | — | — | — |

Valores recomendados para **Decisión**: `implementar`, `posponer`, `descartar`,
`requiere permiso` o `requiere asesoría jurídica`.

## 7. Señales para repetir la auditoría

- [ ] Antes de publicar en Google Play u otra tienda.
- [ ] Antes de monetizar la aplicación, web, descargas o comunidad.
- [ ] Antes de alojar mods en GitHub, Cloudflare R2 u otra infraestructura
      controlada por SM64CDPY.
- [ ] Al incorporar cuentas, comentarios, reseñas o contenido enviado por
      usuarios.
- [ ] Al automatizar la importación desde nuevas fuentes.
- [ ] Cuando cambien el nombre, logo, icono o posicionamiento del producto.
- [ ] Tras recibir una reclamación o solicitud de retirada.
- [ ] Cuando Nintendo, SM64CoopDX, Google Play, GitHub o Cloudflare cambien sus
      políticas relevantes.

## 8. Fuentes de referencia

- [Pautas de Nintendo para contenido de juegos en plataformas de video e imágenes](https://www.nintendo.co.jp/networkservice_guideline/es-mx/index.html)
  — su alcance no constituye una licencia general para aplicaciones o mods.
- [Política de propiedad intelectual de Google Play](https://support.google.com/googleplay/android-developer/answer/9888072?hl=es-419)
- [Política de retirada DMCA de GitHub](https://docs.github.com/es/site-policy/content-removal-policies/dmca-takedown-policy)
- [Política de propiedad intelectual de Nintendo](https://en-americas-support.nintendo.com/app/answers/detail/a_id/50035/)

Estas fuentes pueden cambiar. Verificar siempre sus versiones vigentes antes de
tomar una decisión de publicación o responder a una reclamación.
