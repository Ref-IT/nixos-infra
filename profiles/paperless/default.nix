{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.paperless;
in
{
  options.profiles.pretix = {
    enable = mkEnableOption (mdDoc "Enable the paperless-ngx profile");

    fqdn = mkOption {
      type = types.str;
      description = mdDoc ''
        The FQDN for the nginx vHost of paperless-ngx.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    sops.secrets = {
      "paperless-pw" = {
        owner = "pretix";
        group = "pretix";
        mode = "0400";
      };
    };

    services.pretix = {
      enable = true;
      gunicorn.extraArgs = [
        "--name=pretix"
        "--workers=8"
      ];
      nginx.domain = cfg.fqdn;
      settings = {
        pretix = {
          instance_name = cfg.fqdn;
          registration = false;
          url = "https://${cfg.fqdn}";
        };
        mail = {
          from = "pretix@stura-ilmenau.de";
          host = "imap.fem.tu-ilmenau.de";
          port = 587;
          user = "pretix@stura-ilmenau.de";
          password = config.sops.secrets."pretix-mail-pw".path;
        };
      };
    };

    /*services.borgbackup.jobs.pretix = {
      user = "root";
      group = "root";
      repo = "ssh://backup:23/./pretix";
      readWritePaths = [ "/var/lib/pretix/db-backup" ];
      preHook = ''
        cd /var/lib/pretix

        rm -f db-backup/*

        ${pkgs.mariadb}/bin/mysqldump ${config.services.pretix.settings.database.name} > db-backup/${config.services.pretix.settings.database.name}.sql
      '';
      paths = [ "config/config.php" "data" "db-backup" ];
      doInit = false;
      startAt = [ "*-*-* 03:30:00" ];
      encryption.mode = "repokey";
      encryption.passCommand = "cat ${config.sops.secrets."borg-passphrase".path}";
      prune.keep.within = "1y";
      compression = "auto,zstd";
      dateFormat = "+%Y-%m-%d";
      archiveBaseName = "backup";
    };*/
  };
}
