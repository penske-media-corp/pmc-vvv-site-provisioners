#!/usr/bin/env bash

DIRPATH="${PMC_PROVISION_PATH}/pmc"
WP_CONTENT_DIR="${PUBLIC_DIR_PATH}/wp-content"

echo " * Removing unneeded plugin files included with Core"
PLUGINS_TO_REMOVE="akismet/
hello.php
index.php"

for PLUGIN in $PLUGINS_TO_REMOVE; do
  rm -rf "${WP_CONTENT_DIR}/plugins/${PLUGIN}"
done

set +e
noroot shyaml get-values-0 < "${DIRPATH}/plugins.yml" |
while IFS='' read -r -d '' key &&
      IFS='' read -r -d '' value; do

  pmc_git_dir_install_or_update \
    "${WP_CONTENT_DIR}/${key}" \
    "$key" \
    "rsync" \
    "$value"
done
set -e

OBJECT_CACHE_PATH="mu-plugins/drop-ins/object-cache/object-cache.php"
OBJECT_CACHE_DEST="${WP_CONTENT_DIR}/object-cache.php"
if [ -f "${WP_CONTENT_DIR}/${OBJECT_CACHE_PATH}" ] && [ ! -f "$OBJECT_CACHE_DEST" ]; then
  noroot ln -s "$OBJECT_CACHE_PATH" "$OBJECT_CACHE_DEST"
fi
