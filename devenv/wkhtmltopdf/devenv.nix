let
  # https://lazamar.co.uk/nix-versions/?package=wkhtmltopdf&version=0.12.5&fullName=wkhtmltopdf-0.12.5&keyName=wkhtmltopdf&revision=096bad8d75f1445e622d07faccce2e8ff43956c5&channel=nixos-20.03#instructions
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/096bad8d75f1445e622d07faccce2e8ff43956c5.tar.gz";
  }) {};
in {
  packages = with pkgs; [
    wkhtmltopdf
  ];
}
