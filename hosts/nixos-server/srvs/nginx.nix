{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.srvs.nginx;
in {
  options.srvs.nginx.enable = mkEnableOption "Enable nginx container";

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.proxy-manager = {
      autoStart = true;
      image = "jc21/nginx-proxy-manager:latest";
      ports = ["80:80" "81:81" "443:443"];
      volumes = [
        "/home/nginx/data:/data"
        "/home/nginx/letsencrypt:/etc/letsencrypt"
      ];
    };

    systemd = {
      tmpfiles.rules = [
        "d /home/nginx 774 root root -"
        "d /home/nginx/data 774 root root -"
        "d /home/nginx/letsencrypt 774 root root -"
      ];

      timers."dns-update-timer" = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "daily";
          Unit = "dns-update.service";
          Persistent = true;
        };
      };

      services."dns-update" = {
        description = "Tyco DNS Update";
        requires = ["network-online.target"];
        after = ["network-online.target"];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          Restart = "no";
          ExecStart = "${pkgs.python3Full}/bin/python /etc/scripts/dns-update.py";
        };
      };
    };

    age.secrets.secret1.file = ../../../secrets/secret1.age;
    environment.etc."scripts/dns-update.py".text = ''
      #!/usr/bin/python
      import http.client
      import json
      # Address and other api info
      addr = 'gamer.projecttyco.net'
      zone_id ='acedd06459615553d5e5fcada17cf813'
      identifier='be55c246e3e5276867dac9da7b4f8d4b'
      with open('${config.age.secrets.secret1.path}', 'r') as file:
        api_key = file.readline().rstrip()
      headers = {
          'Content-Type': "application/json",
          'Authorization': "Bearer %s" %(api_key)
          }
      # Get sender ip from web
      def get_ip():
          iphost = http.client.HTTPSConnection("ipapi.co")
          iphost.request("GET", "/ip/")
          respo = iphost.getresponse()
          ip_addr = respo.read()
          return ip_addr.decode("utf-8")
      # Get record IP
      def get_cloudflare_ip(cfheaders):
          cfhost = http.client.HTTPSConnection("api.cloudflare.com")
          cfhost.request("GET", "/client/v4/zones/%s/dns_records/%s" %(zone_id, identifier), headers=headers)
          cfresponse = cfhost.getresponse()
          cfresponse = cfresponse.read()
          cfresponse = cfresponse.decode("utf-8")
          cfresponse = json.loads(cfresponse)
          return cfresponse["result"]["content"]
      # Change the IP
      def update_cloudflare_ip(heads, ip_addr, web_addr, zone, ident ):
          conn = http.client.HTTPSConnection("api.cloudflare.com")
          payload = "{\n  \"content\": \"%s\",\n  \"name\": \"%s\",\n  \"proxied\": false,\n  \"type\": \"A\",\n  \"comment\": \"Domain verification record\",\n  \"ttl\": 3600\n}" %(ip_addr, web_addr)
          conn.request("PUT", "/client/v4/zones/%s/dns_records/%s/" %(zone, ident), payload, heads)
          res = conn.getresponse()
          data = res.read()
          data = data.decode("utf-8")
          data = json.loads(data)
          data_ip = data["result"]["content"]
          print('DNS record updated to IP:', data_ip)
      # Compare two IPs to test for match
      ip = get_ip()
      cfip = get_cloudflare_ip(headers)
      if cfip != ip:
          update_cloudflare_ip(headers, ip, addr, zone_id, identifier)
      else:
          print("IP addresses match, no DNS update needed")
    '';
  };
}
