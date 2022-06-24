#!/usr/bin/env bash

THEMES_DIR="${PUBLIC_DIR_PATH}/wp-content/themes"
CORETECH_THEMES_DIR="/tmp/pmc-coretech/themes"

echo " * Removing default themes"
rm -rf "${THEMES_DIR}/index.php"
find "${THEMES_DIR}" -type d -name "twenty*" -prune -exec rm -rf {} \;

USE_VIP_SUBDIR=$(get_config_value 'pmc.theme_dir_uses_vip' false)

# Set up `vip` subdirectory if production site uses it.
if [ "True" == "$USE_VIP_SUBDIR" ]; then
  THEMES_DIR="${THEMES_DIR}/vip"

  if [ ! -d "$THEMES_DIR" ]; then
    noroot mkdir "$THEMES_DIR"
  fi
fi

THEME_REPO=$(get_config_value 'pmc.theme_repo')
THEME_SLUG=$(get_config_value 'pmc.theme_slug' '')
PARENT_THEME_SLUG=$(get_config_value 'pmc.parent_theme_slug' '')

if [ -z "$THEME_REPO" ]; then
  echo " * Skipping theme installation as no repo is set."
  return
fi

if [ -z "$THEME_SLUG" ]; then
  BASENAME=$(basename "$THEME_REPO")
  THEME_SLUG=${BASENAME%.*}
fi

CHILD_THEME_DIR="${THEMES_DIR}/${THEME_SLUG}"

pmc_git_dir_install_or_update \
  "$CHILD_THEME_DIR" \
  "$THEME_SLUG" \
  "git" \
  "$THEME_REPO"

if [ -n "$PARENT_THEME_SLUG" ]; then
  pmc_git_dir_install_or_update \
    "${THEMES_DIR}/${PARENT_THEME_SLUG}/" \
    "$PARENT_THEME_SLUG" \
    "rsync" \
    "${CORETECH_THEMES_DIR}/${PARENT_THEME_SLUG}/"
fi

# Activate theme when necessary.
if [ -z "$PARENT_THEME_SLUG" ]; then
  PARENT_THEME_SLUG="$THEME_SLUG"
fi
if [ "True" == "$USE_VIP_SUBDIR" ]; then
  THEME_SLUG="vip/${THEME_SLUG}"
  PARENT_THEME_SLUG="vip/${PARENT_THEME_SLUG}"
fi

ACTIVE_THEME=$(noroot wp --skip-plugins --skip-themes option get stylesheet)
ACTIVE_PARENT=$(noroot wp --skip-plugins --skip-themes option get template)
if \
  [ "$THEME_SLUG" != "$ACTIVE_THEME" ] \
  || [ "$PARENT_THEME_SLUG" != "$ACTIVE_PARENT" ] \
; then
  noroot wp --skip-plugins --skip-themes option set stylesheet "$THEME_SLUG"
  noroot wp --skip-plugins --skip-themes option set template "$PARENT_THEME_SLUG"
  noroot wp cache flush
fi
