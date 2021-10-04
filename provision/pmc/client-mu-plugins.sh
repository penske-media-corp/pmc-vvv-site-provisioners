#!/usr/bin/env bash
# This is called both at the start of provisioning and after WP is installed.
# As such, it's possible that some or all of the directories will not exist.

CLIENT_MU_PLUGINS_DIR="${PUBLIC_DIR_PATH}/wp-content/client-mu-plugins"

# Add local-development helper.
LOCAL_DEV_HELPER_PATH="${PUBLIC_DIR_PATH}/wp-content/client-mu-plugins/plugin-loader.php"
if [ -d "${PUBLIC_DIR_PATH}/wp-content" ] && [ ! -d "${CLIENT_MU_PLUGINS_DIR}" ]; then
  mkdir "${CLIENT_MU_PLUGINS_DIR}"
fi
if [ -d "${CLIENT_MU_PLUGINS_DIR}" ]; then
  cp "${PMC_PROVISION_PATH}/pmc/templates/client-mu-plugins-plugin-loader.php" "${LOCAL_DEV_HELPER_PATH}"
fi
