{ inputs, config, rootPath, ... }:
{
  # This makes the sops-nix NixOS module available to your system
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    # Points to your encrypted secrets file in the repo root
    defaultSopsFile = "${rootPath}/secrets.yaml";
    
    # Automatically use the machine's SSH keys for decryption
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    
    # Placeholder for secrets you want to define
    secrets.spotify_password = {
      owner = config.my.user; # Ensure your user can read the decrypted file
    };
  };
}
