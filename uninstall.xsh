#! /usr/bin/env xonsh
# ar18 Script version 2021-08-08_10:09:14
# Script template version 2021-08-08_09:55:39

if not "AR18_PARENT_PROCESS" in ${...}:
  import os
  import getpass
  import sys
  import colorama
  import inspect
  from datetime import datetime
  
  $AR18_LIB_XONSH = "ar18_lib_xonsh"
  
  # Raise exceptions if subprocesses return non-zero exit codes.
  $RAISE_SUBPROC_ERROR = True
  # Show additional debug information.
  $XONSH_SHOW_TRACEBACK = True
  # eval does not work in xonsh, source-bash eval must be used instead. 
  # Without this directive, there will be warnings about bash aliases.
  $FOREIGN_ALIASES_SUPPRESS_SKIP_MESSAGE = True
    
    
  def date_time():
    now = datetime.now()
    return now.strftime("%Y-%m-%d_%H:%M:%S.%f")
    
    
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
    ar18.script.include("script.uninstall")
    ar18.script.uninstall(subsystem_name(), $AR18_USER_NAME)
  except:
    raise
  finally:

##################################SCRIPT_END###################################
    ar18.system[subsystem_name()][f"{function_name()}_exit"]()
    
    
ar18.system[subsystem_name()][function_name()] = exec_func
  
  
def ar18_on_exit_handler():
  if is_parent():
    print("cleanup1")
    rm -rf @($AR18_TEMP_DIR)
  print("on_exit")
  ar18.log.exit()


ar18.system[subsystem_name()][f"{function_name()}_exit"] = ar18_on_exit_handler

if is_parent():
  ar18.system[subsystem_name()][function_name()]()
  
