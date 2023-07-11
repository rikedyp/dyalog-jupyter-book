# Start with the Debian base image
#
# 
FROM debian:bookworm-slim

# Set up some environment variables
ARG DYALOG_RELEASE=18.2
ENV PYDEVD_DISABLE_FILE_VALIDATION=1
ENV PYTHONOPTIMIZE=-Xfrozen_modules=off
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:UTF-8
ENV LC_ALL en_GB.UTF-8

# Install necessary dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    wget \
    python3-venv \
    git \
    libncurses5 \
    locales \
    && apt-get clean && rm -Rf /var/lib/apt/lists/*

# Setup locales
RUN sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

# Download and install Dyalog. NOTE: the jupyter build process fails with 18.2, but works in 19.0
# for currently unknown reasons.
# RUN DEBFILE=`curl -o - -s https://www.dyalog.com/uploads/php/download.dyalog.com/download.php?file=docker.metafile | awk -v v="$DYALOG_RELEASE" '$0~v && /deb/ {print $3}'` && \
#     curl -o /tmp/dyalog.deb ${DEBFILE} && \
#     dpkg -i --ignore-depends=libtinfo5 /tmp/dyalog.deb

RUN curl -o /tmp/dyalog.deb https://packages.dyalog.com/homebrew/dyalog-unicode_19.0.47454_amd64.deb && \
    dpkg -i --ignore-depends=libtinfo5 /tmp/dyalog.deb

# Create a Python virtual environment and install Jupyter Book in it
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install notebook jupyter-book

# Add user
RUN useradd -s /bin/bash -d /home/dyalog -m dyalog

# Define working directory
WORKDIR /home/dyalog

# Download the Dyalog Jupyter Kernel repository as a zip and unpack it, then install
USER root
RUN wget https://github.com/Dyalog/dyalog-jupyter-kernel/archive/master.zip && \
    unzip master.zip && \
    PYVER="$(python3 --version | sed 's/.*\(3\.[0-9]*\).*/\1/')" && \
    KERNELDIR="/opt/venv/share/jupyter/kernels" && \
    SITEDIR="/opt/venv/lib/python$PYVER/site-packages" && \
    mkdir -p "$KERNELDIR" && \
    cp -r dyalog-jupyter-kernel-master/dyalog-kernel "$KERNELDIR"/ && \
    mkdir -p "$SITEDIR" && \
    cp -r dyalog-jupyter-kernel-master/dyalog_kernel "$SITEDIR"/

# Change back to the user 'dyalog'
USER dyalog

# Default command to build the Jupyter Book
# CMD ["/opt/venv/bin/jupyter-book", "build", "--verbose", "1", "/home/dyalog/contents"]
CMD ["/opt/venv/bin/jupyter-book", "build", "-q", "/home/dyalog/contents"]
