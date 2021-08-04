#! /usr/bin/env xonsh
# ar18 Script version 2021-08-04_22:57:42
# Script template version 2021-08-03_00:24:44

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
    print(f"{colorama.Back.WHITE}{colorama.Fore.BLACK}[*]{colorama.Style.RESET_ALL} {script_path(2)}")

    
  def ar18_log_exit():
    print(f"{colorama.Back.WHITE}{colorama.Fore.BLACK}[~]{colorama.Style.RESET_ALL} {script_path(2)}")
    
    
  def module_name():
    return os.path.basename(script_dir())
  
  
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

ar18.log.entry()

def temp_func(**kwargs):
#################################SCRIPT_START##################################
  print("ff")
  ar18.log.debug(script_dir())
  source @(script_dir())/vars
  config_dir = script_dir() + f"/{module_name}/config"
    
  ar18.script.include("script.validate_targets")
  ar18.script.validate_targets(config_dir, sys.argv[1:])
  
  ar18.script.include("sudo.ask_pass")
  ar18.sudo.ask_pass()
  
  ar18.script.include("script.uninstall")
  ar18.script.uninstall(install_dir, module_name, script_dir(), user_name)
  
  ar18.script.include("script.install")
  ar18.script.install(install_dir, module_name, script_dir(), user_name)
  

##################################SCRIPT_END###################################
ar18.system[os.path.basename(script_dir())][os.path.basename(script_path())[:-4]] = temp_func
if __name__ == "__main__":
  ar18.system[os.path.basename(script_dir())][os.path.basename(script_path())[:-4]]()
  
  
@events.on_exit
def on_exit():
  if os.getpid() == $AR18_PARENT_PROCESS and script_path() == $AR18_PARENT_SCRIPT:
    print("cleanup1")
    rm -rf @($AR18_TEMP_DIR)
  print("on_exit")
  ar18.log.exit()
