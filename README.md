# GitHub-Actions-101
Learn GitHub Actions in Simple English - Terraform with AWS workflow


## Introduction
GitHub Actions is a continuous integration / continuous deployment (CI/CD) tool, which is used to automate the deployment of any project. 

## How It Works

Unlike some CI/CD tools similar to Jenkins, Github uses its own backend from virtual instances to run and deploy your code. Each run uses a temporary virtual machine, so if your application requires saving the changes - like Terraform - then you will need a "Backend" that will manage these changes at every Github actions deployment. 

This backend can be any cloud service that integrates with your application and the GitHub actions' integration.

## How to
To start a GitHub actions job, you will need the following requirements:
1. Repository: This will include your deployment file.
2. Actions Workflow: This is a configurations file that automates your program based on its type - such as Python, NodeJS, Terraform, Docker.. etc

A good advantage of the GitHub actions workflow is the ease of creating these workflow configurations - using YAML - and the availability of preconfigured workflow scripts for the most popular applications used. 

### Demo: Deploying an EC2 Instance on AWS cloud using Terraform Infrastructure as Code (IaC) automating tool

Terraform is a scripting automation tool used to build, deploy, and destroy cloud services' resources for tens of cloud providers. This tool helps to save time from setting up a cloud resource - Like VPS/EC2 instance, Storage, Database, and other cloud resources - manually and repeating this boring process every time when needed. 

