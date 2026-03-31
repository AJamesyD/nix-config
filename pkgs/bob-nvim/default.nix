{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "bob-nvim";
  version = "4.1.6";

  src = fetchFromGitHub {
    owner = "MordechaiHadad";
    repo = "bob";
    rev = "v4.1.6";
    hash = "sha256-XI/oNGKLXQ/fpB6MojhTsEgmmPH1pHECD5oZgc1r4rQ=";
  };

  cargoHash = "sha256-YSZcYTGnMnN/srh8Z15toq+GIyRKfFd+pGkFQl5gCuo=";
  doCheck = false;
}
