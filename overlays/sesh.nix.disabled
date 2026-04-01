# TODO: remove once nixpkgs updates sesh past 2.24.2
final: prev: {
  sesh = final.buildGoModule rec {
    pname = "sesh";
    version = "2.24.2";

    src = final.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "sesh";
      tag = "v${version}";
      hash = "sha256-iisAIn4km/uFw2DohA2mjoYmKgDQ3lYUH284Le3xQD0=";
    };

    vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

    ldflags = [
      "-s"
      "-w"
      "-X main.version=${version}"
    ];

    doCheck = false;

    meta = {
      description = "Smart session manager for the terminal";
      homepage = "https://github.com/joshmedeski/sesh";
      license = final.lib.licenses.mit;
      mainProgram = "sesh";
    };
  };
}
