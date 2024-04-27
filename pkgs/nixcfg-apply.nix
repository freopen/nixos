{ writeShellApplication, nix-output-monitor }:
writeShellApplication {
  name = "nixcfg-apply";
  runtimeInputs = [ nix-output-monitor ];
  text = builtins.readFile ./nixcfg-apply.sh;
}
