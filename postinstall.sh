#!/usr/bin/env bash
set -Eeuo pipefail

# ======================================================
# POSTINSTALL UBUNTU DESKTOP MINIMAL - PLEX + TDARR NATIVO
# Incluye: Backups, Xorg forzado (no Wayland), XRDP/VNC OK, 
#           montaje seguro de NAS, Flatpak, VLC, autoinicio Tdarr/Plex
# ======================================================

USERNAME="estejuan"
NAS_HOST="lobomorir-nas.local"
NAS_SHARE="Media"
NAS_MOUNT="/mnt/media"
CREDENTIALS_FILE="/etc/samba/credentials/lobomorir-nas"

PLEX_KEY_URL="https://downloads.plex.tv/plex-keys/PlexSign.key"
PLEX_KEY_PATH="/etc/apt/keyrings/plex.gpg"
PLEX_REPO_LINE="deb [arch=$(dpkg --print-architecture) signed-by=$PLEX_KEY_PATH] https://downloads.plex.tv/repo/deb public main"
PLEX_LIST="/etc/apt/sources.list.d/plexmediaserver.list"

CODE_KEY_URL="https://packages.microsoft.com/keys/microsoft.asc"
CODE_KEY_PATH="/etc/apt/keyrings/microsoft.gpg"
CODE_REPO_LINE="deb [arch=$(dpkg --print-architecture) signed-by=$CODE_KEY_PATH] https://packages.microsoft.com/repos/code stable main"
CODE_LIST="/etc/apt/sources.list.d/vscode.list"

LOGFILE="/var/log/postinstall-plex-tdarr.log"
FLAGDIR="/var/local/postinstall-flags"
mkdir -p "$FLAGDIR"

DRYRUN=0
ONLY=""
if [[ "${1:-}" == "--dry-run" ]]; then DRYRUN=1; shift; fi
if [[ "${1:-}" == "--only" ]]; then ONLY="$2"; shift 2; fi

log()   { echo -e "[\e[32mINFO\e[0m] $*" | tee -a "$LOGFILE"; }
warn()  { echo -e "[\e[33mWARN\e[0m] $*" | tee -a "$LOGFILE"; }
error() { echo -e "[\e[31mERR \e[0m] $*" | tee -a "$LOGFILE"; }
confirm() { read -p "$* [y/N] " -r && [[ $REPLY =~ ^[Yy]$ ]]; }

run() {
  if ((DRYRUN)); then log "DRYRUN: $*"; else eval "$@"; fi
}

backup_if_not_exists() {
  [[ -f "$1" && ! -f "$1.bak" ]] && sudo cp -v "$1" "$1.bak"
}

add_line_if_missing() {
  local line="$1" file="$2"
  grep -Fxq "$line" "$file" 2>/dev/null || echo "$line" | sudo tee -a "$file"
}

ensure_keyring() {
  local url="$1" dest="$2"
  if [[ ! -f $dest ]]; then
    run "sudo install -d -m755 $(dirname $dest)"
    run "curl -fsSL '$url' | gpg --dearmor | sudo tee '$dest' >/dev/null"
    run "sudo chmod 644 '$dest'"
    log "Keyring añadido: $dest"
  else
    log "Keyring existe: $dest"
  fi
}

ensure_repo() {
  local file="$1" line="$2"
  if [[ -f "$file" && $(grep -Fx "$line" "$file" 2>/dev/null) ]]; then
    log "Repo correcto: $file"
  else
    backup_if_not_exists "$file"
    echo "$line" | sudo tee "$file" >/dev/null
    log "Repo actualizado: $file"
  fi
}

ensure_fstab_entry() {
  local entry="$1"
  backup_if_not_exists "/etc/fstab"
  grep -Fq "$entry" /etc/fstab || echo "$entry" | sudo tee -a /etc/fstab >/dev/null
}

ensure_group_user() {
  local user="$1" group="$2"
  id -nG "$user" | grep -qw "$group" || sudo usermod -aG "$group" "$user"
}

check_desktop_minimal() {
  # Devuelve 0 si es minimal (sin gnome-shell, etc)
  if dpkg -l | grep -q gnome-shell; then return 1; else return 0; fi
}

step_done() {
  [[ -f "$FLAGDIR/$1.done" ]]
}
mark_done() {
  touch "$FLAGDIR/$1.done"
}

