{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "claude-code-acp";
  version = "0.24.2";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "claude-code-acp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SRVbLcGrH5pJt6yfM0ObSso68M+yGateIVYf/kFVDhE=";
  };

  npmDepsHash = "sha256-V5lBQNhpL+/Mok9bEVSOrrHSv9B9pXKJswcXW+QDnAs=";

  # Build compiles TypeScript to dist/
  npmBuildScript = "build";

  meta = {
    description = "Agent Client Protocol adapter for Claude Code";
    homepage = "https://github.com/zed-industries/claude-code-acp";
    license = lib.licenses.mit;
    mainProgram = "claude-code-acp";
  };
})
