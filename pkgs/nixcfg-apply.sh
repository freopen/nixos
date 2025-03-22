set -o xtrace

flake=${1:-laptop}
op=${2:-switch}
old=/run/current-system

newLink=$(mktemp --dry-run)
nom build \
    "/home/freopen/Projects/nixos#nixosConfigurations.${flake}.config.system.build.toplevel" \
    --no-write-lock-file \
    --out-link "${newLink}"
new=$(readlink -f "${newLink}")
newDrv=$(nix path-info --derivation "${new}")

if [[ $flake == "laptop" ]]; then
  nix-diff "${old}" "${new}" --color always --character-oriented | bat
else
  nix copy --to "ssh://root@${flake}.freopen.org" --derivation "${new}"
  ssh "root@${flake}.freopen.org" nix-diff "${old}" "${newDrv}" --color always --character-oriented | bat
fi

read -r -p "Continue (y/n)? " reply
case "${reply}" in
  y|Y ) echo "Proceeding" ;;
  * ) exit 1 ;;
esac

if [[ $flake == "laptop" ]]; then
  sudo nixos-rebuild "${op}" --flake ".#${flake}" --no-write-lock-file
else
  nixos-rebuild "${op}" --target-host "root@${flake}.freopen.org" --flake ".#${flake}" --no-write-lock-file
fi
