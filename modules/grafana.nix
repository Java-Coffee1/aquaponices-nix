{ ... }:
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3232;
        enforce_domain = true;
        enable_gzip = true;
        domain = "gf.jv.ax";
        root_url = "https://gf.jv.ax/";
      }; # end of server
      security = {
        admin_user = "aqua";
        admin_password = "PASTE_PLAINTEXT_PASSWORD_HERE";
      };
      users.allow_sign_up = false;
      analytics.reporting_enabled = false;
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Aquaponics";
          type = "postgres";
          # Unix socket dir, not a host:port -- matches the Postgres role
          # "grafana" set up in modules/postgresql.nix (peer auth, no
          # password needed since this connects as the local grafana user).
          url = "/run/postgresql";
          database = "aqua";
          user = "grafana";
          isDefault = true;
          jsonData = {
            sslmode = "disable";
          };
        }
      ];
    };
  };
}
