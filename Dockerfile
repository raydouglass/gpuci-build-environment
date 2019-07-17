ARG CUDA_VERSION=9.2
ARG CUDA_TYPE=devel
ARG LINUX_VERSION=ubuntu16.04
FROM nvidia/cuda:${CUDA_VERSION}-${CUDA_TYPE}-${LINUX_VERSION}

# Define arguments
ARG CONDA_VERSION=4.6.14
ARG TINI_VERSION=v0.18.0
ARG MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh
ARG TINI_URL=https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini

# Set environment
ENV PATH=${PATH}:/conda/bin
ENV DEBIAN_FRONTEND=noninteractive

# Update and add pkgs and install conda
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget --quiet ${MINICONDA_URL} -O /miniconda.sh && \
    /bin/bash /miniconda.sh -b -p /conda && \
    rm -f /miniconda.sh && \
    echo "conda ${CONDA_VERSION}" >> /conda/conda-meta/pinned && \
    /conda/bin/conda clean -tipsy && \
    ln -s /conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    chmod 777 -R /conda && \
    wget --quiet ${TINI_URL} -O /usr/bin/tini && \
    chmod +x /usr/bin/tini 

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
