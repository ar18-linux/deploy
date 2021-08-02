#! /usr/bin/env xonsh
# ar18 Script version 2021-08-02_23:58:55
# Script template version 2021-08-02_23:36:15

if not "AR18_PARENT_PROCESS" in {...}:
  import os
  import getpass
  import sys
  
  $AR18_LIB_XONSH = "ar18_lib_xonsh"
  
  # Raise exceptions if subprocesses return non-zero exit codes.
  $RAISE_SUBPROC_ERROR = True
  # Show additional debug information.
  $XONSH_SHOW_TRACEBACK = True
  # eval does not work in xonsh, source-bash eval must be used instead. 
  # Without this directive, there will be warnings about bash aliases.
  $FOREIGN_ALIASES_SUPPRESS_SKIP_MESSAGE = True
  
  
  @events.on_exit
  def test():
    if os.getpid() == $AR18_PARENT_PROCESS:
      rm -rf @($AR18_TEMP_DIR)
    print("on_exit")
    
    
  def ar18_log_entry():
    print(f"[*] {get_script_path()}")
    
    
  def ar18_log_exit():
    print(f"[~] {get_script_path()}")
    
    
  def module_name():
    return os.path.basename(script_dir())
  
  
  def get_user_name():
    if "AR18_USER_NAME" not in {...}:
      $AR18_USER_NAME = getpass.getuser()
  
  
  def get_parent_process():
    if "AR18_PARENT_PROCESS" not in {...}:
      $AR18_PARENT_PROCESS = os.getpid()
      $AR18_TEMP_DIR = f"/tmp/xonsh/{$AR18_PARENT_PROCESS}"
      mkdir -p @($AR18_TEMP_DIR)
  
  
  def script_dir():
    return os.path.dirname(os.path.realpath(__file__))
  
  
  def script_path():
    return os.path.realpath(__file__)
  
  
  def get_environment():
    pass
  
  
  def retrieve_file(url, dest_dir):
    old_cwd = os.getcwd()
    mkdir -p @(dest_dir)
    cd @(dest_dir)
    curl -f -O @(url)
    cd @(old_cwd)
    
  
  def import_include():
    try:
      assert ar18.script.include
    except:
      # Check if ar18_lib_xonsh is installed on the system.
      # If it cannot be found, fetch it from github.com.
      install_dir_path = f"/home/{$AR18_USER_NAME}/.config/ar18/{$AR18_LIB_XONSH}/INSTALL_DIR"
      if os.path.exists(install_dir_path):
        file_path = open(install_dir_path).read()
        if os.path.exists(file_path):
          file_path = f"{file_path}/{$AR18_LIB_XONSH}/ar18/script/include.xsh"
      else:
        file_path = f"{$AR18_TEMP_DIR}/{$AR18_LIB_XONSH}/ar18/script/include.xsh"
        mkdir -p @(os.path.dirname(file_path))
      if not os.path.exists(file_path):
        print("get from github")
        retrieve_file(
          f"https://raw.githubusercontent.com/ar18-linux/{$AR18_LIB_XONSH}/master/{$AR18_LIB_XONSH}/ar18/script/include.xsh",
          os.path.dirname(file_path)
        )
      source @(file_path)
  
  get_user_name()
  get_parent_process()
  import_include()
else:
  ar18.log.entry()
#################################SCRIPT_START##################################

#config_dir = script_dir() + "/config"
config_dir = ar18.script.get_config_dir(script_dir(), module_name())
ar18.script.include("script.validate_targets")
ar18.script.validate_targets(config_dir, sys.argv[1:])

temp_dir = "/tmp/deploy"

@events.on_exit
def ar18_extra_cleanup():
  print("cleanup 2")
  #ar18.sudo.exec("rm", "-rf", temp_dir)


ar18.script.include("sudo.ask_pass")
ar18.script.include("script.read_targets")
#ar18.script.include("ar18.script.import_vars")
ar18.script.include("sudo.exec_as")
#ar18.script.include("ar18.script.source_or_execute_config")
#ar18.script.include("ar18.script.version_check")

#ar18.sudo.ask_pass()
  
old_targets = ar18.script.read_targets()
# Remove old installations.
# Todo
for key,target in old_targets.items():
  print(key,target)
  
print("sds")
targets = Ar18.Struct()
for arg in sys.argv[1:]:
  targets[arg] = Ar18.Struct(config_dir + "/" + arg + ".json5")
  print(arg)
print(len(targets))
assert len({k: v for k, v in targets.items() if v.user_name == targets.index(0).user_name}) == len(targets), "All selected targets must have the same user name."
assert len({k: v for k, v in targets.items() if v.install_dir == targets.index(0).install_dir}) == len(targets), "All selected targets must have the same install dir."
assert len({k: v for k, v in targets.items() if v.run_level == targets.index(0).run_level}) == len(targets), "All selected targets must have the same run level."
  
$TARGET_USER_NAME = targets.index(0).user_name
$TARGET_INSTALL_DIR = targets.index(0).install_dir
  
ar18.sudo.exec_as(f"chmod +x {script_dir}/../install.xsh")
@(script_dir)/../install.xsh
  

"""
ar18.script.version_check "${@}"


ar18.script.execute_with_sudo chmod +x "${script_dir}/../install.sh" 
"${script_dir}/../install.sh" "${ar18_deployment_target}"
# Upgrade system
ar18.script.execute_with_sudo pacman -Syu --noconfirm

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

ar18.script.execute_with_sudo systemctl set-default "${ar18_run_level}"
"""

##################################SCRIPT_END###################################

#end
