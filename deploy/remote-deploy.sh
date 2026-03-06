#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="${PROJECT_DIR:-/opt/9tech-erp}"
COMPOSE_FILE="${PROJECT_DIR}/deploy/docker-compose.prod.yml"
ENV_FILE="${PROJECT_DIR}/.env"

require_file() {
  local file_path="$1"
  if [[ ! -f "${file_path}" ]]; then
    echo "Missing required file: ${file_path}" >&2
    exit 1
  fi
}

set_env_var() {
  local file_path="$1"
  local key="$2"
  local value="$3"
  local escaped

  escaped="$(printf '%s' "${value}" | sed 's/[\/&]/\\&/g')"
  if grep -q "^${key}=" "${file_path}"; then
    sed -i "s/^${key}=.*/${key}=${escaped}/" "${file_path}"
  else
    printf '%s=%s\n' "${key}" "${value}" >> "${file_path}"
  fi
}

require_file "${COMPOSE_FILE}"
require_file "${ENV_FILE}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required on remote server." >&2
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose plugin is required on remote server." >&2
  exit 1
fi

cd "${PROJECT_DIR}"

ODOO_PORT="$(grep '^ODOO_HTTP_PORT=' "${ENV_FILE}" | cut -d '=' -f2- || true)"
ODOO_PORT="${ODOO_PORT:-8069}"

PREVIOUS_IMAGE=""
RUNNING_ODOO_CONTAINER="$(docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" ps -q odoo || true)"
if [[ -n "${RUNNING_ODOO_CONTAINER}" ]]; then
  PREVIOUS_IMAGE="$(docker inspect --format='{{.Config.Image}}' "${RUNNING_ODOO_CONTAINER}" || true)"
fi

TARGET_IMAGE="$(grep '^APP_IMAGE=' "${ENV_FILE}" | cut -d '=' -f2- || true)"
if [[ -z "${TARGET_IMAGE}" ]]; then
  echo "APP_IMAGE is required in ${ENV_FILE}" >&2
  exit 1
fi

echo "Pulling image: ${TARGET_IMAGE}"
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" pull odoo

echo "Applying compose stack..."
docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" up -d --remove-orphans

echo "Running health check on http://127.0.0.1:${ODOO_PORT}/web/login"
HEALTHY=false
for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${ODOO_PORT}/web/login" >/dev/null 2>&1; then
    HEALTHY=true
    break
  fi
  sleep 5
done

if [[ "${HEALTHY}" == "true" ]]; then
  echo "Deployment succeeded with image ${TARGET_IMAGE}"
  exit 0
fi

echo "Deployment health check failed." >&2
if [[ -n "${PREVIOUS_IMAGE}" ]]; then
  echo "Rolling back to previous image: ${PREVIOUS_IMAGE}" >&2
  set_env_var "${ENV_FILE}" "APP_IMAGE" "${PREVIOUS_IMAGE}"
  docker compose --env-file "${ENV_FILE}" -f "${COMPOSE_FILE}" up -d --remove-orphans
else
  echo "No previous image found. Rollback skipped." >&2
fi

exit 1
