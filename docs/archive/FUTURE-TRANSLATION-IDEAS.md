# Idea futura pública — traducción de descripciones

> Nota de referencia, no especificación vigente ni compromiso de versión.
> Esta propuesta queda fuera de `1.7.0` y puede abordarse gradualmente en
> `1.7.1`, `1.7.2` o una versión posterior.

## Objetivo

Mostrar las descripciones dinámicas del catálogo en español y portugués
brasileño sin traducir manualmente la base, depender de red al abrir un mod ni
mezclar contenido remoto con los ARB de interfaz.

## Diseño propuesto

- Mantener `database_sm64coopdx.json` en inglés como fuente original.
- Generar paquetes separados, por ejemplo
  `descriptions_es.json` y `descriptions_pt_BR.json`.
- Identificar cada traducción por `modId`, idioma y hash SHA-256 de la
  descripción original normalizada.
- Si el hash coincide, reutilizar la traducción; si cambia, marcarla como
  desactualizada y regenerar solo esa entrada.
- Si falta o falla una traducción, mostrar siempre el original.
- Ofrecer `Ver original` / `Ver traducción` e indicar discretamente
  `Traducción automática`.
- No traducir títulos, autores, URLs, versiones, nombres de archivos, nombres
  propios ni términos protegidos por el glosario.

## Herramienta de mantenimiento

Crear fuera de Flutter una herramienta Python que:

1. lea la base actual;
2. normalice y calcule hashes;
3. compare los paquetes existentes;
4. prepare únicamente entradas nuevas o modificadas;
5. traduzca por lotes a ES y PT-BR;
6. conserve párrafos, viñetas, enlaces y créditos;
7. valide la respuesta contra un esquema;
8. produzca los dos JSON y un reporte de cambios.

Primero se ejecutaría manualmente con una muestra pequeña. Una automatización
posterior podría crear un pull request desde GitHub Actions. Las credenciales
del proveedor vivirían en GitHub Secrets, nunca en la aplicación.

## Flujo en la aplicación

- Inglés muestra siempre la descripción original.
- Español y portugués buscan `modId + sourceHash` en su paquete.
- Una coincidencia vigente muestra la traducción.
- Una entrada ausente o desactualizada usa el texto original sin bloquear la
  pantalla.
- Cambiar entre original y traducción recalcula el truncado real del texto.

## Pendientes de decisión

- proveedor y modelo de traducción;
- formato definitivo de los paquetes;
- glosario y proceso de revisión humana;
- preferencia global o por pantalla para mostrar el original;
- política para regenerar todo cuando cambien las reglas editoriales.

