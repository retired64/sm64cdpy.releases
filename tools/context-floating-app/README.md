# aidocs — Context CLI para el Floating App

Herramienta local, enfocada exclusivamente en el desarrollo del **panel
flotante (overlay)** de tu aplicación. No es un navegador de
documentación genérico: es una base de conocimiento local que le da a
tu IA (opencode, Claude Code, o cualquier asistente local) contexto
real y actualizado, extraído directamente de la documentación oficial
de Android y Flutter — sin menús, anuncios ni ruido.

Ubicación sugerida en tu proyecto:

```
tu-proyecto/
└── tools/
    └── context-floating-app/   ← esta carpeta
```

---

## Instalación

```bash
cd tools/context-floating-app
pip install -r requirements.txt
```

(Recomendado: usar un entorno virtual)

```bash
python3 -m venv .venv
source .venv/bin/activate      # en Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

---

## Uso rápido

### 1. Descargar toda la documentación configurada

```bash
python cli.py fetch
```

Solo una categoría:

```bash
python cli.py fetch android
python cli.py fetch flutter
```

### 2. Ver qué hay descargado

```bash
python cli.py list
```

### 3. Buscar un término en toda la documentación local

```bash
python cli.py search overlay
```

### 4. Mostrar un documento completo

```bash
python cli.py show windowmanager
```

### 5. Generar contexto para tu IA (el comando más útil)

Los "grupos" de contexto están definidos en `index.json`, alineados a
las fases del roadmap del overlay:

```bash
python cli.py groups
```

```
fase1_fundamentos
fase2_ventana_flotante
fase3_foreground_service
fase4_flutter_bridge
fase5_optimizacion
overlay              (todo lo relevante junto)
```

Generar el contexto de una fase específica:

```bash
python cli.py context fase2_ventana_flotante --output fase2.md
```

O todo el contexto de overlay a la vez:

```bash
python cli.py context overlay > overlay.md
```

Y luego se lo pasas a tu IA local:

```bash
opencode --context overlay.md
```

---

## Cómo agregar más documentación en el futuro

1. Añade la URL en `config.yaml`, dentro de la categoría que corresponda
   (o crea una categoría nueva).
2. Si es una categoría nueva, crea `providers/<categoria>.py` con una
   función `fetch(url) -> str` (puedes copiar `providers/flutter.py`
   como plantilla) y regístrala en `providers/__init__.py`.
3. Corre `python cli.py fetch`.
4. Opcionalmente, agrégala a un grupo en `index.json` para poder
   incluirla en un `context`.

No hay que tocar `cli.py` para nada de esto.

---

## Estructura del proyecto

```
context-floating-app/
├── docs/                  # Markdown descargado (se genera con 'fetch')
│   ├── android/
│   └── flutter/
├── providers/
│   ├── __init__.py        # registro de providers disponibles
│   ├── base.py             # descarga + limpieza + conversión a Markdown
│   ├── android.py
│   └── flutter.py
├── cli.py                  # punto de entrada de la CLI
├── config.yaml              # qué páginas mantener sincronizadas
├── index.json                # grupos de contexto (por fase del roadmap)
├── aidocs.sh / aidocs.bat      # wrappers opcionales
├── requirements.txt
└── README.md
```

---

## Notas

- La extracción de contenido intenta eliminar navegación, banners de
  feedback, y otros elementos decorativos de las páginas de
  developer.android.com y docs.flutter.dev. Si alguna página sale con
  ruido, ajusta los `SELECTORS` en el provider correspondiente
  (`providers/android.py` o `providers/flutter.py`).
- Cada archivo Markdown generado incluye un comentario con la URL
  fuente (`<!-- source: ... -->`) para trazabilidad.
- El comando `context` no descarga nada nuevo: solo concatena archivos
  ya descargados con `fetch`. Si faltan documentos te lo va a avisar.
