#! /usr/bin/env xonsh
# ar18 Script version 2021-08-05_01:15:47
# Script template version 2021-08-05_01:15:23

if not "AR18_PARENT_PROCESS" in ${...}:
  import os
  import getpass
  import sys
  import colorama
  import inspect
  
  $AR18_LIB_XONSH = "ar18_lib_xonsh"
  
  # Raise exceptions if subprocesses return non-zero exit codes.
  $RAISE_SUBPROC_ERROR = True
  # Show additional debug information.
  $XONSH_SHOW_TRACEBACK = True
  # eval does not work in xonsh, source-bash eval must be used instead. 
  # Without this directive, there will be warnings about bash aliases.
  $FOREIGN_ALIASES_SUPPRESS_SKIP_MESSAGE = True
    
    
  def ar18_log_entry():
    print(f"{colorama.Back.WHITE}{colorama.Fore.BLACK}[*] {log_header()}{colorama.Style.RESET_ALL}")

    
  def ar18_log_exit():
    print(f"{colorama.Back.WHITE}{colorama.Fore.BLACK}[~] {log_header()}{colorama.Style.RESET_ALL}")
    
    
  def subsystem_name():
    return os.path.basename(script_dir(2))
  
  
  def function_name():
    return os.path.basename(script_path(2))[:-4]
    
    
  def log_header():
    c_stack = inspect.stack()[2]
    return f"{os.path.realpath(c_stack.filename)}: {c_stack.function}():{c_stack.lineno}"
  
  
  def get_user_name():
    if "AR18_USER_NAME" not in ${...}:
      $AR18_USER_NAME = getpass.getuser()
  
  
  def get_parent_process():
    if "AR18_PARENT_PROCESS" not in ${...}:
      $AR18_PARENT_PROCESS = os.getpid()
      $AR18_PARENT_SCRIPT = script_path(2)
      $AR18_TEMP_DIR = f"/tmp/xonsh/{$AR18_PARENT_PROCESS}"
      mkdir -p @($AR18_TEMP_DIR)
  
  
  def script_dir(frame_offset:int=1):
    return os.path.dirname(os.path.realpath(inspect.stack()[frame_offset].filename))
  
  
  def script_path(frame_offset:int=1):
    return os.path.realpath(inspect.stack()[frame_offset].filename)
  
  
  def get_environment():
    pass
    
    
  def is_parent():
    return (os.getpid() == $AR18_PARENT_PROCESS and script_path(2) == $AR18_PARENT_SCRIPT)
  
  
  def retrieve_file(url, dest_dir):
    old_cwd = os.getcwd()
    mkdir -p @(dest_dir)
    cd @(dest_dir)
    curl -f -O @(url) > /dev/null 2>&1
    cd @(old_cwd)
    
  
  def import_include():
    try:
      assert ar18.script.include
    except:
      # Check if ar18_lib_xonsh is installed on the system.
      # If it cannot be found, fetch it from github.com.
      install_dir_path = f"/home/{$AR18_USER_NAME}/.config/ar18/{$AR18_LIB_XONSH}/INSTALL_DIR"
      if os.path.exists(install_dir_path):
        file_path = open(install_dir_path).read().strip()
        if os.path.exists(file_path):
          file_path = f"{file_path}/{$AR18_LIB_XONSH}/{$AR18_LIB_XONSH}/ar18/script/include.xsh"
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


def exec_func(**kwargs):
  ar18.log.entry()
  try:
#################################SCRIPT_START##################################
    def ar18_extra_cleanup():
      print("cleanup 2")
    #ar18.sudo.exec("rm", "-rf", temp_dir)
    ar18.script.include("script.get_config_dir")
    config_dir = ar18.script.get_config_dir(script_dir(), subsystem_name())
    ar18.script.include("log.info")
    ar18.script.include("log.debug")
    ar18.script.include("log.fatal")
    ar18.script.include("log.error")
    ar18.log.info(config_dir)
    ar18.script.include("script.validate_targets")
    ar18.script.validate_targets(config_dir, sys.argv[1:], True)
    
    temp_dir = "/tmp/deploy"
    
    
    ar18.script.include("sudo.ask_pass")
    ar18.script.include("script.read_targets")
    #ar18.script.include("ar18.script.import_vars")
    ar18.script.include("sudo.exec_as")
    #ar18.script.include("ar18.script.source_or_execute_config")
    #ar18.script.include("ar18.script.version_check")
      
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
  
    $TARGET_USER_NAME = targets.index(0).user_name
    $TARGET_INSTALL_DIR = targets.index(0).install_dir
    $TARGET_RUN_LEVEL = targets.index(0).run_level
    ar18.script.include("script.check")
    ar18.script.check(len({k: v for k, v in targets.items() if v.user_name == $TARGET_USER_NAME}) == len(targets),
      "All selected targets must have the same user name.")
    ar18.script.check(len({k: v for k, v in targets.items() if v.install_dir == $TARGET_INSTALL_DIR}) == len(targets),
      "All selected targets must have the same install dir.")
    ar18.script.check(len({k: v for k, v in targets.items() if v.run_level == $TARGET_RUN_LEVEL}) == len(targets), 
      "All selected targets must have the same run level.") 
    
    ar18.sudo.ask_pass()
    ar18.sudo.exec_as(f"chmod +x {script_dir()}/../install.xsh")
    ar18.log.debug(script_dir())
    source @(script_dir())/../install.xsh
    
    ar18.system.deploy.install.run()
    #installed_ta



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

  except:
    raise
  finally:
    ar18_extra_cleanup

##################################SCRIPT_END###################################
    ar18.system[subsystem_name()][function_name()].exit()
    
    
ar18.system[subsystem_name()][function_name()].run = exec_func
  
  
def ar18_on_exit_handler():
  if is_parent():
    print("cleanup1")
    rm -rf @($AR18_TEMP_DIR)
  print("on_exit")
  ar18.log.exit()


ar18.system[subsystem_name()][function_name()].exit = ar18_on_exit_handler

if is_parent():
  ar18.system[subsystem_name()][function_name()].run()
  
