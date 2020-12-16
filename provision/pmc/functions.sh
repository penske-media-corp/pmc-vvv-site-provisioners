#!/usr/bin/env bash
##
## UTILITIES FOR PMC PROVISIONERS
##


# Utility to set up a directory from git or a local cache.
function pmc_git_dir_install_or_update() {
  local INSTALL_DIR="$1"
  local SHORT_NAME="$2"
  local INSTALL_TYPE="$3"
  local INSTALL_ARG="$4"

  echo " * Installing or updating ${SHORT_NAME}"

  if [ -d "$INSTALL_DIR" ]; then
      # shellcheck disable=SC2164
      cd "$INSTALL_DIR"

      if [ ! "$(ls -A "$INSTALL_DIR")" ]; then
        _pmc_git_dir_do_type "$INSTALL_DIR" "$INSTALL_TYPE" "$INSTALL_ARG"
        return
      fi

      # Ignore mode changes because Vagrant forces +x on everything.
      if \
        [ -z "$(git -c core.fileMode=false status --porcelain)" ] && \
        [ "$(git remote show origin | grep 'HEAD branch' | sed 's/.*: //')" == "$(git rev-parse --abbrev-ref HEAD)" ] \
      ; then
        noroot git pull --quiet --ff-only
      else
        echo "Not updating ${SHORT_NAME}, it either isn't on the default branch, or local changes were detected"
      fi
    else
      _pmc_git_dir_do_type "$INSTALL_DIR" "$INSTALL_TYPE" "$INSTALL_ARG"
    fi
}

# Utility function for pmc_git_dir_install_or_update.
function _pmc_git_dir_do_type() {
  local INSTALL_DIR="$1"
  local INSTALL_TYPE="$2"
  local INSTALL_ARG="$3"

  case "$INSTALL_TYPE" in
    git)
      noroot git clone --recursive --quiet "$INSTALL_ARG" "$INSTALL_DIR"
    ;;

    rsync)
      noroot rsync \
          --archive \
          --compress \
          "${INSTALL_ARG}/" "${INSTALL_DIR}/"
    ;;
  esac
}
