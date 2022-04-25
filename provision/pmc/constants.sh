#!/usr/bin/env bash

DIRPATH="${PMC_PROVISION_PATH}/pmc"

set +e
noroot shyaml get-values-0 < "${DIRPATH}/constants.yml" |
while IFS='' read -r -d '' key &&
      IFS='' read -r -d '' value; do
    lower_value=$(echo "${value}" | awk '{print tolower($0)}')
    echo " * Adding constant '${key}' with value '${value}' to wp-config.php"
    if [ "${lower_value}" == "true" ] || [ "${lower_value}" == "false" ] || [[ "${lower_value}" =~ ^[+-]?[0-9]*$ ]] || [[ "${lower_value}" =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then
      noroot wp config set "${key}" "${value}" --raw
    else
      noroot wp config set "${key}" "${value}"
    fi
    # Enable WP_DEBUG in wp-config.php, already included via VVV's init.
    noroot wp config set WP_DEBUG true --raw
done
set -e
