{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "mcp-hub";
  version = "4.2.1";

  src = fetchFromGitHub {
    owner = "ravitemer";
    repo = "mcp-hub";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KakvXZf0vjdqzyT+LsAKHEr4GLICGXPmxl1hZ3tI7Yg=";
  };

  npmDepsHash = "sha256-nyenuxsKRAL0PU/UPSJsz8ftHIF+LBTGdygTqxti38g=";

  # Build produces dist/cli.js
  npmBuildScript = "build";

  meta = {
    description = "MCP Hub server for managing multiple MCP servers";
    homepage = "https://github.com/ravitemer/mcp-hub";
    license = lib.licenses.mit;
    mainProgram = "mcp-hub";
  };
})
