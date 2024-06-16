{
  config,
  pkgs,
  ...
}: {
  imports = [./opengl.nix];

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.videoDrivers = ["nvidia"];

  environment.systemPackages = [
    # only cuda 12+ support => other problems, hence broken at the moment
    # (pkgs.cudaPackages.tensorrt.override { autoAddDriverRunpath = pkgs.autoAddDriverRunpath; })
    (pkgs.cudaPackages.cudnn.override {inherit (pkgs) autoAddDriverRunpath;})
    (pkgs.cudaPackages.cutensor.override {inherit (pkgs) autoAddDriverRunpath;})
    pkgs.autoAddDriverRunpath
    pkgs.cudaPackages.cuda_opencl
    pkgs.cudaPackages.cudatoolkit
    pkgs.linuxPackages.nvidia_x11
  ];

  virtualisation.docker.enableNvidia = false;
}
