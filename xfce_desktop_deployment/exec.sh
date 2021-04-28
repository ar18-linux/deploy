#!/bin/bash

if [[ "$(whoami)" != "root" ]]; then
  read -p "[ERROR] must be root!"
  exit 1
fi

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

. "${script_dir}/vars"

mkdir "${script_dir}/temp"
cd "${script_dir}/temp"

for module in "${modules[@]}"; do
  git clone \
    --depth 1  \
    --filter=blob:none  \
    --sparse \
    "https://github.com/ar18-linux/${module}" \
  ;
  cd test-git-partial-clone
  git sparse-checkout set "${module}"
  #git clone "https://github.com/ar18-linux/${module}.git"
done