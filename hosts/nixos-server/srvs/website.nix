{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.srvs.website;
in
{
  options.srvs.website.enable = mkEnableOption "Enable static web server";
  config = mkIf cfg.enable {
    environment.etc."www/index.html" = {
      mode = "0644";
      text = ''
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <title>ghov.net</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              margin: 0;
              padding: 0;
              font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
              background-color: #f9f9f9;
              color: #333;
              display: flex;
              flex-direction: column;
              align-items: center;
              min-height: 100vh;
            }

            header {
              margin-top: 60px;
              font-size: 2em;
              font-weight: bold;
              letter-spacing: 1px;
            }

            .directory {
              margin-top: 40px;
              width: 90%;
              max-width: 600px;
              display: flex;
              flex-direction: column;
              gap: 15px;
            }

            .link {
              display: block;
              padding: 15px 20px;
              text-decoration: none;
              color: #333;
              border: 1px solid #ddd;
              border-radius: 8px;
              background-color: #fff;
              transition: all 0.2s ease-in-out;
            }

            .link:hover {
              border-color: #aaa;
              background-color: #f0f0f0;
            }

            footer {
              margin-top: auto;
              padding: 20px;
              font-size: 0.9em;
              color: #999;
            }
          </style>
        </head>
        <body>

          <header>ghov.net</header>

          <div class="directory">
            <a class="link" href="https://media.ghov.net">Jellyfin</a>
            <a class="link" href="https://request.ghov.net">Ombi</a>
            <a class="link" href="https://torrent.ghov.net">Torrent</a>
            <a class="link" href="https://radarr.ghov.net">Radarr</a>
            <a class="link" href="https://sonarr.ghov.net">Sonarr</a>
            <a class="link" href="https://jackett.ghov.net">Jackett</a>
          </div>

          <footer>&copy; 2025 Gunnar Hovik</footer>

        </body>
        </html>
      '';
    };

    services.static-web-server = {
      enable = true;
      listen = "[::]:80";
      root = "/etc/www";
    };
  };
}
