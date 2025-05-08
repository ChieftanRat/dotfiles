#!/usr/bin/env bash

# Usage: require git fish curl
require() {
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            fatal "🛑 Required command '$cmd' not found in PATH."
        else
            log "✅ Found dependency: $cmd"
        fi
    done
}

# Optional version check
require_version() {
    local tool="$1"
    local required="$2"
    local version

    version=$("$tool" --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [[ "$version" < "$required" ]]; then
        fatal "🛑 $tool version $required+ required. Found: $version"
    else
        log "✅ $tool version $version meets requirement"
    fi
}
