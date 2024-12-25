terraform {
    backend "s3" {
      bucket = "terraform-devops-state-backend"
      key    = "terraform.tfstate"
      region = "gra"
      # sbg or any activated high performance storage region
      endpoint = "s3.gra.io.cloud.ovh.net"
      skip_credentials_validation = true
      skip_region_validation      = true
      #skip_s3_checksum            = true

      # The following fields should be added if your S3 user credentials are not
      # already configured in files ~/.aws/credentials, ~/.aws/config or in
      # environment variables.
      access_key                  = "some_access_key"
      secret_key                  = "some_secret_key"
    }
}