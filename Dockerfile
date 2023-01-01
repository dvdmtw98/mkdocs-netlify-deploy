# Base Image used to Build Site
FROM nikolaik/python-nodejs:python3.9-nodejs18-slim

# Install required Dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get install -y git

# Setup Python & Node Packages
ENV PIP_ROOT_USER_ACTION=ignore
RUN python -m pip install --upgrade pip \
    && npm install -g npm@latest \
    && npm install netlify-cli -g

# Copy entrypoint.sh file (Main Logic)
COPY entrypoint.sh /tmp/entrypoint.sh

# Execute the script to start build process
ENTRYPOINT [ "/tmp/entrypoint.sh" ]

# Image URL
# https://hub.docker.com/r/nikolaik/python-nodejs