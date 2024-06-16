{pkgs, ...}: {
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    setLdLibraryPath = true;
    extraPackages = [pkgs.mesa.drivers];
  };

  environment.systemPackages = [
    pkgs.clinfo
    pkgs.khronos-ocl-icd-loader
    pkgs.ocl-icd
    pkgs.opencl-headers

    pkgs.libGL
    pkgs.libGLU

    pkgs.freeglut
    pkgs.mesa
    pkgs.ncurses5

    pkgs.xorg.libX11
    pkgs.xorg.libXext
    pkgs.xorg.libXi
    pkgs.xorg.libXmu
    pkgs.xorg.libXrandr
    pkgs.xorg.libXv
  ];
}
