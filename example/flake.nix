{
  inputs = {
    xnode-manager.url = "github:Openmesh-Network/xnode-manager";
    xnode-auth.url = "github:Openmesh-Network/xnode-auth";
    xnode-auth-demo.url = "github:Openmesh-Network/xnode-auth-demo";
    nixpkgs.follows = "xnode-auth-demo/nixpkgs";
  };

  outputs = inputs: {
    nixosConfigurations.container = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = [
        inputs.xnode-manager.nixosModules.container
        inputs.xnode-auth.nixosModules.default
        inputs.xnode-auth-demo.nixosModules.default
        {
          # START USER CONFIG
          networking.hostName = "xnode-auth";
          nixpkgs.hostPlatform = "x86_64-linux";
          system.stateVersion = "25.05";
          services.xnode-auth.access."localhost" = [ "eth:519ce4c129a981b2cbb4c3990b1391da24e8ebf3" ];
          # END USER CONFIG

          services.nginx = {
            enable = true;
            virtualHosts."xnode-auth-demo" = {
              default = true;
              serverName = "_";
              locations = {
                "/" = {
                  proxyPass = "http://localhost:3000"; # xnode-auth-demo
                  extraConfig = ''
                    auth_request /xnode-auth/api/validate;
                    error_page 401 = @login;
                  '';
                };
                "/xnode-auth" = {
                  proxyPass = "http://localhost:34401";
                };
                "/xnode-auth/api/validate" = {
                  proxyPass = "http://localhost:34401/xnode-auth/api/validate";
                  extraConfig = ''
                    proxy_set_header Host $host;
                    proxy_pass_request_body off;
                    proxy_set_header Content-Length "";
                  '';
                };
                "@login" = {
                  return = "302 $scheme://$host/xnode-auth?redirect=$scheme://$host$request_uri";
                };
              };
            };
          };

          services.xnode-auth.enable = true;
          services.xnode-auth-demo.enable = true; # Example application to protect
        }
      ];
    };
  };
}
