{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.services.stirling;
in {
  options.modules.services.stirling = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        PDF manipulation service
      '';
    };
    port = lib.mkOption {
      default = 3256;
      type = lib.types.port;
      description = ''
        Port of the service
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.stirling-pdf = {
      inherit (cfg) enable;
      environment = {
        INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
        SERVER_PORT = cfg.port;
      };
    };
  };
}
