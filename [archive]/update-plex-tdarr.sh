#!/usr/bin/env bash
set -Eeuo pipefail

# ================================
# AUTO-UPDATER: Plex & Tdarr
# Version 2024.07
# ================================

# CONFIG
LOGFILE="/var/log/update-plex-tdarr.log"
PLEX_SERVICE="plexmediaserver"
TDARR_SERVER_SERVICE="tdarrserver"
TDARR_NODE_SERVICE="tdarrnode"

log()   { echo -e "[\e[32mINFO\e[0m] $*" | tee -a "$LOGFILE"; }
warn()  { echo -e "[\e[33mWARN\e[0m] $*" | tee -a "$LOGFILE"; }
error() { echo -e "[\e[31mERR \e[0m] $*" | tee -a "$LOGFILE"; }

# --- 1. Actualizar Plex Media Server ---
update_plex() {
  log "🔄 Verificando y actualizando Plex Media Server..."
  BEFORE_VER=$(dpkg-query -W -f='${Version}' plexmediaserver 2>/dev/null || echo "none")
  sudo apt update
  sudo apt install -y plexmediaserver
  AFTER_VER=$(dpkg-query -W -f='${Version}' plexmediaserver 2>/dev/null || echo "none")
  if [[ "$BEFORE_VER" != "$AFTER_VER" ]]; then
    log "✅ Plex actualizado: $BEFORE_VER -> $AFTER_VER"
    sudo systemctl restart "$PLEX_SERVICE"
  else
    log "Plex ya está en la última versión ($AFTER_VER)"
  fi
}

# --- 2. Actualizar Tdarr (nativo, .deb) ---
update_tdarr() {
  log "🔄 Verificando y actualizando Tdarr (.deb)..."
  TDARR_URL_API="https://api.github.com/repos/HaveAGitGat/Tdarr/releases/latest"
  LATEST_VER=$(curl -s "$TDARR_URL_API" | grep -Po '"tag_name": "\K.*?(?=")')
  LATEST_DEB="Tdarr_${LATEST_VER}_amd64.deb"
  LATEST_URL="https://github.com/HaveAGitGat/Tdarr/releases/download/${LATEST_VER}/${LATEST_DEB}"

  INSTALLED_VER=$(dpkg-query -W -f='${Version}' Tdarr 2>/dev/null || echo "none")
  # "2.17.01" tipo versión
  if [[ "$INSTALLED_VER" == "${LATEST_VER#v}" ]]; then
    log "Tdarr ya está en la última versión ($INSTALLED_VER)"
    return
  fi
  log "Descargando nueva versión de Tdarr: $LATEST_VER"
  TMP_DEB="/tmp/$LATEST_DEB"
  curl -L -o "$TMP_DEB" "$LATEST_URL"
  sudo dpkg -i "$TMP_DEB" || sudo apt-get -f install -y
  sudo systemctl restart "$TDARR_SERVER_SERVICE" "$TDARR_NODE_SERVICE"
  log "✅ Tdarr actualizado: $INSTALLED_VER -> ${LATEST_VER#v}"
}

# --- 3. MAIN ---
main() {
  log "==== INICIANDO AUTO-UPDATER Plex & Tdarr ===="
  update_plex
  update_tdarr
  log "==== FIN de actualización $(date) ===="
}

main "$@"