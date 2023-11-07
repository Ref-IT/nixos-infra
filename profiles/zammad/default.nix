{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.profiles.zammad;
in
{
  options.profiles.zammad = {
    enable = mkEnableOption (mdDoc "Enable the Zammad profile");

    bindHost = mkOption {
      type = types.str;
      description = mdDoc ''
        The FQDN for the nginx vHost of the Zammad.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.extraInputRules = ''
      ip saddr 10.170.20.0/24 tcp dport 3000 accept comment "zammad"
      ip saddr 10.170.20.0/24 tcp dport 6042 accept comment "zammad"
      ip6 saddr 2001:638:904:ffd0::/64 tcp dport 3000 accept comment "zammad"
      ip6 saddr 2001:638:904:ffd0::/64 tcp dport 6042 accept comment "zammad"
    '';

    sops.secrets = {
      "zammad-secret-key" = {
        owner = "zammad";
        group = "zammad";
        mode = "0400";
      };
    };

    services.zammad = {
      enable = true;
      host = cfg.bindHost;
      secretKeyBaseFile = config.sops.secrets."zammad-secret-key".path;
    };
  };
}