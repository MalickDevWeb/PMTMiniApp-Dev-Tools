#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_VERSION="2.01.2510290-1"
UPSTREAM_TAG="v${UPSTREAM_VERSION}"
UPSTREAM_FILE="io.github.msojocs.wechat-devtools-linux_${UPSTREAM_VERSION}_amd64.deb"
UPSTREAM_URL="https://github.com/msojocs/wechat-web-devtools-linux/releases/download/${UPSTREAM_TAG}/${UPSTREAM_FILE}"
CUSTOM_PACKAGE="pmtminiapp-dev-tools"
OUTPUT_FILE="${CUSTOM_PACKAGE}_${UPSTREAM_VERSION}_amd64.deb"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_ROOT="${REPO_ROOT}/.build"
CACHE_DIR="${BUILD_ROOT}/cache"
STAGE_DIR="${BUILD_ROOT}/stage"
DIST_DIR="${REPO_ROOT}/dist"
UPSTREAM_DEB="${CACHE_DIR}/${UPSTREAM_FILE}"

ICON_SOURCE="${REPO_ROOT}/assets/orange.png"
CONTROL_TEMPLATE="${REPO_ROOT}/packaging/DEBIAN/control.template"
POSTINST_TEMPLATE="${REPO_ROOT}/packaging/DEBIAN/postinst"
POSTRM_TEMPLATE="${REPO_ROOT}/packaging/DEBIAN/postrm"
DESKTOP_TEMPLATE="${REPO_ROOT}/packaging/pmtminiapp-dev-tools.desktop"
WRAPPER_TEMPLATE="${REPO_ROOT}/packaging/usr-bin-pmtminiapp-dev-tools.template"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    printf '[erreur] commande requise: %s\n' "$1" >&2
    exit 1
  }
}

download_upstream() {
  mkdir -p "${CACHE_DIR}"
  if [[ -f "${UPSTREAM_DEB}" ]]; then
    return
  fi

  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --output "${UPSTREAM_DEB}" "${UPSTREAM_URL}"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -O "${UPSTREAM_DEB}" "${UPSTREAM_URL}"
    return
  fi

  printf '[erreur] curl ou wget est requis pour telecharger le paquet upstream.\n' >&2
  exit 1
}

prepare_stage() {
  rm -rf "${STAGE_DIR}"
  mkdir -p \
    "${STAGE_DIR}/DEBIAN" \
    "${STAGE_DIR}/usr/bin" \
    "${STAGE_DIR}/usr/share/applications" \
    "${STAGE_DIR}/usr/share/icons/hicolor/512x512/apps"

  dpkg-deb -x "${UPSTREAM_DEB}" "${STAGE_DIR}"

  rm -f "${STAGE_DIR}/usr/share/applications/io.github.msojocs.wechat-devtools-linux.desktop"

  install -m 644 "${ICON_SOURCE}" "${STAGE_DIR}/usr/share/icons/hicolor/512x512/apps/pmtminiapp-dev-tools.png"
  install -m 644 "${DESKTOP_TEMPLATE}" "${STAGE_DIR}/usr/share/applications/pmtminiapp-dev-tools.desktop"
  install -m 755 "${WRAPPER_TEMPLATE}" "${STAGE_DIR}/usr/bin/pmtminiapp-dev-tools"
  install -m 755 "${POSTINST_TEMPLATE}" "${STAGE_DIR}/DEBIAN/postinst"
  install -m 755 "${POSTRM_TEMPLATE}" "${STAGE_DIR}/DEBIAN/postrm"
}

write_control() {
  local depends upstream_package
  depends="$(dpkg-deb -f "${UPSTREAM_DEB}" Depends 2>/dev/null || true)"
  upstream_package="$(dpkg-deb -f "${UPSTREAM_DEB}" Package 2>/dev/null || true)"

  if [[ -z "${depends}" ]]; then
    depends="libasound2 | libasound2t64, libnss3, libxss1, libgtk-3-0"
  fi

  if [[ -z "${upstream_package}" ]]; then
    upstream_package="io.github.msojocs.wechat-devtools-linux"
  fi

  sed \
    -e "s#@PACKAGE_VERSION@#${UPSTREAM_VERSION}#g" \
    -e "s#@DEPENDS@#${depends}#g" \
    -e "s#@UPSTREAM_PACKAGE@#${upstream_package}#g" \
    "${CONTROL_TEMPLATE}" > "${STAGE_DIR}/DEBIAN/control"
}

build_package() {
  mkdir -p "${DIST_DIR}"
  dpkg-deb -b "${STAGE_DIR}" "${DIST_DIR}/${OUTPUT_FILE}"
}

main() {
  require_cmd dpkg-deb
  require_cmd ar
  require_cmd tar

  printf '[build] telechargement de %s\n' "${UPSTREAM_URL}"
  download_upstream

  printf '[build] preparation du stage Debian\n'
  prepare_stage

  printf '[build] ecriture du control Debian\n'
  write_control

  printf '[build] creation de %s\n' "${DIST_DIR}/${OUTPUT_FILE}"
  build_package

  printf '\n[ok] paquet cree : %s\n' "${DIST_DIR}/${OUTPUT_FILE}"
  printf 'A publier dans GitHub Releases pour une installation au double-clic.\n'
}

main "$@"
