{ stdenv, fetchzip }:
let
  pname = "renterd";
  version = "1.0.6";

in stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchzip {
    url =
      "https://github.com/SiaFoundation/renterd/releases/download/v${version}/renterd_linux_amd64.zip";
    sha256 = "sha256-PGDwmwhXu8d6ivZ4GWVyPK+Z4FrEDRjnVqQsK5vouDE=";
    stripRoot = false;
  };
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p "$out/bin"
    cp renterd "$out/bin/"
  '';
}
