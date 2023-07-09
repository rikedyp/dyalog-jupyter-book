FROM dyalog/dyalog:latest

WORKDIR /app

# Switch to root to install necessary dependencies
USER root
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    python3-pip \
    git

# Switch back to original user (replace 'user' with the actual username)
USER user

# Install Jupyter Book
RUN pip3 install jupyter-book

# Clone the Dyalog Jupyter Kernel repository
RUN git clone https://github.com/Dyalog/dyalog-jupyter-kernel.git

# Go into the cloned directory and run the install script
WORKDIR /app/dyalog-jupyter-kernel
RUN chmod +x install.sh && ./install.sh

# Go back to /app directory
WORKDIR /app

COPY . /app

CMD ["bash"]
