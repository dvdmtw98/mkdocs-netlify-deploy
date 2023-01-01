# Base Image used to Build Site
FROM nikolaik/python-nodejs:python3.9-nodejs18-slim

# Install required Dependencies
RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        --no-install-recommends \
        git \
        libcairo2-dev \
        libfreetype6-dev \
        libffi-dev \
        libjpeg-dev \
        libpng-dev \
        libz-dev \
    && :

# Setup Python & Node Packages
ENV PIP_ROOT_USER_ACTION=ignore
RUN python -m pip install --upgrade pip \
    && npm install -g npm netlify-cli

# Copy entrypoint.sh file (Main Logic)
COPY entrypoint.sh /tmp/entrypoint.sh

# Execute the script to start build process
ENTRYPOINT [ "/tmp/entrypoint.sh" ]

# Image URL
# https://hub.docker.com/r/nikolaik/python-nodejs