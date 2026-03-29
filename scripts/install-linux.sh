#!/usr/bin/env bash
set -euo pipefail

APP_VERSION="2.01.2510290-1"
RELEASE_TAG="v${APP_VERSION}"
PACKAGE_NAME="io.github.msojocs.wechat-devtools-linux_${APP_VERSION}_amd64.deb"
PACKAGE_URL="https://github.com/msojocs/wechat-web-devtools-linux/releases/download/${RELEASE_TAG}/${PACKAGE_NAME}"
APP_NAME="PMTMiniApp Dev Tools"
ICON_NAME="pmtminiapp-dev-tools"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ICON_SOURCE="${REPO_ROOT}/assets/orange.png"
TEMPLATE_PATH="${REPO_ROOT}/desktop/PMTMiniApp Dev Tools.desktop.template"

APPLICATIONS_DIR="${HOME}/Applications"
INSTALL_DIR="${APPLICATIONS_DIR}/wechat-devtools-${APP_VERSION}"
RUNNER_PATH="${APPLICATIONS_DIR}/run-pmtminiapp-dev-tools.sh"

XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
ICON_DIR="${XDG_DATA_HOME}/icons/hicolor/512x512/apps"
ICON_TARGET="${ICON_DIR}/${ICON_NAME}.png"
MENU_ENTRY_PATH="${XDG_DATA_HOME}/applications/pmtminiapp-dev-tools.desktop"
PROFILE_ROOT="${XDG_DATA_HOME}/wechat-devtools-stable-clean"

find_desktop_dir() {
  local desktop_dir=""

  if command -v xdg-user-dir >/dev/null 2>&1; then
    desktop_dir="$(xdg-user-dir DESKTOP 2>/dev/null || true)"
  fi

  if [[ -z "${desktop_dir}" || "${desktop_dir}" == "${HOME}" ]]; then
    if [[ -d "${HOME}/Bureau" ]]; then
      desktop_dir="${HOME}/Bureau"
    else
      desktop_dir="${HOME}/Desktop"
    fi
  fi

  printf '%s\n' "${desktop_dir}"
}

download_package() {
  local destination="$1"

  if command -v curl >/dev/null 2>&1; then
    curl -L --fail --output "${destination}" "${PACKAGE_URL}"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -O "${destination}" "${PACKAGE_URL}"
    return
  fi

  printf '[erreur] curl ou wget est requis pour telecharger le paquet.\n' >&2
  exit 1
}

extract_package() {
  local package_path="$1"
  local destination="$2"

  rm -rf "${destination}"
  mkdir -p "${destination}"

  if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb -x "${package_path}" "${destination}"
    return
  fi

  local tmp_extract
  local data_archive
  tmp_extract="$(mktemp -d)"

  (
    cd "${tmp_extract}"
    ar x "${package_path}"
  )

  data_archive="$(find "${tmp_extract}" -maxdepth 1 -type f -name 'data.tar.*' | head -n 1)"
  if [[ -z "${data_archive}" ]]; then
    rm -rf "${tmp_extract}"
    printf '[erreur] impossible de trouver data.tar.* dans le paquet.\n' >&2
    exit 1
  fi

  tar -xf "${data_archive}" -C "${destination}"
  rm -rf "${tmp_extract}"
}

main() {
  local desktop_dir desktop_path deb_path executable_path

  desktop_dir="$(find_desktop_dir)"
  desktop_path="${desktop_dir}/${APP_NAME}.desktop"
  deb_path="${XDG_CACHE_HOME}/pmtminiapp-dev-tools/${PACKAGE_NAME}"

  mkdir -p \
    "${APPLICATIONS_DIR}" \
    "${XDG_CACHE_HOME}/pmtminiapp-dev-tools" \
    "${XDG_DATA_HOME}/applications" \
    "${ICON_DIR}" \
    "${PROFILE_ROOT}/config" \
    "${PROFILE_ROOT}/cache" \
    "${PROFILE_ROOT}/data" \
    "${desktop_dir}"

  printf '[install] telechargement de %s\n' "${PACKAGE_URL}"
  download_package "${deb_path}"

  printf '[install] extraction dans %s\n' "${INSTALL_DIR}"
  extract_package "${deb_path}" "${INSTALL_DIR}"

  executable_path="${INSTALL_DIR}/opt/apps/io.github.msojocs.wechat-devtools-linux/files/bin/bin/wechat-devtools"
  if [[ ! -x "${executable_path}" ]]; then
    printf '[erreur] executable WeChat DevTools introuvable.\n' >&2
    exit 1
  fi

  install -m 644 "${ICON_SOURCE}" "${ICON_TARGET}"

  cat > "${RUNNER_PATH}" <<EOF
#!/usr/bin/env bash
set -euo pipefail
ROOT="\$HOME/.local/share/wechat-devtools-stable-clean"
export XDG_CONFIG_HOME="\$ROOT/config"
export XDG_CACHE_HOME="\$ROOT/cache"
export XDG_DATA_HOME="\$ROOT/data"
mkdir -p "\$XDG_CONFIG_HOME" "\$XDG_CACHE_HOME" "\$XDG_DATA_HOME"
exec "${executable_path}" "\$@"
EOF
  chmod 755 "${RUNNER_PATH}"

  sed "s#@RUNNER_PATH@#${RUNNER_PATH}#g" "${TEMPLATE_PATH}" > "${MENU_ENTRY_PATH}"
  chmod 755 "${MENU_ENTRY_PATH}"
  install -m 755 "${MENU_ENTRY_PATH}" "${desktop_path}"

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${XDG_DATA_HOME}/applications" >/dev/null 2>&1 || true
  fi

  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache "${XDG_DATA_HOME}/icons/hicolor" >/dev/null 2>&1 || true
  fi

  if command -v gio >/dev/null 2>&1; then
    gio set "${desktop_path}" metadata::trusted true >/dev/null 2>&1 || true
  fi

  printf '\n[ok] installation terminee\n'
  printf 'Lanceur menu : %s\n' "${MENU_ENTRY_PATH}"
  printf 'Lanceur bureau : %s\n' "${desktop_path}"
  printf 'Image installee : %s\n' "${ICON_TARGET}"
  printf '\nSi Ubuntu affiche un X rouge, faites : clic droit > Autoriser le lancement\n'
}

main "$@"
