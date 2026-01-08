FROM ubuntu:20.04 

# Prevent tzdata interactive prompt
ENV DEBIAN_FRONTEND=noninteractive

# Install Python 3.10 and basic tools
RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    curl \
    gnupg \
    software-properties-common \
    build-essential \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libssl-dev \
    libffi-dev \
    gcc \
    samtools \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3.10-distutils \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 \
    && rm -rf /var/lib/apt/lists/*

# Install htslib from source (includes bgzip)
# RUN apt-get update && apt-get install -y \
#     wget \
#     make \
#     gcc \
#     zlib1g-dev \
#     libbz2-dev \
#     liblzma-dev \
#     libcurl4-openssl-dev \
#     libssl-dev \
#     && cd /opt \
#     && wget https://github.com/samtools/htslib/releases/download/1.17/htslib-1.17.tar.bz2 \
#     && tar -xvjf htslib-1.17.tar.bz2 \
#     && cd htslib-1.17 \
#     && ./configure --prefix=/usr/local \
#     && make \
#     && make install \
#     && cd / \
#     && rm -rf /opt/htslib-1.17 /opt/htslib-1.17.tar.bz2

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && python3 -m pip install --no-cache-dir --upgrade pip

# Add the Cloud SDK distribution URI as a package source
# RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
#     | tee /etc/apt/sources.list.d/google-cloud-sdk.list \
#     && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
#     | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Install gcloud CLI
# RUN apt-get update && apt-get install -y google-cloud-sdk && rm -rf /var/lib/apt/lists/*

# Install pysam + terra-notebook-utils
RUN pip install --no-cache-dir "setuptools<58" \
    && pip install --no-cache-dir pysam terra-notebook-utils==0.15.0 "urllib3<2"


# Default workdir
WORKDIR /app

# Copy the subset_cram.py into the app dir
COPY subset_cram.py /app/
# COPY drs_copy.py /app/

# command

# BUILD with platform:
# docker build --platform linux/amd64 -t catererzt/subset_cram:v1 .

# PUSH:
# docker push catererzt/subset_cram:v1

# TEST:
# docker run --rm -it catererzt/subset_cram:v1 bash
