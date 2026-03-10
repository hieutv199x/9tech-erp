#!/usr/bin/env bash
set -euo pipefail

DEFAULT_INIT_MODULES="muk_web_theme,nine_tech_branding"
INIT_MODULES="${ODOO_INIT_MODULES:-$DEFAULT_INIT_MODULES}"
DB_NAME="${DB_NAME:-${POSTGRES_DB:-}}"

has_init_arg=false
has_db_arg=false

for arg in "$@"; do
    case "$arg" in
        --init|--init=*)
            has_init_arg=true
            ;;
        -d|--database|--db_name|--database=*|--db_name=*)
            has_db_arg=true
            ;;
    esac
done

if [[ $# -eq 0 ]]; then
    set -- odoo
fi

if [[ "$1" == "--" ]]; then
    shift
fi

case "${1:-}" in
    odoo)
        ;;
    -*)
        set -- odoo "$@"
        ;;
    *)
        exec /entrypoint.sh "$@"
        ;;
esac

if [[ "${2:-}" == "scaffold" ]]; then
    exec /entrypoint.sh "$@"
fi

if [[ -n "$DB_NAME" && "$has_db_arg" == false ]]; then
    set -- "$@" -d "$DB_NAME"
fi

if [[ -n "$INIT_MODULES" && "$has_init_arg" == false && ( "$has_db_arg" == true || -n "$DB_NAME" ) ]]; then
    set -- "$@" "--init=${INIT_MODULES}"
fi

exec /entrypoint.sh "$@"
