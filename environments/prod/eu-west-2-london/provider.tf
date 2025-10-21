# AWS Providers for multiple regions

# London region provider
provider "aws" {
  alias  = "london"
  region = var.region
}

# Ireland region provider (if needed).
provider "aws" {
  alias  = "ireland"
  region = var.region
}



