# Pin kanata to v1.12.0-prerelease-1 for defhands and
# tap-hold-opposite-hand (bilateral enforcement) support.
# TODO: remove when nixpkgs updates kanata to >= 1.12.0
final: prev:
let
  version = "1.12.0-prerelease-1";
  src = prev.fetchFromGitHub {
    owner = "jtroo";
    repo = "kanata";
    rev = "v${version}";
    hash = "sha256-aYKjC4g3QKfTlZsI2axRNdKEzdW9VSb6o7EtRBmQiqY=";
  };
in
{
  kanata = prev.kanata.overrideAttrs (old: {
    inherit version src;
    # Binary reports "kanata 1.12.0" without the prerelease suffix
    doInstallCheck = false;
    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit src;
      name = "kanata-${version}-vendor";
      hash = "sha256-GhiPQO2kbx8Y5EnGP+XOa2HNLSuH/YW+Yrxffusnhfo=";
    };
  });
}
