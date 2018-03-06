#!/bin/bash

echo "LinShares v0.1 (c) Prodexity  (Licence: MIT)"

usage() {
  echo ""
  echo "linshares.sh [-d <shares directory>] [-r] [-s] [-p <group name prefix>] [-h]"
  echo ""
  echo "Options:"
  echo "  -d <shares directory>  Root directory of the share structure. Groups will be"
  echo "                         made based on this, permissions will be set here."
  echo "                         Default: ."
  echo "  -r                     Real run. Do not just simulate, actually add groups"
  echo "                         and set permissions."
  echo "  -s                     Simulation. Will only print actions. (Default)"
  echo "  -p <prefix>            System group name prefix. Default: 'shr_'"
  echo "  -g <start id>          New system group ids start from <start id>"
  echo "                         Default: 3000"
  echo "  -h                     Show help with command line options."
  echo ""
  exit 0
}

showerror() {
  echo "ERROR: $1"
  exit $2
}

create_group() {
  if [ ! $(getent group "$1") ]; then
    if [ $realrun == "true" ]; then
      groupadd -g $groupidstart -f "$1"
      echo "New group created: '$1'"
    else
      echo "groupadd -g $groupidstart -f \"${1}\""
    fi
    let groupidstart++
  fi
}

set_permissions() {
  sharedir=$1
  readgroup=$2
  writegroup=$3

  if [ $realrun == "true" ]; then
    chown root.root "$sharedir"
    chmod 751 "$sharedir"
    setfacl -m "group:$readgroup:r-x" "$sharedir"
    setfacl -m "group:$writegroup:rwx" "$sharedir"
    setfacl -d -m "group:$readgroup:r-x" "$sharedir"
    setfacl -d -m "group:$writegroup:rwx" "$sharedir"
  else
    echo "chown root.root \"$sharedir\""
    echo "chmod 751 \"$sharedir\""
    echo "setfacl -m \"group:$readgroup:r-x\" \"$sharedir\""
    echo "setfacl -m \"group:$writegroup:rwx\" \"$sharedir\""
    echo "setfacl -d -m \"group:$readgroup:r-x\" \"$sharedir\""
    echo "setfacl -d -m \"group:$writegroup:rwx\" \"$sharedir\""
  fi
}

if [ "$#" -eq 0 ]; then
  usage
fi

# parameter defaults
realrun=false
sharerootparam="."
groupprefix="shr_"
groupidstart=3000

# process command line parameters
while [[ "$#" > 0 ]]; do
  case $1 in
    -d)
      sharerootparam="$2"
      shift; shift
      ;;
    -r)
      realrun=true
      shift
      ;;
    -s)
      realrun=false
      shift
      ;;
    -p)
      groupprefix="$2"
      shift; shift
      ;;
    -g)
      groupidstart="$2"
      shift; shift
      ;;
    -h)
      usage
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ $(id -u) -ne 0 ]; then
  echo "WARNING: not running as root, only simulation may be possible."
  realrun=false
fi

cd "$sharerootparam" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  showerror "Directory does not exist or is inaccessible: '$sharerootparam'" 100
fi

shareroot=$(pwd)

echo "Running with parameters:"
echo "  share root directory = '$sharerootparam'"
echo "  share root absolute path = '$shareroot'"
echo "  system group name prefix = '$groupprefix'"
echo "  start from group id = $groupidstart"
echo "  real run = '$realrun'"

echo ""

dirs=$(find . -type d | tail --lines=+2 | sort)
for sharedir in $dirs; do
  groupbase=$(echo -n "$sharedir" | sed "s/\.\//$groupprefix/" | sed "s/\//_/g")
  readgroup="${groupbase}_ro"
  writegroup="${groupbase}_rw"

  create_group $readgroup
  create_group $writegroup

  set_permissions "$sharedir" "$readgroup" "$writegroup"
done
