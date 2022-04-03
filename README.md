# Welcome

## Cullan's Portfolio Website

- Cullancarey.com is a static AWS S3 website fronted by Cloudfront. Please see the architecture diagram [here](./src/images/cullancarey-website-architecture.png). When I push changes to the Github repository, an AWS CodePipeline is kicked off. This pipeline extracts the necessary files for the website and pushes them to the corresponding S3 bucket. It also invokes a Lambda function to invalidate the Cloudfront cache, so the updates are available immediately. You can view the lambda code [here](./lambda/invalidate.py). Terraform fully manages the website infrastructure, as seen in the [terraform](./terraform) directory. Full disclosure, I did not write the HTML for this website. I am not a website developer, so I used a template from [HTML5 UP](http://html5up.net) and filled in the necessary details. Building cullancarey.com was a fun project for me to do, and I hope you visit the site!
- Link! [cullancarey.com](https://www.cullancarey.com)


