{ self, ... }:
{
  flake.nixosModules.fail2ban = { config, pkgs, ... }: {
    services.fail2ban = {
      enable = true;
      maxretry = 5;
      
      # SSH Jail Configuration
      jails.ssh-iptables = {
        settings = {
          backend = "systemd";
          filter = "sshd";
          action = "iptables[name=SSH, port=ssh, protocol=tcp]";
        };
      };
    };
  };
}
