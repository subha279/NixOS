{ ... }:

let
  vars = import ../../lib/variables.nix;
in
{
  config =
    if vars.hardware.nvidia.enable then
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
            intelBusId = vars.hardware.nvidia.intelBusId;
            nvidiaBusId = vars.hardware.nvidia.nvidiaBusId;
          };
        };
      }
    else
      {
        services.xserver.videoDrivers = [ "modesetting" ];
      };
}
