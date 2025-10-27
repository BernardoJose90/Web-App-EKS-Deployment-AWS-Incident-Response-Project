# AWS Providers for multiple regions

# London region provider
provider "aws" {
  alias  = "london"
  region = var.region
  profile = "terraform-user"
}





