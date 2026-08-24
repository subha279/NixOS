{ ... }:

let
  vars = import ../../lib/variables.nix;
in
{
  config =
    if vars.nvidia.enable then
      {
        services.xserver.videoDrivers = [
          "modesetting"
          "nvidia"
        ];

        hardware.nvidia = {
          open = true;
          modesetting.enable = true;
          prime = {
            offload.enable = true;
            offload.enableOffloadCmd = true;
            intelBusId = vars.nvidia.intelBusId;
            nvidiaBusId = vars.nvidia.nvidiaBusId;
          };
        };
      }
    else
      {
        services.xserver.videoDrivers = [ "modesetting" ];
      };
}
