# Github-Actions-101
Learn GitHub Actions in Simple English - Terraform with AWS workflow


## Introduction
Github Actions is a continous integration / continous deployment (CI/CD) tool, which is used to automate a deployment of any project. 

## How It Works

unlike some CI/CD tools similar to jenkines, Github uses its own backend from virtual instances to run and deploy your code. Each run uses a temprary virtual machine, so if your appliation requires saving the changes - like Terraform - then you will need a "Backend" that will manage these changes at every Github actions deployment. 

This backend can be any cloud service that integrates with your application and the Github actions' intergation.

## How to
To start a Github actions job, you will need the following requirements:
1. Repository: which will include your deployment file.
2. Actions Workflow: This is a configurations file which automates your program based on its type - such as python, NodeJS, Terraform, Docker.. etc

A good advantage of the github actions workflow is the ease of creating these workflow configurations - using YAML - and the availability of a preconfigured workflow scripts for the most popular appliations used. 

### Demo: Deploying an EC2 Instance on AWS cloud using Terraform Infarstructure as Code (IaC) automating tool

Terraform is a scripting automation tool used to build, deploy, and destroy cloud services' resources for tens of cloud providers. This tool helps to save time from setting up a cloud resource - Like VPS/EC2 instance, Storage, Database, and other cloud resources - manually and repeating this boring process everytime when needed. 

- You may refer to the [Terraform documnetation](https://developer.hashicorp.com/terraform/docs) to learn every and anything else about it. 

- Also this is a great [YouTube Tutorial](https://www.youtube.com/watch?v=SLB_c_ayRMo&list=PL8Cv29YkJcM_zGxPxDufx7prF_t0PyZtl&index=2) to learn everything about it and get your hands on in two hours.

**This demo will explain how the github actions workflow and its configurations work step by step. **
#### Step #1: Preparing the Terraform resources and provider's script:

Terraform has two main elements:

1. Provider configurations: which defines your log credintials and cloud service provider (CSP).
2. Resources: Any resource you want to deploy on the cloud.

Starting with the Provider:
1. Create a `main.tf` file - you may call it anything else.
2. One file is enough to include both of the provider settings and the resources. But for a better management and readability we will sepcify this for the provider settings only.
3. This is what it containers:
```

# Backend cofiguration
terraform {
  backend "s3" {
    bucket = "BUCKET_NAME"
    key    = "TERRAOFRM_OUTPUT_NAME_FILE"              # This is the name you provide that will be named and refered as a saved plan's output file
    region = "AWS_REGION"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 0.14.0"
}

# Provider's configuration
provider "aws" {
  region = "us-east-1"
}

```
The main purpose of Backend is to set a source where the terraform deployment can save its output file, if this output is not exist, then terraform will not be able to check the changes of our deployment, so it will assume there was no previous deployment and will create new resources each time and won't be able to delete them because it can not track the changes.

In backend, as mentioned earlier, you may choose any cloud provider that is integrating with terraform and the Github actions. There are two common backends to useL
1. Terraform Cloud: it is a service used by terraform that manages and saves your deployments' workflows.
2. AWS S3 storage: You can use this as in the code above which is easier to configure. 

To use the Terraform Cloud as a backend, add replace the content in the `Terraform {}` class with the following:
```
   backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "ORG_NAME"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "WORKSPACE_NAME"
    }
  }


```
