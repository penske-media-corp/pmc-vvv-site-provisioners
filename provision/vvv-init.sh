#!/usr/bin/env bash

set -eo pipefail

PMC_PROVISION_PATH="${VVV_PATH_TO_SITE}/provision"

source "${PMC_PROVISION_PATH}/pmc/functions.sh"

vvv_info " * PMC site provisioner ${VVV_SITE_NAME}"

# Run default provisioner.
vvv_info "   > Installing WordPress"
. "${PMC_PROVISION_PATH}/default/provision/vvv-init.sh"

# Ensure VIP Go's pre-config requirements are loaded.
vvv_info "   > Adding necessary modifications to wp-config.php"
. "${PMC_PROVISION_PATH}/pmc/wp-config-mods.sh"

# Update URL to be HTTPS.
noroot wp --skip-plugins --skip-themes option set home "https://${DOMAIN}/"
noroot wp --skip-plugins --skip-themes option set siteurl "https://${DOMAIN}/"

# Apply PMC customizations.
vvv_info "   > Installing PMC plugins and theme(s)"
. "${PMC_PROVISION_PATH}/pmc/constants.sh"
. "${PMC_PROVISION_PATH}/pmc/plugins.sh"
. "${PMC_PROVISION_PATH}/pmc/themes.sh"

noroot wp --skip-plugins --skip-themes cache flush

vvv_info " * PMC site provisioner completed for ${VVV_SITE_NAME}"
