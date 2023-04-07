# Dockerfile to run aws cdk commands
# References
# - AWS CLI https://levelup.gitconnected.com/how-to-create-a-simple-docker-image-with-aws-cli-and-serverless-installed-d1cc2901946
FROM ubuntu:22.10
# Install dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common
RUN add-apt-repository universe
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    npm \
    nodejs \
    git \
    python3.10 \
    python3-pip
RUN npm config set unsafe-perm true
RUN npm update -g
RUN pip install --upgrade pip && \
    pip install --upgrade awscli && \
    pip install black && \
    pip install pylint && \
    pip install checkov==2.3.152
RUN npm install -g aws-cdk
RUN cdk --version
################################
# Install Terraform
################################

ENV TERRAFORM_VERSION=1.4.4
RUN apt-get update && apt-get install unzip
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
RUN sudo apt update
RUN sudo apt-get install terraform



RUN terraform --version

CMD ["/bin/bash"]
