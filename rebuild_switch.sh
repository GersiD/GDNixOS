#!/bin/sh
pushd /etc/nixos
git --no-pager diff *.nix
echo "NixOS Rebuilding Switch..."
sudo nixos-rebuild switch &>./nixos-switch.log
(cat nixos-switch.log | grep --color error)
if [ $? -eq 0 ]; then
  echo "NixOS Rebuild failed. Check nixos-switch.log"
  exit 1
fi
echo "Pushing to git..."
GEN=$(nixos-rebuild --fast list-generations | grep current)
echo "Generation: $GEN"
sudo git commit -am "NixOS Rebuild: $GEN"
git push -u origin main
popd
