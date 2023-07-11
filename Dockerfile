# dyjupy -- container with Dyalog, Dyalog's jupyter kernel and the jupyter-book build 
# system.
# 
# Build: docker build [--platform linux/amd64] -t dyjupy .
#
# To render your book, use
#
#   docker run [--platform linux/amd64] \
#       -v {YOUR/PATH}/contents:/home/dyalog/contents \
#       dyjupy 
#
# The rendered book will end up in `{YOUR/PATH}/contents/_build`. 
#
FROM debian:bookworm-slim

ENV PYDEVD_DISABLE_FILE_VALIDATION=1
ENV PYTHONOPTIMIZE=-Xfrozen_modules=off
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:UTF-8
ENV LC_ALL en_GB.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    wget \
    python3-venv \
    git \
    libncurses5 \
    locales \
    && apt-get clean && rm -Rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

# Download and install Dyalog. 
# NOTE: the jupyter build process fails with 18.2, but works in 19.0
# for currently unknown reasons.
RUN curl -o /tmp/dyalog.deb https://packages.dyalog.com/homebrew/dyalog-unicode_19.0.47454_amd64.deb && \
    dpkg -i --ignore-depends=libtinfo5 /tmp/dyalog.deb

RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install notebook jupyter-book

RUN useradd -s /bin/bash -d /home/dyalog -m dyalog

WORKDIR /home/dyalog

# Install the Dyalog Jupyter Kernel
RUN wget https://github.com/Dyalog/dyalog-jupyter-kernel/archive/master.zip && \
    unzip master.zip && \
    PYVER="$(python3 --version | sed 's/.*\(3\.[0-9]*\).*/\1/')" && \
    KERNELDIR="/opt/venv/share/jupyter/kernels" && \
    SITEDIR="/opt/venv/lib/python$PYVER/site-packages" && \
    mkdir -p "$KERNELDIR" && \
    cp -r dyalog-jupyter-kernel-master/dyalog-kernel "$KERNELDIR"/ && \
    mkdir -p "$SITEDIR" && \
    cp -r dyalog-jupyter-kernel-master/dyalog_kernel "$SITEDIR"/

USER dyalog

# Default command to build the Jupyter Book
CMD ["/opt/venv/bin/jupyter-book", "build", "-q", "/home/dyalog/contents"]
