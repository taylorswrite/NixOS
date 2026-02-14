{ inputs, ... }:
{
  flake.nixosModules.sops = { pkgs, config, ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ];

    sops = {
      # The encrytped secrets file
      defaultSopsFile = ./secrets.yaml;

      # private SSH key for decryption
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      secrets = {
        "spotify_email" = {
          owner = config.my.user;
        };
        "spotify_password" = {
          owner = config.my.user;
        };
      };
    };

    environment.systemPackages = [ pkgs.sops pkgs.ssh-to-age ];
  };
}
