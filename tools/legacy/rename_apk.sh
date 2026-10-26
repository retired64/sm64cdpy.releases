#!/usr/bin/env bash
# =============================================================================
# rename_apks.sh
# Renombra los APKs generados por Flutter al formato correcto para GitHub OTA.
#
# USO:
#   ./rename_apks.sh                  → lee versión de pubspec.yaml automático
#   ./rename_apks.sh 1.3.0            → fuerza versión específica
#
# RESULTADO:
#   Sm64CDPYv1.3.0-arm64.apk
#   Sm64CDPYv1.3.0-arm32.apk
#   Sm64CDPYv1.3.0-x86_64.apk
#
# COLÓCALO en la raíz del proyecto: ~/APPDUMP/source-code/rename_apks.sh
# =============================================================================

set -e  # Salir si cualquier comando falla

# --------------------------------------------------------------------------
# CONFIGURACIÓN — edita solo estos valores si el proyecto cambia de nombre
# --------------------------------------------------------------------------
APP_NAME="Sm64CDPY"           # Prefijo del nombre final del APK
PUBSPEC="pubspec.yaml"        # Ruta al pubspec.yaml (relativa al script)
APK_DIR="build/app/outputs/flutter-apk"   # Directorio de salida de Flutter
OUT_DIR="release_apks"        # Carpeta donde se guardan los APKs renombrados
# --------------------------------------------------------------------------

# ── Colores para output ────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo ""
echo -e "${CYAN}${BOLD}══════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}   Renombrador de APKs — ${APP_NAME} OTA  ${NC}"
echo -e "${CYAN}${BOLD}══════════════════════════════════════════${NC}"
echo ""

# ── Verificar que estamos en la raíz del proyecto ─────────────────────────
if [ ! -f "$PUBSPEC" ]; then
  echo -e "${RED}✗ Error: No se encontró $PUBSPEC${NC}"
  echo -e "  Ejecuta el script desde la raíz del proyecto Flutter."
  echo -e "  Ejemplo: ${YELLOW}cd ~/APPDUMP/source-code && ./rename_apks.sh${NC}"
  exit 1
fi

# ── Obtener versión ────────────────────────────────────────────────────────
if [ -n "$1" ]; then
  # Versión pasada como argumento
  VERSION="$1"
  echo -e "  Versión: ${YELLOW}${VERSION}${NC} (argumento manual)"
else
  # Extraer versionName de pubspec.yaml (parte antes del +)
  RAW_VERSION=$(grep "^version:" "$PUBSPEC" | awk '{print $2}')
  VERSION=$(echo "$RAW_VERSION" | cut -d'+' -f1)

  if [ -z "$VERSION" ]; then
    echo -e "${RED}✗ Error: No se pudo leer la versión de $PUBSPEC${NC}"
    echo -e "  Verifica que tenga una línea como: ${YELLOW}version: 1.2.0+4${NC}"
    exit 1
  fi

  VERSION_CODE=$(echo "$RAW_VERSION" | cut -d'+' -f2)
  echo -e "  Versión leída de pubspec.yaml:"
  echo -e "  versionName  → ${GREEN}${VERSION}${NC}"
  echo -e "  versionCode  → ${GREEN}${VERSION_CODE}${NC}"
fi

echo ""

# ── Verificar que el directorio de APKs existe ────────────────────────────
if [ ! -d "$APK_DIR" ]; then
  echo -e "${RED}✗ Error: No se encontró el directorio $APK_DIR${NC}"
  echo -e "  Primero ejecuta el build:"
  echo -e "  ${YELLOW}flutter build apk --release --split-per-abi${NC}"
  exit 1
fi

# ── Definir mapeo: archivo origen → nombre destino ────────────────────────
declare -A APK_MAP=(
  ["app-arm64-v8a-release.apk"]="${APP_NAME}v${VERSION}-arm64.apk"
  ["app-armeabi-v7a-release.apk"]="${APP_NAME}v${VERSION}-arm32.apk"
  ["app-x86_64-release.apk"]="${APP_NAME}v${VERSION}-x86_64.apk"
)

# ── Verificar que los APKs existen ────────────────────────────────────────
echo -e "${BOLD}  Verificando APKs en $APK_DIR/ ...${NC}"
echo ""
MISSING=0
for SRC in "${!APK_MAP[@]}"; do
  if [ ! -f "$APK_DIR/$SRC" ]; then
    echo -e "  ${RED}✗ No encontrado: $SRC${NC}"
    MISSING=$((MISSING + 1))
  else
    SIZE=$(du -h "$APK_DIR/$SRC" | cut -f1)
    echo -e "  ${GREEN}✓${NC} $SRC ${YELLOW}(${SIZE})${NC}"
  fi
done

if [ "$MISSING" -gt 0 ]; then
  echo ""
  echo -e "${RED}✗ Faltan $MISSING APK(s). Ejecuta primero:${NC}"
  echo -e "  ${YELLOW}flutter build apk --release --split-per-abi${NC}"
  exit 1
fi

# ── Crear directorio de salida ─────────────────────────────────────────────
mkdir -p "$OUT_DIR"

# ── Copiar y renombrar ─────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}  Renombrando y copiando a ${OUT_DIR}/ ...${NC}"
echo ""

for SRC in "${!APK_MAP[@]}"; do
  DST="${APK_MAP[$SRC]}"
  cp "$APK_DIR/$SRC" "$OUT_DIR/$DST"
  SIZE=$(du -h "$OUT_DIR/$DST" | cut -f1)
  echo -e "  ${GREEN}✓${NC} ${SRC}"
  echo -e "    ${CYAN}→ ${OUT_DIR}/${DST}${NC} ${YELLOW}(${SIZE})${NC}"
  echo ""
done

# ── Resumen final ──────────────────────────────────────────────────────────
echo -e "${CYAN}${BOLD}══════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ✓ Listos para subir a GitHub Releases${NC}"
echo -e "${CYAN}${BOLD}══════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Tag de GitHub:${NC}   ${YELLOW}v${VERSION}${NC}"
echo -e "  ${BOLD}Título release:${NC}  ${YELLOW}${APP_NAME} v${VERSION}${NC}"
echo -e "  ${BOLD}Carpeta:${NC}         ${YELLOW}$(pwd)/${OUT_DIR}/${NC}"
echo ""
echo -e "  Archivos listos:"
for SRC in "${!APK_MAP[@]}"; do
  DST="${APK_MAP[$SRC]}"
  echo -e "  ${GREEN}•${NC} ${OUT_DIR}/${DST}"
done
echo ""
echo -e "  ${CYAN}https://github.com/retired64/sm64cdpy.releases/releases/new${NC}"
echo ""
