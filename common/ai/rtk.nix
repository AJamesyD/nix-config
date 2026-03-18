{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage ../../pkgs/rtk { })
  ];
}