# ============ 1. PRELIMINARES Y BACKUP ==============
step="01-backup"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  log "Preparando backups y verificando entorno..."
  backup_if_not_exists "/etc/fstab"
  backup_if_not_exists "/etc/apt/sources.list"
  sudo apt update | tee -a "$LOGFILE"
  mark_done "$step"
fi

# =========== 2. REPOSITORIOS OFICIALES ==============
step="02-repos-oficiales"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  log "Habilitando universe, multiverse, restricted..."
  run "sudo add-apt-repository -y universe"
  run "sudo add-apt-repository -y multiverse"
  run "sudo add-apt-repository -y restricted"
  run "sudo apt update"
  mark_done "$step"
fi

# ========== 3. HERRAMIENTAS FUNDAMENTALES ===========
step="03-herramientas"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  log "Instalando utilidades base..."
  run "sudo apt install -y software-properties-common curl gnupg ca-certificates"
  if dpkg -l | grep '^..r'; then
    warn "Paquetes rotos detectados. Reparando..."
    run "sudo dpkg --configure -a"
    run "sudo apt --fix-broken install -y"
  fi
  run "sudo apt clean"
  mark_done "$step"
fi

# ============== 4. REPOS EXTERNOS ===================
step="04-repos-externos"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  log "Añadiendo keyrings y repos de Plex / VSCode..."
  ensure_keyring "$PLEX_KEY_URL" "$PLEX_KEY_PATH"
  ensure_repo "$PLEX_LIST" "$PLEX_REPO_LINE"
  ensure_keyring "$CODE_KEY_URL" "$CODE_KEY_PATH"
  ensure_repo "$CODE_LIST" "$CODE_REPO_LINE"
  run "sudo apt update"
  mark_done "$step"
fi

# ============= 5. SOFTWARE PRINCIPAL ================
step="05-software"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  log "Instalando Plex, VSCode y utilidades..."
  run "sudo apt install -y plexmediaserver code xrdp tigervnc-standalone-server \
    gparted gnome-disk-utility gnome-system-monitor gnome-terminal git vlc \
    vainfo intel-media-va-driver-non-free cifs-utils"
  mark_done "$step"
fi

# =========== 6. FLATPAK Y FLATHUB ===================
step="06-flatpak"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  log "Instalando Flatpak y GitHub Desktop..."
  run "sudo apt install -y flatpak gnome-software-plugin-flatpak"
  run "flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
  run "flatpak install -y flathub io.github.shiftey.Desktop"
  mark_done "$step"
fi

# ============= 7. MONTAJE NAS =======================
step="07-nas"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  log "Configurando montaje automático NAS..."
  sudo mkdir -p "$NAS_MOUNT" "$(dirname "$CREDENTIALS_FILE")"
  if [[ ! -f "$CREDENTIALS_FILE" ]]; then
    read -rp "Usuario NAS: " NASUSER
    read -srp "Contraseña NAS: " NASPASS && echo
    echo -e "username=$NASUSER\npassword=$NASPASS" | sudo tee "$CREDENTIALS_FILE" >/dev/null
    sudo chmod 600 "$CREDENTIALS_FILE"
    sudo chown root:root "$CREDENTIALS_FILE"
  fi
  fstab_entry="//${NAS_HOST}/${NAS_SHARE}  ${NAS_MOUNT}  cifs credentials=${CREDENTIALS_FILE},iocharset=utf8,sec=ntlmssp,vers=3.0,_netdev,x-systemd.automount,nofail  0 0"
  ensure_fstab_entry "$fstab_entry"
  sudo mount -a || warn "¡Error en mount -a! Revisa credenciales."
  # Plex override
  sudo mkdir -p /etc/systemd/system/plexmediaserver.service.d
  printf "[Unit]\nRequiresMountsFor=%s\n" "$NAS_MOUNT" | sudo tee /etc/systemd/system/plexmediaserver.service.d/override.conf >/dev/null
  sudo systemctl daemon-reload
  mark_done "$step"
fi

