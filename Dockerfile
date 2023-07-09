FROM dyalog/dyalog:latest

WORKDIR /app

# Switch to root to install necessary dependencies
USER root
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    python3-pip

# Switch back to original user
USER dyalog

# Install Jupyter Book
RUN pip3 install jupyter-book

# Download and extract the Dyalog Jupyter Kernel
RUN wget https://github.com/Dyalog/dyalog-jupyter-kernel/archive/master.zip && \
    unzip master.zip && \
    rm master.zip

# Go into the extracted directory and run the install script
WORKDIR /app/dyalog-jupyter-kernel-master
RUN chmod +x install.sh && ./install.sh

# Go back to /app directory
WORKDIR /app

COPY . /app

CMD ["bash"]
