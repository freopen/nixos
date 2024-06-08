{ writeShellApplication, file, bat, chafa, }:
writeShellApplication {
  name = "fzf-preview";
  runtimeInputs = [ file bat chafa ];
  text = builtins.readFile ./fzf-preview.sh;
}
