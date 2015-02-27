#!/bin/bash

# Asks the user a yes or no question, returning the boolean result
# $1: Message message to print
# $2: Default answer (defaults to "no" (1))
std_askyesno() {
  local CONF="y/N"
  if [[ $2 == 0 ]]; then local CONF="Y/n"; fi
  local reply="n"
  read -p "$1 $CONF " -n 1 -r reply
  if [[ "$reply" ]]; then echo; fi
  if [[ $reply =~ ^[Yy]$ ]]; then
    return 0
  elif [[ $reply =~ ^[Nn]$ ]]; then
    return 1
  elif [[ $2 ]]; then
    return $2
  else
    return 1
  fi
}

std_killall() {
  ps aux | grep $1 > /dev/null
  mypid=$(pidof $1)
  if [ "$mypid" != "" ]; then
    kill -9 $(pidof $1)
    if [[ "$?" == "0" ]]; then
      echo "PID $mypid ($1) killed."
    fi
  else
    echo "None killed."
  fi
  return;
}

# FROM: https://indlovu.wordpress.com/2010/07/26/useful-bash-functions/
std_extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1        ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1       ;;
      *.rar)       rar x $1     ;;
      *.gz)        gunzip $1     ;;
      *.tar)       tar xf $1        ;;
      *.tbz2)      tar xjf $1      ;;
      *.tgz)       tar xzf $1       ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1    ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
