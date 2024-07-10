FROM nvidia/cuda:12.0.0-base-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

# Create your user in the container
ARG LDAP_USERNAME
ARG LDAP_UID
ARG LDAP_GROUPNAME
ARG LDAP_GID
RUN groupadd ${LDAP_GROUPNAME} --gid ${LDAP_GID} && useradd -m -s /bin/bash -g ${LDAP_GROUPNAME} -u ${LDAP_UID} ${LDAP_USERNAME}

# Install required packages
RUN apt-get update && apt-get install -y \
  git \
  python3-pip \
  python3-dev \
  python3-opencv \
  libglib2.0-0 \
  curl \
  htop \
  vim \
  nvtop

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Copy your code in the container
RUN mkdir -p /home/${LDAP_USERNAME} && mkdir -p /home/${LDAP_USERNAME}/.ssh && mkdir -p /home/${LDAP_USERNAME}/code

COPY /poetry_installation/pyproject.toml /home/${LDAP_USERNAME}/code
COPY /known_hosts /home/${LDAP_USERNAME}/.ssh/known_hosts

# Set your user as owner of the new copied files
RUN chown -R ${LDAP_USERNAME}:${LDAP_GROUPNAME} /home/${LDAP_USERNAME}

# Set the working directory in your user's home
WORKDIR /home/${LDAP_USERNAME}
USER ${LDAP_USERNAME}

ENV PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  POETRY_NO_INTERACTION=1 \
  POETRY_VIRTUALENVS_CREATE=true \
  POETRY_VIRTUALENVS_IN_PROJECT=true \
  POETRY_HOME="/home/${LDAP_USERNAME}/.poetry" \
  PATH="$PATH:/home/${LDAP_USERNAME}/.poetry/bin" \
  MLFLOW_DIR="/home/${LDAP_USERNAME}/nas/wyss/mlflow" \
  MLFLOW_TRACKING_URI="/home/${LDAP_USERNAME}/nas/wyss/mlflow" \
  DATA_DIR="/home/${LDAP_USERNAME}/nas/wyss/data" \
  OUTPUT_DIR="/home/${LDAP_USERNAME}/nas/wyss/output"

# install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# install dependencies
WORKDIR /home/${LDAP_USERNAME}/code
RUN poetry install --no-root

# create directories
WORKDIR /home/${LDAP_USERNAME}
RUN mkdir -p mlflow
RUN mkdir -p output

COPY --chown=${LDAP_USERNAME}:${LDAP_GROUPNAME} /pull_repo.sh /home/${LDAP_USERNAME}/pull_repo.sh
COPY --chown=${LDAP_USERNAME}:${LDAP_GROUPNAME} /run_script.sh /home/${LDAP_USERNAME}/run_script.sh
COPY --chown=${LDAP_USERNAME}:${LDAP_GROUPNAME} /run_jupyter.sh /home/${LDAP_USERNAME}/run_jupyter.sh
RUN chmod +x /home/${LDAP_USERNAME}/pull_repo.sh && chmod +x /home/${LDAP_USERNAME}/run_script.sh && chmod +x /home/${LDAP_USERNAME}/run_jupyter.sh
