#!/usr/bin/env bash
# Wrapper script for update-dependency-security.sh
# Calls the shared script from artagon-common submodule

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMMON_SCRIPT="${PROJECT_ROOT}/.common/artagon-common/scripts/security/update-dependency-security.sh"

if [[ ! -x "${COMMON_SCRIPT}" ]]; then
    echo "ERROR: Shared script not found at ${COMMON_SCRIPT}" >&2
    echo "Ensure artagon-common submodule is initialized:" >&2
    echo "  git submodule update --init --recursive" >&2
    exit 1
fi

# Forward all arguments to the shared script with project root
exec "${COMMON_SCRIPT}" --project-root "${PROJECT_ROOT}" "$@"
