#!/usr/bin/env bash
# ar18

# Prepare script environment
{
  # Script template version 2021-07-06_08:05:30
  # Make sure some modification to LD_PRELOAD will not alter the result or outcome in any way
  LD_PRELOAD_old="${LD_PRELOAD}"
  LD_PRELOAD=
  # Determine the full path of the directory this script is in
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  script_path="${script_dir}/$(basename "${0}")"
  #Set PS4 for easier debugging
  export PS4='\e[35m${BASH_SOURCE[0]}:${LINENO}: \e[39m'
  # Determine if this script was sourced or is the parent script
  if [ ! -v ar18_sourced_map ]; then
    declare -A -g ar18_sourced_map
  fi
  if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    ar18_sourced_map["${script_path}"]=1
  else
    ar18_sourced_map["${script_path}"]=0
  fi
  # Initialise exit code
  if [ ! -v ar18_exit_map ]; then
    declare -A -g ar18_exit_map
  fi
  ar18_exit_map["${script_path}"]=0
  # Save PWD
  if [ ! -v ar18_pwd_map ]; then
    declare -A -g ar18_pwd_map
  fi
  ar18_pwd_map["${script_path}"]="${PWD}"
  # Get old shell option values to restore later
  shopt -s inherit_errexit
  IFS=$'\n' shell_options=($(shopt -op))
  # Set shell options for this script
  set -o pipefail
  set -eu
  if [ ! -v ar18_parent_process ]; then
    export ar18_parent_process="$$"
  fi
  # Get import module
  if [ ! -v ar18.script.import ]; then
    mkdir -p "/tmp/${ar18_parent_process}"
    cd "/tmp/${ar18_parent_process}"
    curl -O https://raw.githubusercontent.com/ar18-linux/ar18_lib_bash/master/ar18_lib_bash/script/import.sh > /dev/null 2>&1 && . "/tmp/${ar18_parent_process}/import.sh"
    cd "${ar18_pwd_map["${script_path}"]}"
  fi
}
#################################SCRIPT_START##################################

ar18.script.import ar18.script.obtain_sudo_password
ar18.script.import ar18.script.read_target
ar18.script.import ar18.script.import_vars
ar18.script.import ar18.script.execute_with_sudo
ar18.script.import ar18.script.source_or_execute_config

ar18.script.obtain_sudo_password
ar18.script.import_vars

set +u
export ar18_deployment_target="$(ar18.script.read_target "${1}")"
set -u

ar18.script.source_or_execute_config "source" "deploy" "${ar18_deployment_target}"

export user_name="${user_name}"
export install_dir="${install_dir}"

ar18.script.execute_with_sudo chmod +x "${script_dir}/../install.sh" 
"${script_dir}/../install.sh" "${ar18_deployment_target}"
# Upgrade system
ar18.script.execute_with_sudo pacman -Syu --noconfirm

temp_dir="/tmp/deploy"
ar18.script.execute_with_sudo rm -rf "${temp_dir}"

mkdir -p "${temp_dir}"
cd "${temp_dir}"

for module in "${modules[@]}"; do
  #git clone \
  #  --depth 1  \
  #  --filter=blob:none  \
  #  --sparse \
  #  "https://github.com/ar18-linux/${module}" \
  #;
  #cd "${module}"
  #git sparse-checkout set "${module}"
  git clone "https://github.com/ar18-linux/${module}.git"
  if [ -f "${module}/install.sh" ]; then
    ar18.script.execute_with_sudo chmod +x "${module}/install.sh"
    "${module}/install.sh"
  fi
done

##################################SCRIPT_END###################################
# Restore environment
{
  # Restore old shell values
  set +x
  for option in "${shell_options[@]}"; do
    eval "${option}"
  done
  # Restore LD_PRELOAD
  LD_PRELOAD="${LD_PRELOAD_old}"
  # Restore PWD
  cd "${ar18_pwd_map["${script_path}"]}"
}
# Return or exit depending on whether the script was sourced or not
{
  if [ "${ar18_sourced_map["${script_path}"]}" = "1" ]; then
    return "${ar18_exit_map["${script_path}"]}"
  else
    exit "${ar18_exit_map["${script_path}"]}"
  fi
}
