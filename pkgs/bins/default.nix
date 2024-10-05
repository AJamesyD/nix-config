{ stdenv, ... }:
stdenv.mkDerivation {
  name = "custom-bins";
  version = "unstable";
  src = ./bin;
  installPhase = # bash
    ''
      mkdir -p $out/bin
      cp * $out/bin
      ln -sf $out/bin/open $out/bin/xdg-open
    '';
}
