# Pin kanata to v1.12.0-prerelease-1 for defhands and
# tap-hold-opposite-hand (bilateral enforcement) support.
# TODO: remove when nixpkgs updates kanata to >= 1.12.0
final: prev:
let
  version = "1.12.0-prerelease-1";
  kanata-prebuilt = prev.stdenvNoCC.mkDerivation {
    pname = "kanata";
    inherit version;
    src = prev.fetchurl {
      url = "https://github.com/jtroo/kanata/releases/download/v${version}/macos-binaries-arm64.zip";
      hash = "sha256-8vep+XOwBl/E3heNwLmaYmspjMa6ttZo2cdRgIlyT1M=";
    };
    nativeBuildInputs = [ prev.unzip ];
    sourceRoot = ".";
    installPhase = ''
      install -Dm755 kanata_macos_arm64 $out/bin/kanata
    '';
  };
in
if prev.stdenvNoCC.hostPlatform.system == "aarch64-darwin" then
  {
    kanata = kanata-prebuilt;
    # Prevent nixpkgs from building kanata-with-cmd from source
    kanata-with-cmd = kanata-prebuilt;
  }
else
  { }
