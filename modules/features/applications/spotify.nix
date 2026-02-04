{ config, lib, pkgs, ... }: {
  flake.nixosModules.spotify = { pkgs, config, ... }: {
    services.spotifyd = {
      enable = true;
      settings = {
        global = {
          username_cmd = "cat ${config.sops.secrets.spotify_email.path}";
          password_command = "cat ${config.sops.secrets.spotify_password.path}";
          device_name = "pain";
          bitrate = 320;
          backend = "pulseaudio"; 
          volume_normalization = true;
          initial_volume = "90";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      spotifyd
      spotify-qt
    ];

    home-manager.users."${config.my.user}" = {
      xdg.configFile."spotify-qt/config.json".text = builtins.toJSON {
        client = {
          use_internal_player = false; 
        };
      };
    };
  };
}
