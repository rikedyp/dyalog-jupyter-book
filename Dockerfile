FROM debian:bookworm-slim as installer

ARG DYALOG_RELEASE=19.0
ARG BUILDTYPE=minimal

RUN apt-get update && apt-get install -y curl && \
    apt-get clean && rm -Rf /var/lib/apt/lists/*

RUN DEBFILE=`curl -o - -s https://www.dyalog.com/uploads/php/download.dyalog.com/download.php?file=docker.metafile | awk -v v="$DYALOG_RELEASE" '$0~v && /deb/ {print $3}'` && \
    curl -o /tmp/dyalog.deb ${DEBFILE}

ADD rmfiles.sh /

RUN dpkg -i --ignore-depends=libtinfo5 /tmp/dyalog.deb && /rmfiles.sh

FROM debian:bookworm-slim

ARG DYALOG_RELEASE=19.0

# Install system dependencies including Python and requirements for PDF generation
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    libncurses5 \
    python3-full \
    python3-pip \
    python3-venv \
    git \
    gcc \
    python3-dev \
    pandoc \
    texlive-latex-extra \
    && apt-get clean && rm -Rf /var/lib/apt/lists/* \
    && sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:UTF-8
ENV LC_ALL en_GB.UTF-8

# Copy Dyalog from installer stage
COPY --from=installer /opt /opt

# Create mapl symlink
RUN ln -s /opt/mdyalog/${DYALOG_RELEASE}/64/unicode/dyalog /opt/mdyalog/${DYALOG_RELEASE}/64/unicode/mapl

# Set up Dyalog
RUN P=$(echo ${DYALOG_RELEASE} | sed 's/\.//g') && update-alternatives --install /usr/bin/dyalog dyalog /opt/mdyalog/${DYALOG_RELEASE}/64/unicode/dyalog ${P}
RUN P=$(echo ${DYALOG_RELEASE} | sed 's/\.//g') && update-alternatives --install /usr/bin/dyalogscript dyalogscript /opt/mdyalog/${DYALOG_RELEASE}/64/unicode/scriptbin/dyalogscript ${P}
RUN cp /opt/mdyalog/${DYALOG_RELEASE}/64/unicode/LICENSE /LICENSE

# Create and set up dyalog user
RUN useradd -s /bin/bash -d /home/dyalog -m dyalog
RUN mkdir -p /app /storage /workspace /home/dyalog/contents /home/dyalog/book && \
    chmod 777 /app /storage /workspace /home/dyalog/contents /home/dyalog/book

# Set Dyalog environment variables
ENV DYALOG=/opt/mdyalog/${DYALOG_RELEASE}/64/unicode
ENV DYALOG_PYTHONHOME=/home/dyalog/venv
ENV PATH="${DYALOG}:${PATH}"
ENV MAXWS=1G

# Switch to dyalog user and set up Python environment
USER dyalog
WORKDIR /home/dyalog

# Create and activate virtual environment
RUN python3 -m venv /home/dyalog/venv
ENV PATH="/home/dyalog/venv/bin:$PATH"
ENV VIRTUAL_ENV="/home/dyalog/venv"
ENV JUPYTER_PATH="/home/dyalog/.local/share/jupyter"
ENV JUPYTER_CONFIG_DIR="/home/dyalog/.jupyter"
ENV JUPYTER_RUNTIME_DIR="/home/dyalog/.local/share/jupyter/runtime"
ENV JUPYTER_DATA_DIR="/home/dyalog/.local/share/jupyter"

# Create necessary directories
RUN mkdir -p \
    /home/dyalog/.local/share/jupyter/kernels \
    /home/dyalog/.local/share/jupyter/runtime \
    /home/dyalog/.jupyter

# Install Jupyter, Jupyter Book, and the Dyalog kernel
RUN pip3 install --no-cache-dir \
    jupyter \
    notebook \
    'dyalog-jupyter-kernel==2.0.1' \
    jupyter-book \
    ghp-import \
    sphinx-book-theme \
    sphinx-copybutton \
    sphinx-togglebutton \
    sphinx-comments \
    myst-nb

# Configure Jupyter for minimal logging and no authentication
RUN jupyter notebook --generate-config && \
    echo "c.NotebookApp.token = ''" >> /home/dyalog/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.password = ''" >> /home/dyalog/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.log_level = 'WARN'" >> /home/dyalog/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.terminals_enabled = True" >> /home/dyalog/.jupyter/jupyter_notebook_config.py

# Configure the kernel
RUN python -m dyalog_kernel install --user --prefix=/home/dyalog/.local && \
    chmod -R 755 /home/dyalog/.local/share/jupyter

# Copy entrypoint script
COPY --chown=dyalog:dyalog entrypoint.sh /home/dyalog/entrypoint.sh
RUN chmod +x /home/dyalog/entrypoint.sh

# Set up work environment
WORKDIR /workspace
VOLUME ["/storage", "/app", "/workspace", "/home/dyalog/contents", "/home/dyalog/book"]

# Expose Jupyter and RIDE ports
EXPOSE 4502 8888

ENTRYPOINT ["/home/dyalog/entrypoint.sh"]