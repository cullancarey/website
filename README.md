# Cullan's Portfolio Website

## About
Cullancarey.com is a static AWS S3 website fronted by Cloudfront. Please see the architecture diagram below. Two GitHub Actions [workflows](.github/workflows) kick off when I push changes to the GitHub repository. The first workflow focuses on code formatting and IaC security utilizing Black, Pylint, and Checkov. The second workflow deploys the terraform, pushes the website files to S3, and invalidates the Cloudfront cache, making the updates available immediately. This website is highly available. The main website bucket replicates to the failover bucket in a different region. Access to the S3 bucket is restricted to the Cloudfront OAI. Building cullancarey.com was a fun project for me to do, and I hope you visit the [site](https://www.cullancarey.com)!


### Terraform
Terraform fully manages the website infrastructure, as seen in the [terraform](./terraform) directory.


### Architecture
![Architecture](./src/main/images/cullancarey-website-architecture.png)


### Disclosure
I did not write the HTML for this website. I am not a website developer, so I used a template from [HTML5 UP](http://html5up.net) and filled in the necessary details.
