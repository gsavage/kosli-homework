FROM ubuntu

# Install dependencies needed to install Terraform
RUN apt-get update && apt-get -y install wget gpg lsb-release make curl unzip groff less

# Terraform's own installation instructions
RUN wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt-get update && apt-get -y install terraform

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Prepare a directory for the code and a user to own it
RUN mkdir /code
RUN useradd -m dev
RUN chown dev:dev /code

USER dev

RUN mkdir /home/dev/.aws

WORKDIR /code


