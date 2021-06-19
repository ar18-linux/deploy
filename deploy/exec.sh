#!/bin/bash

# Script template version 2021-06-12.02
# Make sure some modification to LD_PRELOAD will not alter the result or outcome in any way
LD_PRELOAD_old="${LD_PRELOAD}"
LD_PRELOAD=
# Determine the full path of the directory this script is in
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
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
if [ -z "${ar18_exit_map+x}" ]; then
  declare -A -g ar18_exit_map
fi
ar18_exit_map["${script_path}"]=0
# Get old shell option values to restore later
shopt -s inherit_errexit
IFS=$'\n' shell_options=($(shopt -op))
# Set shell options for this script
set -o pipefail
set -eu
#################################SCRIPT_START##################################

set -x

if [ ! -v ar18_helper_functions ]; then rm -rf "/tmp/helper_functions_$(whoami)"; cd /tmp; git clone https://github.com/ar18-linux/helper_functions.git; mv "/tmp/helper_functions" "/tmp/helper_functions_$(whoami)"; . "/tmp/helper_functions_$(whoami)/helper_functions/helper_functions.sh"; cd "${script_dir}"; export ar18_helper_functions=1; fi
obtain_sudo_password
import_vars

export ar18_deployment_target="${1}"

source_or_execute_config "source" "deploy" "${ar18_deployment_target}"

export user_name="${user_name}"
export install_dir="${install_dir}"

"${script_dir}/../install.sh" "${ar18_deployment_target}"
# Upgrade system
echo "${ar18_sudo_password}" | sudo -S -k pacman -Syu --noconfirm


echo "${ar18_sudo_password}" | sudo -Sk rm -rf "${script_dir}/temp"

mkdir "${script_dir}/temp"
cd "${script_dir}/temp"

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
    echo "${ar18_sudo_password}" | sudo -Sk chmod +x "${module}/install.sh"
    "${module}/install.sh"
  fi
done

##################################SCRIPT_END###################################
# Restore old shell values
set +x
for option in "${shell_options[@]}"; do
  eval "${option}"
done
# Restore LD_PRELOAD
LD_PRELOAD="${LD_PRELOAD_old}"
# Return or exit depending on whether the script was sourced or not
if [ "${ar18_sourced_map["${script_path}"]}" = "1" ]; then
  return "${ar18_exit_map["${script_path}"]}"
else
  exit "${ar18_exit_map["${script_path}"]}"
fi
