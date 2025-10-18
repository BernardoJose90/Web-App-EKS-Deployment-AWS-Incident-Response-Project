# AWS Providers for multiple regions

# London region provider
provider "aws" {
  alias  = "london"
  region = var.region_london
}

# Ireland region provider (if needed).
provider "aws" {
  alias  = "ireland"
  region = var.region_ireland
}



