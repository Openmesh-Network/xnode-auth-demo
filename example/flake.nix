{
  inputs = {
    xnode-manager.url = "github:Openmesh-Network/xnode-manager";
    xnode-auth.url = "github:Openmesh-Network/xnode-auth";
    xnode-auth-demo.url = "github:Openmesh-Network/xnode-auth-demo";
    nixpkgs.follows = "xnode-auth-demo/nixpkgs";
  };

  nixConfig = {
    extra-substituters = [
      "https://openmesh.cachix.org"
    ];
    extra-trusted-public-keys = [
      "openmesh.cachix.org-1:du4NDeMWxcX8T5GddfuD0s/Tosl3+6b+T2+CLKHgXvQ="
    ];
  };

  outputs = inputs: {
    nixosConfigurations.container = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = [
        inputs.xnode-manager.nixosModules.container
        {
          services.xnode-container.xnode-config = {
            host-platform = ./xnode-config/host-platform;
            state-version = ./xnode-config/state-version;
            hostname = ./xnode-config/hostname;
          };
        }
        inputs.xnode-auth.nixosModules.default
        inputs.xnode-auth-demo.nixosModules.default
        (
          { lib, ... }:
          {
            # START USER CONFIG
            services.xnode-auth.domains."xnode-auth-demo".accessList."regex:^eth:.*$" = {
              paths = "^\/private(?:\\?.*)?$";
            };
            services.xnode-auth.domains."xnode-auth-demo".accessList."eth:519ce4c129a981b2cbb4c3990b1391da24e8ebf3" =
              { };
            services.xnode-auth.domains."xnode-auth-demo".paths = [
              "/private"
              "/admin"
            ];
            # END USER CONFIG

            services.nginx = {
              enable = true;
              virtualHosts."xnode-auth-demo" = {
                serverName = "xnode-auth.container";
                enableACME = true;
                forceSSL = true;
                locations."/" = {
                  proxyPass = "http://127.0.0.1:3000"; # xnode-auth-demo
                };
                # Separate location entries are requires if the root is not protected
                locations."/private" = {
                  proxyPass = "http://127.0.0.1:3000";
                };
                locations."/admin" = {
                  proxyPass = "http://127.0.0.1:3000";
                };
              };
            };

            # self-signed https certificate
            security.acme = {
              acceptTerms = true;
              defaults.email = "info@xnode-auth.container";
            };
            systemd.services."acme-xnode-auth.container".script = lib.mkForce ''echo "selfsigned only"'';

            services.xnode-auth.enable = true;
            services.xnode-auth-demo.enable = true; # Example application to protect

            networking.hostName = "xnode-auth";
            networking.firewall.allowedTCPPorts = [
              80
              443
            ];
          }
        )
      ];
    };
  };
}
