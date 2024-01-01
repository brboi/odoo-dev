{pkgs, ...}: {
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_14;
    initialScript = ''
      CREATE USER postgres WITH
        SUPERUSER
        PASSWORD 'PostgresqlSuperAdminP@ssw0rd';
      CREATE USER odoo     WITH
        CREATEDB
        PASSWORD 'odoo';
    '';
  };
}
