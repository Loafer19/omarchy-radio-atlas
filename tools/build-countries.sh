#!/usr/bin/env bash
# Rebuild assets/countries.json (detail) and assets/countries-coarse.json (used
# while the globe moves) from Natural Earth Admin 0 Countries.
#
# Requires curl, jq and mapshaper (npx is used when mapshaper is not on PATH).
# Country set and names follow the 1:110m data (ADMIN field); geometry comes from
# 1:50m and is simplified topologically, so shared borders stay aligned and no
# gaps open between neighbours at either detail level.
set -euo pipefail

version=${NATURAL_EARTH_VERSION:-v5.1.2}
detail=${DETAIL_KEEP:-15%}
coarse=${COARSE_KEEP:-4%}
project_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

base="https://raw.githubusercontent.com/nvkelso/natural-earth-vector/$version/geojson"
curl -fsSL -o "$work/ne_50m.geojson" "$base/ne_50m_admin_0_countries.geojson"
curl -fsSL -o "$work/ne_110m.geojson" "$base/ne_110m_admin_0_countries.geojson"

if command -v mapshaper >/dev/null 2>&1; then mapshaper=(mapshaper); else mapshaper=(npx --yes mapshaper); fi

# Countries shown on the globe: the 1:110m set (disputed areas without an ISO
# code are folded into the country Radio Browser files them under).
jq '[.features[].properties.ADMIN]' "$work/ne_110m.geojson" > "$work/admins.json"

build() {
  "${mapshaper[@]}" "$work/ne_50m.geojson" \
    -each "code = ISO_A2_EH; if (NAME == 'Somaliland') code = 'SO'; if (NAME == 'N. Cyprus') code = 'CY'; name = ADMIN" \
    -filter "$(jq -c . "$work/admins.json").indexOf(ADMIN) >= 0 && code !== '-99'" \
    -filter-fields name,code \
    -simplify "$1" keep-shapes \
    -o format=geojson precision=0.0001 "$2" 2>&1 | grep -v '^\[o\]' || true
}

build "$detail" "$project_dir/assets/countries.json"
build "$coarse" "$project_dir/assets/countries-coarse.json"
