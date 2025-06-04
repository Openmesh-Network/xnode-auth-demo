{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.xnode-auth-demo;
  xnode-auth-demo = pkgs.callPackage ./package.nix { };
in
{
  options = {
    services.xnode-auth-demo = {
      enable = lib.mkEnableOption "Enable Xnode Auth Demo";

      hostname = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        example = "127.0.0.1";
        description = ''
          The hostname under which the app should be accessible.
        '';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        example = 3000;
        description = ''
          The port under which the app should be accessible.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = ''
          Whether to open ports in the firewall for this application.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.xnode-auth-demo = { };
    users.users.xnode-auth-demo = {
      isSystemUser = true;
      group = "xnode-auth-demo";
    };

    systemd.services.xnode-auth-demo = {
      wantedBy = [ "multi-user.target" ];
      description = "Xnode Auth example application.";
      after = [ "network.target" ];
      environment = {
        HOSTNAME = cfg.hostname;
        PORT = toString cfg.port;
      };
      serviceConfig = {
        ExecStart = "${lib.getExe xnode-auth-demo}";
        User = "xnode-auth-demo";
        Group = "xnode-auth-demo";
        CacheDirectory = "nextjs-app";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
