#! /bin/bash

prefix="$1"

mkdir -p "$prefix/"
os_type="`echo $OSTYPE | grep -oP '^.{5}'`"
if [[ "$os_type" == "linux" ]]; then
  cp -rT bin/ "$prefix/bin"
  cp -rT lib/ "$prefix/lib"
  cp -rT share/ "$prefix/share"
else
  cp -r bin/ "$prefix/bin"
  cp -r lib/ "$prefix/lib"
  cp -r share/ "$prefix/share"
fi
