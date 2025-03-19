{ config, ... }:
{
  sops.secrets = {
    cloudflare_account_id = {
      owner = "postgres";
    };
    cloudflare_r2_access_key_id = {
      owner = "postgres";
    };
    cloudflare_r2_secret_access_key = {
      owner = "postgres";      
    };
  };
  sops.templates."rclone.conf" = {
    owner = "postgres";
    content = ''
      [backups]
      type = s3
      provider = Cloudflare
      access_key_id = ${config.sops.placeholder.cloudflare_r2_access_key_id}
      secret_access_key = ${config.sops.placeholder.cloudflare_r2_secret_access_key}
      endpoint = https://${config.sops.placeholder.cloudflare_account_id}.r2.cloudflarestorage.com
      acl = private
    '';
  };
}
