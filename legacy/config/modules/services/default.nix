{...}: {
  imports = [
    ./printing.nix
    ./sshd.nix
    ./fail2ban.nix
    ./llm.nix
    ./stirling.nix
    ./routing.nix
  ];
}
