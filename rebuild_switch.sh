#!/bin/sh
pushd /etc/nixos/
set -e
git --no-pager diff *.nix
echo "NixOS Rebuilding Switch..."
sudo nixos-rebuild switch >nixos-switch.log
(cat nixos-switch.log | grep --color error) && false
echo "Pushing to git..."
gen=$(nixos-rebuild --fast list-generations | head -n 2 | tail -n 1)
echo "Generation: $gen"
sudo git commit -am "NixOS Rebuild: $gen"
git push -u origin main
popd
