#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <database> <module1,module2,...> [extra odoo args]" >&2
  exit 1
fi

DB_NAME="$1"
MODULES="$2"
shift 2

CONFIG_PATH="${ODOO_CONFIG:-config/odoo.conf}"

exec python3 odoo-bin -c "${CONFIG_PATH}" -d "${DB_NAME}" -u "${MODULES}" --stop-after-init "$@"
