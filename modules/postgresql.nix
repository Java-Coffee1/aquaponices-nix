{ lib, ... }:

{
  # Local-only database for sensor/control data from the touchscreen app.
  # No network exposure (no enableTCPIP) -- both the app and Grafana run on
  # the same Pi and talk to it over the Unix socket at /run/postgresql.
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "aqua" ];
    ensureUsers = [
      {
        # Peer-authenticated: the Linux "aqua" user can connect with no
        # password needed, since its OS username matches this role name.
        name = "aqua";
        ensureDBOwnership = true;
      }
      {
        # Same deal for the "grafana" system user/role.
        name = "grafana";
      }
    ];
  };

  # ensureUsers only creates the grafana role -- it doesn't grant it access
  # to the aqua role's tables. Grant read access now, and set up default
  # privileges so grafana can also read tables the app creates later.
  systemd.services.postgresql-setup.script = lib.mkAfter ''
    psql -d aqua -tAc "GRANT USAGE ON SCHEMA public TO grafana"
    psql -d aqua -tAc "GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana"
    psql -d aqua -tAc "ALTER DEFAULT PRIVILEGES FOR ROLE aqua IN SCHEMA public GRANT SELECT ON TABLES TO grafana"
  '';
}
