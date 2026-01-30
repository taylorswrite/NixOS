{ self, ... }:
{
  flake.nixosModules.tailscale = { config, pkgs, ... }: {
    # Tailscale client is unfree
    nixpkgs.config.allowUnfree = true;

    services.tailscale.enable = true;

    networking.firewall = {
      enable = true;
      # Trust the tailscale interface
      trustedInterfaces = [ "tailscale0" ];
      # Allow Tailscale UDP traffic
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
