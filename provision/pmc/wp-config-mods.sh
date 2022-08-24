#!/usr/bin/env bash

function pmc_load_vip_requires_in_wpconfig() {
  WP_CONFIG_PATH="$(noroot wp --skip-plugins --skip-themes config path)"
  TMP_WP_CONFIG_PATH="/tmp/mod-wp-config"

  VIP_GO_REQUIRES_ADDITION="// Load VIP's additional requirements.\nif ( file_exists( ABSPATH . '/wp-content/mu-plugins/000-pre-vip-config/requires.php' ) ) {\n\trequire_once ABSPATH . '/wp-content/mu-plugins/000-pre-vip-config/requires.php';\n}\n"
  VIP_GO_REQUIRES_ADDITION_ANCHOR="\/\*\* Sets up WordPress vars and included files\. \*\/"

  if [[ -n "$(grep '000-pre-vip-config/requires.php' "${WP_CONFIG_PATH}")" ]]; then
    echo ' * VIP requires already present'
  else
    echo ' * Adding VIP requires'

    awk "/${VIP_GO_REQUIRES_ADDITION_ANCHOR}/{print \"${VIP_GO_REQUIRES_ADDITION}\"}1" "${WP_CONFIG_PATH}" > "${TMP_WP_CONFIG_PATH}"
    mv -f "${TMP_WP_CONFIG_PATH}" "${WP_CONFIG_PATH}"
  fi
}

pmc_load_vip_requires_in_wpconfig
