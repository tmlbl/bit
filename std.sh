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
