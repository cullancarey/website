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
RUN sudo apt-get install terraform



RUN terraform --version

CMD ["/bin/bash"]
