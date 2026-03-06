#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="${PROJECT_DIR:-/opt/9tech-erp}"
ADMIN_USER="${ADMIN_USER:-${SUDO_USER:-$USER}}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script with sudo: sudo bash deploy/vps-bootstrap.sh" >&2
  exit 1
fi

apt-get update -y
apt-get install -y ca-certificates curl ufw fail2ban

if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

usermod -aG docker "${ADMIN_USER}"
mkdir -p "${PROJECT_DIR}/deploy"
chown -R "${ADMIN_USER}:${ADMIN_USER}" "${PROJECT_DIR}"

ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

systemctl enable --now docker
systemctl enable --now fail2ban

echo "Bootstrap complete."
echo "Log out and back in to apply docker group membership for ${ADMIN_USER}."
