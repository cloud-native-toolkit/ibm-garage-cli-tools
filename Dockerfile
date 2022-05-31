FROM docker.io/hashicorp/terraform:1.1.9

ARG TARGETPLATFORM
ENV OPENSHIFT_CLI_VERSION 4.10

RUN apk add --update-cache \
  curl \
  unzip \
  sudo \
  shadow \
  bash \
  openssl \
  ca-certificates \
  perl \
  openvpn \
  gcompat \
  jq \
  && rm -rf /var/cache/apk/*


## AWS cli
RUN apk add --no-cache \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install \
        awscli \
    && rm -rf /var/cache/apk/* \
    && aws --version


## Azure cli
RUN apk add gcc musl-dev python3-dev libffi-dev openssl-dev cargo make \
    && pip install --upgrade pip \
    && pip install azure-cli \
    && az --version


WORKDIR $GOPATH/bin

COPY src/bin/* /usr/local/bin/

##################################
# User setup
##################################

# Configure sudoers so that sudo can be used without a password
RUN groupadd --force sudo && \
    chmod u+w /etc/sudoers && \
    echo "%sudo   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV HOME /home/devops

# Create devops user
RUN useradd -u 10000 -g root -G sudo -d ${HOME} -m devops && \
    usermod --password $(echo password | openssl passwd -1 -stdin) devops && \
    mkdir -p /workspaces && \
    chown -R 10000:0 /workspaces

USER devops
WORKDIR ${HOME}

COPY --chown=devops:root src/home/ ${HOME}/

##################################
# IBM Cloud CLI
##################################

# Install the ibmcloud cli
RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh && \
    ibmcloud plugin install container-service -f && \
    ibmcloud plugin install container-registry -f && \
    ibmcloud plugin install observe-service -f && \
    ibmcloud plugin install vpc-infrastructure -f && \
    ibmcloud config --check-version=false

WORKDIR ${HOME}

RUN cat ./image-message >> ./.bashrc-ni

RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-${OPENSHIFT_CLI_VERSION}/openshift-client-linux.tar.gz --output oc-client.tar.gz && \
    mkdir tmp && \
    cd tmp && \
    tar xzf ../oc-client.tar.gz && \
    sudo mv ./oc /usr/local/bin && \
    cd .. && \
    rm -rf tmp && \
    rm oc-client.tar.gz

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)/kubectl" && \
    chmod +x ./kubectl && \
    sudo mv ./kubectl /usr/local/bin

#RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash && \
#    sudo cp /usr/local/bin/helm /usr/local/bin/helm3

#RUN sudo chown -R devops ${HOME} && sudo chgrp -R 0 ${HOME} && sudo chmod -R g=u ${HOME}

RUN wget -q -O ./yq $(wget -q -O - https://api.github.com/repos/mikefarah/yq/releases/tags/3.4.1 | jq -r --arg NAME "yq_linux_$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)" '.assets[] | select(.name == $NAME) | .browser_download_url') && \
    chmod +x ./yq && \
    sudo mv ./yq /usr/bin/yq

RUN wget -q -O ./yq4 $(wget -q -O - https://api.github.com/repos/mikefarah/yq/releases/tags/v4.16.1 | jq -r --arg NAME "yq_linux_$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)" '.assets[] | select(.name == $NAME) | .browser_download_url') && \
    chmod +x ./yq4 && \
    sudo mv ./yq4 /usr/bin/yq4

RUN wget -q -O ./helm.tar.gz https://get.helm.sh/helm-v3.8.2-linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi).tar.gz && \
    tar xzf ./helm.tar.gz linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)/helm && \
    sudo mv ./linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)/helm /usr/bin/helm && \
    rmdir ./linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi) && \
    rm ./helm.tar.gz

RUN wget -q -O ./terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.36.10/terragrunt_linux_$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi) && \
    chmod +x ./terragrunt && \
    sudo mv ./terragrunt /usr/bin/terragrunt

VOLUME /workspaces

ENTRYPOINT ["/bin/sh"]
