# Dockerfile to run aws cdk commands
# References
# - AWS CLI https://levelup.gitconnected.com/how-to-create-a-simple-docker-image-with-aws-cli-and-serverless-installed-d1cc2901946
FROM ubuntu:22.10
# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    npm \
    git \
    unzip \
    python3.10 \
    python3-pip
RUN npm config set unsafe-perm true
RUN npm update -g
RUN pip install --upgrade pip && \
    pip install --upgrade awscli && \
    pip install black && \
    pip install pylint && \
    pip install checkov==2.3.152
    pip install aws-cdk-lib==2.70.0
    pip install constructs>=10.0.0,<11.0.0
RUN npm install -g aws-cdk
RUN cdk --version

ENV TERRAFORM_VERSION=1.4.4

# Download terraform for linux
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Unzip
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Move to local bin
RUN mv terraform /usr/local/bin/
# Check that it's installed
RUN terraform --version



RUN terraform --version

CMD ["/bin/bash"]
