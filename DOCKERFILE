# Dockerfile to run aws cdk commands
# References
# - AWS CLI https://levelup.gitconnected.com/how-to-create-a-simple-docker-image-with-aws-cli-and-serverless-installed-d1cc2901946
FROM alpine:3.16.2
RUN apk update && apk add --update --no-cache \
    git \
    bash \
    curl \
    openssh \
    python3 \
    py3-pip \
    py-cryptography \
    wget \
    curl \
    nodejs \
    npm
RUN apk --no-cache add --virtual builds-deps build-base python3
RUN npm config set unsafe-perm true
RUN npm update -g
RUN pip install --upgrade pip --ignore-installed packaging && \
    pip install --upgrade awscli && \
    pip install black && \
    pip install pylint && \
    pip install checkov
RUN npm install -g aws-cdk
RUN cdk --version
################################
# Install Terraform
################################

ENV TERRAFORM_VERSION=1.4.4
RUN apt-get update && apt-get install unzip \
    && curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && curl https://keybase.io/hashicorp/pgp_keys.asc | gpg --import \    && curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig \
    && gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && shasum -a 256 c terraform_${TERRAFORM_VERSION}_SHA256SUMS 2>&1 | grep "${TERRAFORM_VERSION}_linux_amd64.zip:\sOK" \
    && unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin
RUN terraform --version

CMD ["/bin/bash"]
