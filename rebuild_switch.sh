#!/bin/sh
pushd /etc/nixos
git --no-pager diff *.nix
echo "NixOS Rebuilding Switch..."
sudo nixos-rebuild switch &>./nixos-switch.log
(cat nixos-switch.log | grep --color error)
if [ $? -eq 0 ]; then
  echo "NixOS Rebuild failed."
  notify-send "NixOS Rebuild failed." -t 3000 -u critical
  exit 1
fi
echo "NixOS Rebuild successful."
notify-send "NixOS Rebuild successful." -t 3000 -u normal
echo "Pushing to git..."
GEN=$(nixos-rebuild --fast list-generations | grep current)
echo "Generation: $GEN"
sudo git commit -am "NixOS Rebuild: $GEN"
sudo git push -u origin main
popd
