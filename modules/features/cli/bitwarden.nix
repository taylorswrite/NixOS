{ pkgs, config, lib, ... }:
{
  flake.nixosModules.bitwarden = {
    environment.systemPackages = [ pkgs.bitwarden-desktop ];

    # Configure SSH to look for Bitwarden's socket
    home-manager.users."${config.my.user}" = {
      home.sessionVariables = {
        SSH_AUTH_SOCK = "/run/user/1000/bitwarden-ssh-agent.sock";
      };

      # Configure ~/.ssh/config to force this agent
      programs.ssh = {
        enable = true;
        extraConfig = ''
          IdentityAgent /run/user/1000/bitwarden-ssh-agent.sock
        '';
      };
    };
  };
}
