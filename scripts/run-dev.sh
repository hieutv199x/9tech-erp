#!/usr/bin/env bash

set -euo pipefail

CONFIG_PATH="${ODOO_CONFIG:-config/odoo.conf}"
DB_NAME="${DB_NAME:-odoo}"

if [[ $# -gt 0 && "$1" != -* ]]; then
  DB_NAME="$1"
  shift
fi

exec python3 odoo-bin -c "${CONFIG_PATH}" -d "${DB_NAME}" "$@"
