FROM dyalog/dyalog:latest

WORKDIR /home/dyalog

# Switch to root to install necessary dependencies
USER root
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    python3-pip \
    git

# Install Jupyter notebook and Jupyter Book
RUN pip3 install notebook jupyter-book

# No "mapl" script in base install, which jupyter
# kernel expects. Create symbolic link to fake it.
RUN ln -s /opt/mdyalog/18.2/64/unicode/dyalog /opt/mdyalog/18.2/64/unicode/mapl

# Switch back to original user
USER dyalog

# Clone the Dyalog Jupyter Kernel repository
RUN git clone https://github.com/Dyalog/dyalog-jupyter-kernel.git

# Go into the cloned directory and run the install script
WORKDIR /home/dyalog/dyalog-jupyter-kernel
RUN chmod +x install.sh && ./install.sh

COPY . /home/dyalog

# Change owner to dyalog
USER root
RUN chown -R dyalog:dyalog /home/dyalog

USER dyalog
CMD ["bash"]
