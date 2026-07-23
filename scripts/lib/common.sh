#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

load_project_env() {
    local env_file="$project_root/config/project.env"
    [[ -r "$env_file" ]] || {
        printf 'missing project configuration: %s\n' "$env_file" >&2
        exit 1
    }

    set -a
    # shellcheck disable=SC1090
    source "$env_file"
    set +a
}

require_command() {
    local command_name="$1"
    command -v "$command_name" >/dev/null 2>&1 || {
        printf 'required command is missing: %s\n' "$command_name" >&2
        exit 1
    }
}

require_build_root() {
    local build_root="${OS_NAME_BUILD_ROOT:-}"
    [[ -n "$build_root" ]] || {
        printf 'OS_NAME_BUILD_ROOT is not set\n' >&2
        exit 1
    }

    build_root="$(readlink -m -- "$build_root")"
    [[ "$build_root" != "/" && "$build_root" != "/home" && "$build_root" != "$HOME" ]] || {
        printf 'refusing unsafe build root: %s\n' "$build_root" >&2
        exit 1
    }
    [[ -d "$build_root" && -w "$build_root" ]] || {
        printf 'build root is not a writable directory: %s\n' "$build_root" >&2
        exit 1
    }
    printf '%s\n' "$build_root"
}

assert_regular_image_target() {
    local allowed_root target
    allowed_root="$(require_build_root)"
    target="$(readlink -m -- "$1")"

    [[ "$target" == "$allowed_root/"* ]] || {
        printf 'target is outside OS_NAME_BUILD_ROOT: %s\n' "$target" >&2
        exit 1
    }
    [[ -f "$target" ]] || {
        printf 'target must be an existing regular image file: %s\n' "$target" >&2
        exit 1
    }
    [[ ! -b "$target" ]] || {
        printf 'block devices are forbidden: %s\n' "$target" >&2
        exit 1
    }
}
