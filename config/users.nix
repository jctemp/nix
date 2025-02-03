{ config, ... }:
let
  user = {
    name = "tmpl";
    password = "$y$j9T$3p69Y8VnzNo6piNHJ6GKs.$2tdeDO3cnBwiYmnrMArqR141wtKEv9rlCrAtJwfv23A";
    keys =
      [
      ];
  };
  checkGroups = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.mutableUsers = true;

  users.users.${user.name} = {
    inherit (user) name;
    isNormalUser = true;
    hashedPassword = user.password;
    openssh.authorizedKeys.keys = user.keys;
    extraGroups =
      [
        "wheel"
      ]
      ++ (checkGroups [
        "audio"
        "video"
        "docker"
        "libvirt"
        "git"
        "networkmanager"
        # printing and scanning"
        "scanner"
        "lp"
      ]);
  };

  systemd.tmpfiles.rules =
    let
      user = config.users.users.${user.name}.name;
      group = config.users.users.${user.name}.group;
    in
    [
      "d /home/${user.name}/.ssh 0750 ${user} ${group} -"
      "d /home/${user.name}/.ssh/sockets 0750 ${user} ${group} -"
    ];

  users.users.root = {
    hashedPasswordFile = config.users.users.${user.name}.hashedPasswordFile;
    hashedPassword = config.users.users.${user.name}.hashedPassword;
    openssh.authorizedKeys.keys = config.users.users.${user.name}.openssh.authorizedKeys.keys;
  };
}
