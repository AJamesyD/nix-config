{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "claude-code-acp";
  version = "0.16.2";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "claude-code-acp";
    tag = "v${version}";
    hash = "sha256-NiUlTFNA9q56KoDb/2qan2wt7x4ls2IPBUcY3QHj3WA=";
  };

  npmDepsHash = "sha256-c8/dfHKY6BTNHMfkQs8+nOUefiy6QVUZ5+h/Hf+3Gsc=";

  # Build compiles TypeScript to dist/
  npmBuildScript = "build";

  meta = {
    description = "Agent Client Protocol adapter for Claude Code";
    homepage = "https://github.com/zed-industries/claude-code-acp";
    license = lib.licenses.mit;
    mainProgram = "claude-code-acp";
  };
}