- You may refer to the [Terraform documnetation](https://developer.hashicorp.com/terraform/docs) to learn every and anything else about it. 

- Also this is a great [YouTube Tutorial](https://www.youtube.com/watch?v=SLB_c_ayRMo&list=PL8Cv29YkJcM_zGxPxDufx7prF_t0PyZtl&index=2) to learn everything about it and get your hands on in two hours.

**This demo will explain how the GitHub actions workflow and its configurations work step by step. **
#### Step #1: Preparing the Terraform resources and provider's script:

Terraform has two main elements:

1. Provider configurations: which define your log credentials and cloud service provider (CSP).
2. Resources: Any resource you want to deploy on the cloud.

### Starting with the Provider:
1. Create a `main.tf` file - you may call it anything else.
2. One file is enough to include both the provider settings and the resources. But for better management and readability, we will specify this for the provider settings only.
3. This is what it Containers:
```

# Backend configuration
terraform {
  backend "s3" {
    bucket = "BUCKET_NAME"
    key    = "TERRAOFRM_OUTPUT_NAME_FILE"              # This is the name you provide that will be named and referred as a saved plan's output file
    region = "AWS_REGION"
  }
  
  required_providers {                                 # This assigns the AWS library
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

```
The main purpose of Backend is to set a source where the Terraform deployment can save its output file, if this output does not exist, then Terraform will not be able to check the changes of our deployment, so it will assume there was no previous deployment and will create new resources each time and won't be able to delete them because it can not track the changes.

In the backend, as mentioned earlier, you may choose any cloud provider that is integrating with Terraform and the GitHub actions. There are two common backends to use
1. Terraform Cloud: it is a service used by Terraform that manages and saves your deployments' workflows.
2. AWS S3 storage: You can use this as in the code above which is easier to configure. 

To use the Terraform Cloud as a backend, add replace the content in the `Terraform {}` class with the following:
```
   backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "ORGNIZATION_NAME"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "WORKSPACE_NAME"
    }
  }


```
However, this requires setting up the Terraform Cloud and connecting it to the GitHub repository. You can refer to the Terraform Cloud [Docs](https://developer.hashicorp.com/terraform/cloud-docs)
#### Setting up your resources:

This is a script that creates an EC2 instance saved in `instance.tf` file :
```
# Instance
resource "aws_instance" "Instance" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  associate_public_ip_address = "true"
  root_block_device {
    volume_size = "8"
  }
  key_name  = ""                        # Add your keypair name here
  count     = 1
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update
    sudo yum install httpd -y
    sudo service httpd start
    sudo service httpd enable
    sudo echo "This was created using Terraform" >> /var/www/html/index.html
    EOF

  tags = {
    Name = "EC2 Instance"
  }
}


```
#### Step #2: Preparing the Terraform workflow:
1. Create a repository and push the files created to it.
2. We'll use an already Terraform workflow config available from Github by selecting the ` Actions > New Workflow > Search for Terraform `. Click on configure > commit changes.
3. Now the file is saved on your repository with the following directory `/.github/workflows/terraform.yaml`
4. We'll edit the file to suit our setup, you can edit the script from GitHub or clone the repository and replace the script with the following:
```
name: 'Terraform'                             # Workflow Name

on:                                           # It triggers the workflow when a push or pull event occurs in the repository
  push:
    branches: [ "main" ]
  pull_request:

permissions:
  contents: read                              # Giving permissions to the workflow to read-only

jobs:                                         # Here you can set multiple jobs, each job will do a task and they all run in parallel as soon as the content is retrieved.
  terraform:                                  
    name: 'Terraform'                         # Job-1, use ubuntu
    runs-on: ubuntu-latest          
    env:                                      # These are the AWS credentials, you need to register them in the GitHub secrets from the repo settings. The credentials are extracted from AWS IAM.
      AWS_ACCESS_KEY_ID: ${{secrets.AWS_ACCESS_KEY_ID}}
      AWS_SECRET_ACCESS_KEY: ${{secrets.AWS_SECRET_ACCESS_KEY}}
      AWS_REGION: "us-east-1"

    # Use the Bash shell regardless of whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash

    steps:                                    # These are actions done within a single job
    # Checkout the repository to the GitHub Actions runner.
    - name: Checkout
      uses: actions/checkout@v3

    # Install the latest version of Terraform CLI and configure the Terraform CLI configuration file with a Terraform Cloud user API token
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1
      with:
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}   # This is taken from your Terraform Cloud user API settings, save it in GitHub secrets.

    # Initialize a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.
    - name: Terraform Init
      run: terraform init

    # Checks that all Terraform configuration files adhere to a canonical format
    - name: Terraform Format
      run: terraform fmt

    # Generates an execution plan for Terraform
    - name: Terraform Plan
      run: terraform plan -input=false
      env:
        AWS_ACCESS_KEY_ID: ${{secrets.AWS_ACCESS_KEY_ID}}
        AWS_SECRET_ACCESS_KEY: ${{secrets.AWS_SECRET_ACCESS_KEY}}
        AWS_REGION: "us-east-1"

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -auto-approve -input=false
      env:
        AWS_ACCESS_KEY_ID: ${{secrets.AWS_ACCESS_KEY_ID}}
        AWS_SECRET_ACCESS_KEY: ${{secrets.AWS_SECRET_ACCESS_KEY}}
        AWS_REGION: "us-east-1"

```
After you are done, push the files again if you edited the workflow locally then it shall start the workflow CICD process automatically. You can check the steps applied in the terminal by viewing the actions tab and clicking on the workflow job.

## Best Security Practices

The above method is relatively secure, but for the best practices, we can deploy the workflow with more security by using OpenID Connect (OIDC) instead of assigning the user secret keys in Github. 

To learn more, follow this [documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

#### Step #1: Register the Identity provider in the AWS cloud from the IAM > Identity providers

- For the provider URL: Use https://token.actions.githubusercontent.com
- For the "Audience": Use sts.amazonaws.com

#### Step #2: Create a policy that will allow the s3 bucket we assigned previously - so it allows Terraform to read and write the output file - and any other policy you want to grant for the provider so that Terraform can deploy the resource. In our case, we will create a policy for the EC2.

1. S3:
`S3 policy`
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::BUCKET_NAME/*",
                "arn:aws:s3:::BUCKET_NAME"
            ]
        }
    ]
}
```
2. EC2 can be assigned using AWS-managed policies.

Step #3: Create a trust policy role with the below code and assign the above policies to it.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::YOUR_AWS_USER_ID:oidc-provider/token.actions.githubusercontent.com"  # This arn refers to the Identity provider you created.
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:GITHUB_USERNAME/GITHUB_REPOSITORY_NAME:*"
                }
            }
        }
    ]
}

```

Step #4: Edit the terraform workflow script by replacing the environment variables after the checkout job with the new credentials:

```
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        role-to-assume: arn:aws:iam::AWS_USER_ID:role/ROLE
        role-session-name: ANYNAME
        aws-region: AWS_REGION
```
Also, remove the provider configurations from the main.tf
