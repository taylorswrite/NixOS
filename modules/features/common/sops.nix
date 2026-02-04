{ inputs, config, ... }:
{
  flake.nixosModules.sops = { pkgs, config, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops = {
      # This points to a secrets file in your flake root
      defaultSopsFile = ./secrets.yaml;

      # Use the host's SSH key for decryption
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      secrets = {
        "spotify_email" = {
          owner = config.my.user; # Set to your user "taylor"
        };
        "spotify_password" = {
          owner = config.my.user;
        };
      };
    };

    environment.systemPackages = [ pkgs.sops ];
  };
}
