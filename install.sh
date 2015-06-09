#! /bin/bash

prefix="$1"
cp_switches="-r"

mkdir -p "$prefix/"
os_type="`echo $OSTYPE | grep -oP '^.{5}'`"
if [[ "$os_type" == "linux" ]]; then
  cp_switches="${cp_switches}T"
fi

cp "$cp_switches" bin/ "$prefix/bin"
cp "$cp_switches" lib/ "$prefix/lib"
cp "$cp_switches" share/ "$prefix/share"
