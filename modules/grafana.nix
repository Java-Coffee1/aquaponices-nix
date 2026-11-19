{ ... }:
{
  environment.etc."grafana-dashboards".source = "/home/aqua/grafana/dashboards";
  services.grafana = {
    enable = true;
    dataDir = "/home/aqua/grafana";
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
  };

  systemd.tmpfiles.settings."default"."/home/aqua/grafana".d = {
    user = "grafana";
    group = "grafana";
    mode = "755";
  };
  systemd.tmpfiles.settings."default"."/home/aqua/grafana/dashboards".d = {
    user = "grafana";
    group = "grafana";
    mode = "755";
  };
}
