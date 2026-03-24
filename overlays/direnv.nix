# Workaround: direnv's GNUmakefile adds -linkmode=external on Darwin
# (for DYLD_INSERT_LIBRARIES, see direnv/direnv#194), but nixpkgs sets
# CGO_ENABLED=0 for a static build. Go 1.26+ enforces that external
# linking requires CGO, breaking the build. Patch out the flag.
# TODO: Remove once nixpkgs updates the direnv derivation.
final: prev: {
  direnv = prev.direnv.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sed -i.bak '/linkmode=external/d' GNUmakefile
    '';
  });
}
