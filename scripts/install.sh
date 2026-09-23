#!/usr/bin/env bash

set -euo pipefail

# Resolve paths relative to this script so installation works from any current
# directory and from either a Git clone or an extracted ZIP archive.
script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd -- "${script_directory}/.." && pwd)"
codex_home="${CODEX_HOME:-${HOME}/.codex}"
pets_directory="${codex_home}/pets"
pet_backups_directory="${codex_home}/pet-backups"

requested_pet="${1:-}"

if [[ -z "${requested_pet}" ]]; then
    if [[ -t 0 ]]; then
        printf '\nChoose which Codex pet to install:\n'
        printf '  1. Johnny5i\n'
        printf '  2. PixyPi\n'
        printf '  3. Both pets\n'
        read -r -p 'Enter 1, 2, or 3 (default: 3): ' requested_pet
    else
        requested_pet="all"
    fi
fi

case "${requested_pet}" in
    1|johnny5i)
        pet_ids=("johnny5i")
        ;;
    2|pixypi)
        pet_ids=("pixypi")
        ;;
    ""|3|all)
        pet_ids=("johnny5i" "pixypi")
        ;;
    *)
        printf 'Invalid selection: %s\n' "${requested_pet}" >&2
        printf 'Use johnny5i, pixypi, or all.\n' >&2
        exit 1
        ;;
esac

mkdir -p -- "${pets_directory}"

install_pet() {
    local pet_id="$1"
    local source_pet_directory="${repository_root}/pet/${pet_id}"
    local source_manifest_path="${source_pet_directory}/pet.json"
    local source_spritesheet_path="${source_pet_directory}/spritesheet.webp"
    local target_pet_directory="${pets_directory}/${pet_id}"

    if [[ ! -f "${source_manifest_path}" ]]; then
        printf 'The source package is missing pet.json: %s\n' "${source_pet_directory}" >&2
        exit 1
    fi

    if [[ ! -f "${source_spritesheet_path}" ]]; then
        printf 'The source package is missing spritesheet.webp: %s\n' "${source_pet_directory}" >&2
        exit 1
    fi

    # Validate the required manifest fields without adding a jq dependency.
    if ! grep -Eq "\"id\"[[:space:]]*:[[:space:]]*\"${pet_id}\"" "${source_manifest_path}" ||
       ! grep -Eq "\"spriteVersionNumber\"[[:space:]]*:[[:space:]]*2" "${source_manifest_path}" ||
       ! grep -Eq "\"spritesheetPath\"[[:space:]]*:[[:space:]]*\"spritesheet\.webp\"" "${source_manifest_path}"; then
        printf 'The source manifest did not pass v2 validation: %s\n' "${source_manifest_path}" >&2
        exit 1
    fi

    # Keep backups outside the active pets directory so Codex does not scan
    # archived manifests as additional custom pets.
    if [[ -e "${target_pet_directory}" ]]; then
        mkdir -p -- "${pet_backups_directory}"
        local timestamp
        local archive_directory
        timestamp="$(date '+%Y%m%d-%H%M%S')-$$"
        archive_directory="${pet_backups_directory}/${pet_id}.archive-${timestamp}"
        mv -- "${target_pet_directory}" "${archive_directory}"
        printf 'Archived the previous %s installation to: %s\n' "${pet_id}" "${archive_directory}"
    fi

    cp -R -- "${source_pet_directory}" "${target_pet_directory}"

    if [[ ! -f "${target_pet_directory}/pet.json" ||
          ! -f "${target_pet_directory}/spritesheet.webp" ]]; then
        printf 'The installed %s package is incomplete.\n' "${pet_id}" >&2
        exit 1
    fi

    printf 'Installed %s successfully at: %s\n' "${pet_id}" "${target_pet_directory}"
}

for pet_id in "${pet_ids[@]}"; do
    install_pet "${pet_id}"
done

printf '\nRestart Codex or refresh Settings > Appearance > Pets.\n'
printf 'Select Johnny5i or PixyPi, then choose Wake Pet.\n'
