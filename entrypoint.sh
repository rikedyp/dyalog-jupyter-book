#!/bin/bash

# If contents directory exists and contains files, build the book
if [ -d "/home/dyalog/contents" ] && [ "$(ls -A /home/dyalog/contents)" ]; then
    echo "Building Jupyter Book..."
    jupyter-book build /home/dyalog/contents
else
    # Otherwise start Jupyter notebook server
    echo "Starting Jupyter notebook server..."
    jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.log_level='WARN'
fi