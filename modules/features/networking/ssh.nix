{ self, ... }:
{
  flake.nixosModules.ssh = { config, lib, ... }: {
    services.openssh = {
      enable = true;
      settings = {
        # Hardening
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        
        # Traffic restrictions
        X11Forwarding = false;
        AllowAgentForwarding = "no";
        AllowStreamLocalForwarding = "no";
        
        # Authentication
        AuthenticationMethods = "publickey";
      };
    };

    # Open the default SSH port
    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