# ============= 8. TDARR (NATIVO) =====================
step="08-tdarr"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  log "Instalando Node.js 18, FFmpeg y Mediainfo para Tdarr..."
  run "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
  run "sudo apt install -y nodejs ffmpeg mediainfo"
  log "Descargando e instalando Tdarr (.deb) última versión..."
  TDARR_VER=$(curl -s https://api.github.com/repos/HaveAGitGat/Tdarr/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
  TDARR_DEB="Tdarr_${TDARR_VER}_amd64.deb"
  cd /tmp
  run "curl -L -o $TDARR_DEB https://github.com/HaveAGitGat/Tdarr/releases/download/${TDARR_VER}/$TDARR_DEB"
  run "sudo dpkg -i $TDARR_DEB || sudo apt-get -f install -y"
  log "Configurando TdarrServer y TdarrNode como servicios systemd..."
  sudo tee /etc/systemd/system/tdarrserver.service > /dev/null <<EOF
[Unit]
Description=Tdarr Server
After=network.target

[Service]
User=$USERNAME
ExecStart=/usr/bin/TdarrServer
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

  sudo tee /etc/systemd/system/tdarrnode.service > /dev/null <<EOF
[Unit]
Description=Tdarr Node
After=network.target

[Service]
User=$USERNAME
ExecStart=/usr/bin/TdarrNode
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

  run "sudo systemctl daemon-reload"
  run "sudo systemctl enable tdarrserver tdarrnode"
  run "sudo systemctl start tdarrserver tdarrnode"
  log "Probando aceleración VAAPI (vainfo)..."
  vainfo || warn "vainfo falló; verifica los drivers y permisos."
  log "Tdarr instalado nativamente. Accede vía http://localhost:8265/"
  mark_done "$step"
fi

# =========== 9. USUARIOS Y GRUPOS ===================
step="09-usuarios"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  log "Ajustando usuarios y grupos..."
  for grp in sudo video ssl-cert; do ensure_group_user "$USERNAME" "$grp"; done
  for grp in video render; do ensure_group_user "plex" "$grp"; done
  mark_done "$step"
fi

# =========== 10. SESIONES REMOTAS ===================
step="10-sesion"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  log "Configurando .xsession..."
  XSESSION="/home/$USERNAME/.xsession"
  [[ -f "$XSESSION" && ! -f "$XSESSION.bak" ]] && sudo cp "$XSESSION" "$XSESSION.bak"
  echo "gnome-session --systemd" | sudo tee "$XSESSION" >/dev/null
  sudo chmod +x "$XSESSION"
  sudo chown "$USERNAME:$USERNAME" "$XSESSION"
  mark_done "$step"
fi

# ======== 10A. DESACTIVAR WAYLAND Y FORZAR XORG =======
step="10a-xorg"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  if [[ -f /etc/gdm3/custom.conf ]]; then
    log "Desactivando Wayland en GDM (sólo Xorg habilitado)..."
    sudo sed -i '/^\[daemon\]/a WaylandEnable=false' /etc/gdm3/custom.conf
    sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
    sudo systemctl restart gdm3 || warn "No se pudo reiniciar gdm3, puede que no esté instalado (ok en minimal/headless)"
  else
    warn "GDM3 no está instalado; si tienes otro display manager, revisa su configuración manualmente."
  fi
  mark_done "$step"
fi

# =============== 11. LIMPIEZA =======================
step="11-limpieza"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  if check_desktop_minimal; then
    log "Limpieza de paquetes no deseados..."
    warn "Esto puede eliminar tu entorno gráfico si no es minimal. ¿Continuar?"
    if confirm "¿Continuar con limpieza?"; then
      run "sudo apt purge -y ubuntu-wallpapers-* yaru-theme-audio yaru-theme-sound aisleriot cheese gnome-maps gnome-weather gnome-photos rhythmbox totem shotwell gnome-characters gnome-contacts"
      run "sudo apt autoremove -y"
    fi
  else
    warn "Se detecta escritorio GNOME; omitiendo limpieza agresiva."
  fi
  mark_done "$step"
fi

# =========== 12. FINAL / LOG / REBOOT ===============
step="12-final"
if [[ "$ONLY" == "" || "$ONLY" == "$step" ]] && ! step_done "$step"; then
  log "¡Instalación completa!"
  if [[ -f /etc/gdm3/custom.conf ]]; then
    log "Verifica que la próxima sesión gráfica será Xorg (no Wayland):"
    log "En tu próxima sesión gráfica (incluido XRDP/VNC), ejecuta: 'echo \$XDG_SESSION_TYPE' (debe devolver 'x11')"
  fi
  echo "Revisa el log en $LOGFILE"
  echo "Reinicia tu equipo para asegurar que todos los servicios y montajes funcionen correctamente."
  mark_done "$step"
fi