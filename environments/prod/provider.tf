# AWS Providers for multiple regions

# London region provider
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

# Ireland region provider (if needed)
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

# Default AWS provider (optional, if some modules use it).
provider "aws" {
  region = "eu-west-2"
}
