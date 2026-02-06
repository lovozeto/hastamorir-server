# Hastamorir Server Setup

**Servidor Ubuntu Minimal con Plex + Tdarr + Herramientas Multimedia**

Automatiza la **instalación, configuración y mantenimiento** de un servidor multimedia Ubuntu minimal, optimizado para hardware Intel, con soporte remoto y actualizaciones automáticas.

---

## 🚀 Instalación rápida

Descarga y ejecuta el último postinstall:

```bash
LATEST=$(curl -s https://api.github.com/repos/lovozeto/hastamorir-server/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
curl -LO https://github.com/lovozeto/hastamorir-server/releases/download/$LATEST/postinstall.sh
chmod +x postinstall.sh
sudo ./postinstall.sh
```

---

## ¿Qué hace este script?

- Habilita repos oficiales y extras (Plex, VSCode, Flathub)
- Instala utilidades base y multimedia (VLC, Flatpak, XRDP/VNC, Git, etc.)
- Configura montaje seguro de NAS/CIFS
- Instala **Plex Media Server**
- Instala **Tdarr nativo** (con aceleración HW Intel)
- Limpia paquetes y deja el entorno minimal
- Refuerza el soporte remoto (Xorg en vez de Wayland)
- **Programa un auto-actualizador semanal para Plex y Tdarr**

---

## 🔄 Actualización automática

- El script deja configurado un actualizador en `/usr/local/bin/update-plex-tdarr.sh`
  (corre cada domingo a las 3am vía cron).
- Puedes ejecutarlo manualmente cuando quieras: