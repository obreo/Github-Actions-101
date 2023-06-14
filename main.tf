
# Backend cofiguration
terraform {
  /*
  backend "remote" {
  # The name of your Terraform Cloud organization.
  organization = "ORGNIZATION_NAME"

  # The name of the Terraform Cloud workspace to store Terraform state files in.
  workspaces {
    name = "WORKSPACE_NAME"
  }
}
*/

  backend "s3" {
    bucket = "BUCKET_NAME"
    key    = "TERRAOFRM_OUTPUT_NAME_FILE"              # This is the name you provide that will be named and refered as a saved plan's output file
    region = "AWS_REGION"
  }
  
  required_providers {                                 # This assigns the aws library
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 0.14.0"
}

# Provider's configuration                            # This is to set up the configuration for the Terraform deployment
provider "aws" {
  region = "us-east-1"
}
