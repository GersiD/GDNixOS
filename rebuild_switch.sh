#!/usr/bin/env bash
pushd /etc/nixos/
set -e
git --no-pager diff *.nix
echo "NixOS Rebuilding Switch..."
sudo nixos-rebuild switch >nixos-switch.log || (sudo cat nixos-switch.log | grep --color error && false)
gen=$(nixos-rebuild list-generations | grep current)
echo "Pushing to git..."
sudo git commit -am "NixOS Rebuild: $gen"
git push -u origin main
popd
