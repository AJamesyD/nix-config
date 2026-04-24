{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
}:
let
  version = "4.1.6";
  sources = {
    aarch64-darwin = fetchurl {
      url = "https://github.com/MordechaiHadad/bob/releases/download/v${version}/bob-macos-arm.zip";
      hash = "sha256-RCIo4XoJ9de+h6RyiSoigMyaOWx818wfInxaYBf8Mlc=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/MordechaiHadad/bob/releases/download/v${version}/bob-linux-arm.zip";
      hash = "sha256-Dvz+U/pSre1h0/34oCwpqE1uVmNfrZ/ommqNV0xPHD8=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/MordechaiHadad/bob/releases/download/v${version}/bob-linux-x86_64.zip";
      hash = "sha256-45EmyRxgUgixWEoskyYivLLqchFlHoIzzg38As5fKYs=";
    };
  };
  sourceRoots = {
    aarch64-darwin = "bob-macos-arm";
    aarch64-linux = "bob-linux-arm";
    x86_64-linux = "bob-linux-x86_64";
  };
in
stdenvNoCC.mkDerivation {
  pname = "bob-nvim";
  inherit version;

  src =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "unsupported system: ${stdenvNoCC.hostPlatform.system}");

  sourceRoot =
    sourceRoots.${stdenvNoCC.hostPlatform.system}
      or (throw "unsupported system: ${stdenvNoCC.hostPlatform.system}");

  nativeBuildInputs = [ unzip ] ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    install -Dm755 bob $out/bin/bob
  '';

  meta = {
    description = "Neovim version manager";
    homepage = "https://github.com/MordechaiHadad/bob";
    license = lib.licenses.mit;
    mainProgram = "bob";
  };
}
