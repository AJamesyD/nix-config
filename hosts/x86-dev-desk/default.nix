{
  ...
}:
{
  imports = [
    ../../common/aws.nix
  ];

  programs = {
    mise = {
      enable = true;
      globalConfig = {
        plugins = {
          node = "ssh://git.amazon.com/pkg/RtxNode";
        };
        tools = {
          node = [
            # TODO: move to aliases once RtxNode gets it together
            # "lts-gallium" # v16
            # "lts-hydrogen" # v18
            # "20" # iron
            "16.20.0"
            "18.20.2"
            "20.10.0"
          ];
        };
      };
    };
  };
}
