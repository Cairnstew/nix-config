# Configuration common to all Linux systems
{ flake, ... }:

let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [
    {
      users.users.${config.me.username}.isNormalUser = true;
      home-manager.users.${config.me.username} = { };
      home-manager.sharedModules = [
        self.homeModules.default
        self.homeModules.linux-only
      ];
    }
    self.nixosModules.common
    inputs.agenix.nixosModules.default # Used in github-runner.nix & hedgedoc.nix
    ./linux/self-ide.nix
    ./linux/current-location.nix
    ./linux/docker.nix
    #./linux/nvidia.nix
  ];

  boot.loader.grub.configurationLimit = 5; # Who needs more?
}
