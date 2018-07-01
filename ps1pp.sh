#!/bin/bash
################################################################################
# MIT License
# 
# Copyright (c) 2018 Daniel Pauli
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################


################################################################################
# constants
################################################################################

# colors
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
YELLOW="\[\e[1;33m\]"
CYAN="\[\e[1;36m\]"
WHITE="\[\e[1;37m\]"
NORMAL="\[\e[0m\]"

# file paths
BASHRC=~/.bashrc
INSTALL_PATH=~/.bash_ps1pp.sh

# markers for .bashrc section
MARKER_BEGIN="##### BEGIN ps1pp generated code #####"
MARKER_END="###### END ps1pp generated code ######"

################################################################################
# functions
################################################################################

# this function is called using PROMPT_COMMAND from bashrc
ps1pp() {
  # remember last exit code (must be first)
  local lasterr=$?

  # build prompt
  PS1="${CYAN}[${WHITE}\u@\h${CYAN}]-[${WHITE}\w$(git_info)${CYAN}]\n"
  PS1+="${CYAN}[$(err_info $lasterr)${CYAN}]\\$>${NORMAL} "
}

################################################################################

err_info() {
  local code=$1
  if [[ $code -ne 0 ]]; then
    if [[ $code -eq 130 ]]; then
      echo -e "${YELLOW}CNCL"
    else
      echo -e "${RED}ERR ${code}"
    fi
  else
    echo -e "${GREEN}OK"
  fi
}

################################################################################

git_info() {
  local git_info=""

  # get current branch
  # credits to https://coderwall.com/p/fasnya/add-git-branch-name-to-bash-prompt
  local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  if [[ $branch ]]; then
    # success, must be a git repository
    # check if dirty
    local status=$(git status --porcelain)
    if [[ $status ]]; then
      # there are changes, investigate more
      local status_without_untracked=$(echo "$status" | grep -v '?? ')
      if [[ $status_without_untracked ]]; then
        # general modification besides untracked files
        git_info="${RED}${branch}!"
      else
        # untracked files only
        git_info="$YELLOW${branch}*"
      fi
    else
      # no changes
      git_info="${GREEN}${branch}"
    fi
  fi

  if [[ $git_info ]]; then
    echo -e " ${WHITE}(${git_info}${WHITE})"
  fi
}

################################################################################

cmd_install() {
  # ensure everything is clean first
  cmd_uninstall

  # copy script to install location
  cp $0 $INSTALL_PATH

  # create bashrc entry
  echo $MARKER_BEGIN >> $BASHRC
  echo "source $INSTALL_PATH" >> $BASHRC
  echo "PROMPT_COMMAND=ps1pp" >> $BASHRC 
  echo $MARKER_END >> $BASHRC
}

################################################################################

cmd_uninstall() {
  # remove bashrc entry
  sed -i "/^${MARKER_BEGIN}/,/^${MARKER_END}/d" $BASHRC

  # remove from install location
  rm $INSTALL_PATH 2> /dev/null
}

################################################################################
# main
################################################################################

# check command
cmd=$1
if [[ $cmd == "install" ]]; then
  cmd_install
elif [[ $cmd == "uninstall" ]]; then
  cmd_uninstall
fi

################################################################################
# end of file

