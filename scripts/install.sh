#!/usr/bin/env bash

set -euo pipefail

# Resolve paths relative to this script so installation works from any current
# directory and from either a Git clone or an extracted ZIP archive.
script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd -- "${script_directory}/.." && pwd)"
source_pet_directory="${repository_root}/pet/johnny5i"
codex_home="${CODEX_HOME:-${HOME}/.codex}"
pets_directory="${codex_home}/pets"
target_pet_directory="${pets_directory}/johnny5i"

if [[ ! -f "${source_pet_directory}/pet.json" ]]; then
    printf 'The source package is missing pet.json: %s\n' "${source_pet_directory}" >&2
    exit 1
fi

if [[ ! -f "${source_pet_directory}/spritesheet.webp" ]]; then
    printf 'The source package is missing spritesheet.webp: %s\n' "${source_pet_directory}" >&2
    exit 1
fi

mkdir -p -- "${pets_directory}"

# Preserve any existing installation in a timestamped sibling directory.
if [[ -e "${target_pet_directory}" ]]; then
    timestamp="$(date '+%Y%m%d-%H%M%S')"
    archive_directory="${pets_directory}/johnny5i.archive-${timestamp}"
    mv -- "${target_pet_directory}" "${archive_directory}"
    printf 'Archived the previous Johnny5i installation to: %s\n' "${archive_directory}"
fi

cp -R -- "${source_pet_directory}" "${target_pet_directory}"

printf 'Johnny5i was installed successfully at: %s\n' "${target_pet_directory}"
printf 'Restart Codex or refresh Settings > Pets, then select johnny5i.\n'
