#!/bin/bash

set -e
set -x

read -s -p "foo:" foo

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

. "${script_dir}/vars"

export user_name="${user_name}"
export install_dir="${install_dir}"
export foo="${foo}"

rm -rf "${script_dir}/temp"

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
    chmod +x "${module}/install.sh"
    echo "${foo}" | sudo -Sk "${module}/install.sh"
  fi
done

git clone "https://github.com/ar18-linux/install_software.git"
chmod +x install_software/install_software/exec.sh

echo "${foo}" | install_software/install_software/exec.sh