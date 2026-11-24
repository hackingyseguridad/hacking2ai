#!/bin/sh
# (R) Antonio Taboada - hackingyseguridad.com 2026
#
# Script de instalacion de herramientas para IA / hacking con IA en local
# Compatible con /bin/sh (Bourne/POSIX shell) - sin bashismos, para sistemas
# antiguos o minimalistas (dash, ash, busybox sh, etc.)
#
# Ollama (DeepSeek)
# ------------------------------------------------------------------------

echo " "
echo "Instalando herramientas para hacking con IA ..."
echo "(R) hackingyseguridad.com 2026"
echo " "

# ------------------------------------------------------------------------
# 0) COMPROBACIONES PREVIAS
# ------------------------------------------------------------------------

if [ "$(id -u)" -ne 0 ]; then
    echo "Aviso: este script instala paquetes de sistema (apt-get)."
    echo "Ejecutalo con sudo o como root si falla algun paso."
fi

echo "Sistema:"
uname -a
date
echo " "

# ------------------------------------------------------------------------
# 1) ACTUALIZACION DE SISTEMA, HORA Y ZONA HORARIA
# ------------------------------------------------------------------------

echo "== Ajustando zona horaria y hora del sistema =="
timedatectl set-timezone Europe/Madrid
timedatectl set-local-rtc 1
timedatectl status

apt-get install -y ntpdate
ntpdate hora.ngn.rima-tde.net
timedatectl status

echo " "
echo "== Actualizando el sistema =="
dpkg --configure -a
apt-get clean
apt-get update
apt-get full-upgrade --fix-missing -y
apt-get dist-upgrade -y
apt-get autoremove -y
apt-get autoclean -y
apt-get update
apt-get -f -y install

echo " "
echo "== Paquetes base =="
apt-get install -y zstd
chmod 777 * 2>/dev/null


# ------------------------------------------------------------------------
# 3) OLLAMA
# ------------------------------------------------------------------------

echo " "
echo "== Instalando Ollama =="

if command -v ollama >/dev/null 2>&1; then
    echo "Ollama ya esta instalado ...!"
else
    echo "Instalando Ollama ..."
    curl -fsSL https://ollama.com/install.sh | sh
fi

# Intentar arrancar el servicio si existe systemctl
if command -v systemctl >/dev/null 2>&1; then
    if ! systemctl is-active ollama >/dev/null 2>&1; then
        echo "Iniciando servicio Ollama..."
        sudo systemctl start ollama
    fi
fi



chmod 777 *
