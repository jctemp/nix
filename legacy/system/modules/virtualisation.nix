{lib, ...}: {
  # Implement virtualization configurations
  config = lib.mkMerge [
    {
      virtualisation.vmVariant = {
        virtualisation.forwardPorts = [
          {
            from = "host";
            host.port = 8888;
            guest.port = 80;
          }
        ];

        # Hardware configuration for VMs
        diskSize = 32768; # 32 GB
        memorySize = 8192; # 8 GB
        cores = 4;
      };
    }
  ];
}
