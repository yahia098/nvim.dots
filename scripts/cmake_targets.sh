#!/usr/bin/env bash
# List and run executable targets from a CMake project.
# Usage:
#   cmake_targets.sh list PROJECT_ROOT BUILD_DIR
#   cmake_targets.sh run  PROJECT_ROOT BUILD_DIR TARGET

set -euo pipefail

usage() {
    printf 'Usage: %s {list|run} PROJECT_ROOT BUILD_DIR [TARGET]\n' "$0" >&2
    exit 2
}

[[ $# -ge 3 ]] || usage

action=$1
project_root_arg=$2
build_dir_arg=$3
target=${4:-}

case "$action" in
    list|run) ;;
    *) usage ;;
esac

project_root=$(cd -- "$project_root_arg" 2>/dev/null && pwd -P) || {
    printf 'cmake_targets.sh: project directory does not exist: %s\n' "$project_root_arg"
    exit 1
}

if [[ ! -f "$project_root/CMakeLists.txt" ]]; then
    printf 'cmake_targets.sh: no CMakeLists.txt in %s\n' "$project_root"
    exit 1
fi

if [[ "$build_dir_arg" = /* ]]; then
    build_dir=$build_dir_arg
else
    build_dir="$project_root/$build_dir_arg"
fi

mkdir -p -- "$build_dir"
build_dir=$(cd -- "$build_dir" && pwd -P)

# The CMake File API exposes executable targets and their real artifact paths.
query_dir="$build_dir/.cmake/api/v1/query"
mkdir -p -- "$query_dir"
: > "$query_dir/codemodel-v2"

# Refresh target metadata when listing. Running a selected target can rely on
# that reply; `cmake --build` will regenerate the build if inputs have changed.
if [[ "$action" == "list" ]]; then
    configure_log=$(mktemp)
    if ! cmake -S "$project_root" -B "$build_dir" >"$configure_log" 2>&1; then
        cat "$configure_log"
        rm -f -- "$configure_log"
        exit 1
    fi
    rm -f -- "$configure_log"
fi

get_metadata() {
    python3 - "$build_dir" "$action" "$target" <<'PY'
import json
import pathlib
import sys

build_dir = pathlib.Path(sys.argv[1]).resolve()
action = sys.argv[2]
requested_target = sys.argv[3]
reply_dir = build_dir / ".cmake" / "api" / "v1" / "reply"
indexes = sorted(reply_dir.glob("index-*.json"))
if not indexes:
    raise SystemExit("cmake_targets.sh: CMake did not produce a File API index")

try:
    index = json.loads(indexes[-1].read_text())
    codemodel_ref = index.get("reply", {}).get("codemodel-v2")
    if not codemodel_ref:
        raise ValueError("the index has no codemodel-v2 reply")
    codemodel = json.loads((reply_dir / codemodel_ref["jsonFile"]).read_text())
except (OSError, KeyError, ValueError, json.JSONDecodeError) as error:
    raise SystemExit(f"cmake_targets.sh: could not read CMake target metadata: {error}")

configurations = codemodel.get("configurations", [])
if not configurations:
    raise SystemExit("cmake_targets.sh: CMake reported no build configurations")

# For multi-configuration generators, use CMAKE_BUILD_TYPE when available,
# otherwise Debug if it exists. Pass that choice to `cmake --build` later.
cache = build_dir / "CMakeCache.txt"
build_type = ""
if cache.exists():
    for line in cache.read_text(errors="replace").splitlines():
        if line.startswith("CMAKE_BUILD_TYPE:STRING="):
            build_type = line.partition("=")[2].strip()
            break

multi_config = len(configurations) > 1
wanted = build_type or "Debug"
configuration = next(
    (item for item in configurations if item.get("name", "").lower() == wanted.lower()),
    configurations[0],
)

executables = []
for reference in configuration.get("targets", []):
    try:
        target_data = json.loads((reply_dir / reference["jsonFile"]).read_text())
    except (OSError, KeyError, json.JSONDecodeError) as error:
        raise SystemExit(f"cmake_targets.sh: could not read target metadata: {error}")
    if target_data.get("type") != "EXECUTABLE" or not target_data.get("artifacts"):
        continue
    artifact_path = pathlib.Path(target_data["artifacts"][0]["path"])
    if not artifact_path.is_absolute():
        artifact_path = build_dir / artifact_path
    executables.append((target_data["name"], artifact_path.resolve()))

if action == "list":
    for name in sorted({name for name, _ in executables}):
        print(name)
    raise SystemExit(0)

for name, artifact_path in executables:
    if name == requested_target:
        # '-' means a single-config generator; no --config is needed.
        print(f"{artifact_path}\t{configuration.get('name') or '-'}\t{1 if multi_config else 0}")
        raise SystemExit(0)

raise SystemExit(f"cmake_targets.sh: no executable target found: {requested_target}")
PY
}

metadata=$(get_metadata)

case "$action" in
    list)
        if [[ -n "$metadata" ]]; then
            printf '%s\n' "$metadata"
        fi
        ;;
    run)
        if [[ -z "$target" ]]; then
            printf 'cmake_targets.sh: run mode requires a target name\n' >&2
            exit 2
        fi

        IFS=$'\t' read -r executable config multi_config <<< "$metadata"
        build_args=(--build "$build_dir" --target "$target")
        if [[ "$multi_config" == "1" && "$config" != "-" ]]; then
            build_args+=(--config "$config")
        fi

        cmake "${build_args[@]}" || exit $?

        if [[ ! -x "$executable" ]]; then
            printf 'cmake_targets.sh: target built, but executable is missing or not executable: %s\n' "$executable" >&2
            exit 1
        fi

        # Run from the project root so relative asset/config paths work.
        cd -- "$project_root"
        exec "$executable"
        ;;
esac
