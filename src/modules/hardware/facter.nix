{
  self,
  config,
  ...
}: {
  facter.reportPath = "${self}/src/settings/hosts/${config.networking.hostName}.json";
}
