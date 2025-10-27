Purpose: Separate Terraform configurations for each AWS account in your organization
accounts/
├── management/        # AWS Organizations master account
├── security/          # Central security tools account
├── network/           # Shared networking account  
└── shared-services/   # Shared services account 