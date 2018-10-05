FROM nvidia/cuda:9.0-cudnn7-runtime-ubuntu16.04

# avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set up locales properly
RUN apt-get update && \
    apt-get install --yes --no-install-recommends locales wget bzip2 && \
    apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Use bash as default shell, rather than sh
ENV SHELL /bin/bash

# Set up user
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
       less \
       npm \
       unzip \
       && apt-get purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8888

# Almost all environment variables
ENV APP_BASE /srv
ENV CONDA_DIR ${APP_BASE}/conda
ENV NB_PYTHON_PREFIX ${CONDA_DIR}
ENV KERNEL_PYTHON_PREFIX ${NB_PYTHON_PREFIX}
# Special case PATH
ENV PATH ${CONDA_DIR}/bin:$HOME/.local/bin:${PATH}
# If scripts required during build are present, copy them

COPY conda/install-miniconda.bash /tmp/install-miniconda.bash
COPY conda/environment.py-3.6.frozen.yml /tmp/environment.yml

RUN bash /tmp/install-miniconda.bash 
RUN rm /tmp/install-miniconda.bash /tmp/environment.yml



# Copy and chown stuff. This doubles the size of the repo, because
# you can't actually copy as USER, only as root! Thanks, Docker!
USER root
COPY src/environment.yml ${HOME}
RUN chown -R ${NB_USER}:${NB_USER} ${HOME}

# Run assemble scripts! These will actually build the specification
# in the repository into the image.
USER ${NB_USER}
RUN conda env update -n root -f "environment.yml"
# && \
RUN conda clean -tipsy 
#&& \
RUN conda list -n root

ENV MALMO_XSD_PATH /srv/conda/Schemas

COPY src/ ${HOME}

# Container image Labels!
# Put these at the end, since we don't want to rebuild everything
# when these change! Did I mention I hate Dockerfile cache semantics?


# We always want containers to run as non-root
USER ${NB_USER}

# Make sure that postBuild scripts are marked executable before executing them
# Specify the default command to run
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]