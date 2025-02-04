{ config, ... }:
let
  user = {
    name = "tmpl";
    hashedPassword = "$y$j9T$ED2wTBe5BM1TISOGYdgS11$AkWjWs4kiI0n3kYdlUiuPC33m0aWXV/PK63U7n4Z823";
    keys =
      [
      ];
  };
  checkGroups = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.${user.name} = {
    inherit (user) name hashedPassword;
    isNormalUser = true;
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
      u = config.users.users.${user.name}.name;
      g = config.users.users.${user.name}.group;
    in
    [
      "d /home/${user.name}/.ssh 0750 ${u} ${g} -"
      "d /home/${user.name}/.ssh/sockets 0750 ${u} ${g} -"
    ];

  users.users.root = {
    hashedPassword = config.users.users.${user.name}.hashedPassword;
    openssh.authorizedKeys.keys = config.users.users.${user.name}.openssh.authorizedKeys.keys;
  };
}
