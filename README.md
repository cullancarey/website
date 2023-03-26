# Cullan's Portfolio Website

## About
Cullancarey.com is a static AWS S3 website fronted by Cloudfront. Please see the architecture diagram below. Two GitHub Actions [workflows](.github/workflows) kick off when I push changes to the GitHub repository. The first workflow focuses on code formatting and IaC security utilizing Black, Pylint, and Checkov. The second workflow deploys the terraform, pushes the website files to S3, and invalidates the Cloudfront cache, making the updates available immediately. This website is highly available. The main website bucket replicates to the failover bucket in a different region. Access to the S3 bucket is restricted to the Cloudfront OAI. Building cullancarey.com was a fun project for me to do, and I hope you visit the [site](https://www.cullancarey.com)!

## Automation
The automation for this repo's deployment utilized stack sets set up for my aws organization. My [aws_deployment-roles](https://github.com/cullancarey/aws_deployment_roles) repo holds CDK code which defines the Cloudformation stack set that deploys the deployment roles to the member accounts of my organization. I have created an OIDC GitHub Actions user in my management account. The actions first assume this role and then use this role to assume the deployment roles in the member accounts. Below is a diagram showing the flow of this architecture.

![image](./website_automation_arch.drawio.png)

The below outlines the workflow files and their purposes:

#### [plan.yaml](.github/workflows/plan.yaml)
This is a GitHub Actions workflow file that automates the process of deploying infrastructure using Terraform. The workflow file consists of two jobs: dev-terraform and prod-terraform.

The dev-terraform job is triggered when there is a pull request made against the develop branch. The prod-terraform job is triggered when there is a pull request made against the main branch.

Both jobs are run on an ubuntu-latest virtual machine and have a default shell of bash. The workflow begins with the actions/checkout@v3 action, which checks out the repository to the GitHub Actions runner.

The next step is to configure AWS credentials using the aws-actions/configure-aws-credentials@v2 action. This action assumes an IAM role and generates temporary AWS credentials using the aws sts assume-role command. These credentials are then exported as environment variables using the echo command and the $GITHUB_ENV file.

The hashicorp/setup-terraform@v1 action is then used to install the latest version of the Terraform CLI.

The Terraform Init step initializes a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc. It uses the backend.develop.conf or backend.main.conf files as the backend configuration depending on the branch.

The Terraform Format step checks that all Terraform configuration files adhere to a canonical format.

The Terraform Validate step checks that all Terraform configuration files are valid.

Finally, the Terraform Plan step generates an execution plan for Terraform. This plan is based on the Terraform configuration files and includes any changes that need to be made to the infrastructure.

The workflow file is split into two jobs to separate the deployment of infrastructure between the develop and main branches. This allows for a clear separation of responsibilities and prevents unwanted changes to the infrastructure.

#### [deploy.yaml](.github/workflows/deploy.yam)
This is a GitHub Action that deploys infrastructure and static site content to AWS (Amazon Web Services) using Terraform, AWS CLI, and AWS S3. The action consists of three jobs - dev-terraform, dev-deploy-files-to-S3, and prod-terraform.

The dev-terraform job deploys Terraform configurations in the development environment, while the prod-terraform job deploys in the production environment. These jobs have similar structures with a few differences, including the environment they deploy to, and the branch they listen to (develop or main).

The dev-deploy-files-to-S3 job deploys static site content to the S3 bucket in the development environment. This job depends on the dev-terraform job, which means that the infrastructure must be deployed first before deploying the static site content.

All jobs in this action use AWS CLI to configure AWS credentials and perform AWS-related tasks such as deploying infrastructure and content. The action uses GitHub secrets and environment variables to store sensitive information such as AWS access keys and secrets. The action also checks that Terraform configuration files adhere to a canonical format, initializes the Terraform working directory, validates the Terraform configuration, and applies the configuration to the infrastructure. Lastly, the action invalidates the Cloudfront cache, which is a content delivery network (CDN) used to speed up content delivery.

#### [format_code.yaml](.github/workflows/format_code.yaml)
This is a GitHub Actions file that defines a workflow to format, analyze and check the code in a Python project. Here is a breakdown of the different parts of the workflow:

The name of the workflow is "Format Code". The workflow is triggered by a push event to any branch except "main" and "develop". The workflow consists of three jobs: "format-black", "run-pylint", and "checkov".

The "format-black" job runs on an Ubuntu machine and does the following:
    Checks out the code using the actions/checkout action.
    Sets up Python using the actions/setup-python action.
    Installs the Black code formatter using pip.
    Formats the Python code files in the "Lambdas/" directory using Black.

The "run-pylint" job runs on an Ubuntu machine and does the following:
    Depends on the "format-black" job.
    Checks out the code using the actions/checkout action.
    Sets up Python using the actions/setup-python action.
    Installs the Pylint code analyzer using pip.
    Analyzes the Python code files ending with ".py" using Pylint.

The "checkov" job runs on an Ubuntu machine and does the following:
    Depends on the "run-pylint" job.
    Checks out the code using the actions/checkout action.
    Sets up Python 3.8 using the actions/setup-python action.
    Tests the Terraform code files in the "terraform/" directory using Checkov, a tool for static analysis of infrastructure as code.
    Uses a configuration file ".checkov.yaml" to configure the Checkov scan.


### Terraform
Terraform fully manages the website infrastructure, as seen in the [terraform](./terraform) directory.


### Architecture
![Architecture](./src/main/images/cullancarey-website-architecture.png)


### Disclosure
I did not write the HTML for this website. I am not a website developer, so I used a template from [HTML5 UP](http://html5up.net) and filled in the necessary details.
