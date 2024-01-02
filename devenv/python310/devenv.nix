{
  pkgs,
  lib,
  ...
}: let
  requirements = ../../odoo/community/requirements.txt;
in {
  packages = with pkgs; [
    nodejs_20
    nodePackages_latest.rtlcss

    old_nixos_revision_for_wkhtmltopdf_0_12_5.wkhtmltopdf

    # Odoo deps for requirements.txt
    cyrus_sasl.dev
    gcc
    gsasl
    openldap
  ];

  env.LD_LIBRARY_PATH = "${lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib]}:/run/opengl-driver/lib/:${lib.makeLibraryPath [pkgs.glib]}";
}
