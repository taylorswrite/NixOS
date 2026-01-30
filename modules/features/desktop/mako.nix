{ self, ... }:
{
  flake.nixosModules.mako = { config, ... }: {
    home-manager.users."${config.my.user}" = {
      services.mako = {
        enable = true;

        settings = {
          max-history = 5;
          sort = "-time";
          default-timeout = 5000;

          anchor = "top-right";
          width = 400;
          height = 100;

          font = "JetBrainsMono Nerd Font 13";
          border-size = 2;
          padding = "5";
          markup = true;

          background-color = "#1e1e2e";
          text-color = "#cdd6f4";
          border-color = "#b4befe";
          progress-color = "over #313244";
        };

        extraConfig = ''
          [urgency=high]
          border-color=#fab387
        '';
      };
    };
  };
}
