{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.services.llm;
in {
  options.modules.services.llm = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        Host a local LLMs on the current machine.
      '';
    };
    acceleration = lib.mkOption {
      default = null;
      type = lib.types.nullOr (lib.types.enum ["rocm" "cuda"]);
      description = ''
        Use specific hardware to accelerate inference.
      '';
    };
    port = lib.mkOption {
      default = 4242;
      type = lib.types.port;
      description = ''
        Set the port for the webui.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.oterm ];
  
    services = {
      ollama = {
        inherit (cfg) acceleration;
        enable = true;
      };
      open-webui = {
        inherit (cfg) port;
        enable = true;
      };
    };
  };
}
