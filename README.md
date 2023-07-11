# Dyalog Jupyterbook Template

This repository is a functioning, but largely empty, Jupyterbook set up for Dyalog APL. Fork it to get a headstart if you want to make a Dyalog Jupyterbook. It includes a suitable font, and some CSS bits that should make APL look good.

The book is self-documenting, that is the first bits detail how to install the bits needed and how to build. You can view the rendered book template [here](http://devtweb.dyalog.bramley/stefan/jupyterbook-template).

You content, in the form of jupyter notebooks, go in the `contents/` directory. The structure of the book is defined in the `contents/_toc.yml` file. Some config stuff is defined in the `contents/_config.yml` file. Modify that to suit your needs.

To build using the included Docker image, try:
```
git clone git@github.com:xpqz/jupy.git
cd jupy
docker build -t dyjupy .
docker run -v ./contents:/home/dyalog/contents dyjupy
```
(If you're running this on an Apple Silicon Mac, you may need `--platform linux/amd64` on the `docker` commands above).

The rendered book will end up in `./contents/_build`. If the build succeeded, open `./contents/_build/html/index.html`.

## Building without Docker

You need a running, recent, sound Python installation, the `jupyter` and `jupyter-book` packages. Installing Python in a sustainable way is a bit of an artform. [pyenv](https://github.com/pyenv/pyenv) is a great tool to manage Python versions.

Use `pyenv` to install a recent version of Python, e.g 

    % pyenv install 3.10.4
    
If you intend to do more Python than what's required to author Jupyter notebooks in APL, you need a more sophisticated setup (likely `poetry`), but for now, just use `pyenv`.

In your directory which holds your jupyterbooks, create a new local python environment with `pyenv`:

    % cd path/to/jupyterbooks; pyenv local 3.10.4
    
Now install the jupyter stuff

    % pip install jupyter
    % pip install jupyter-book
    
If you intend to publish your book on GitHub Pages, you also need

    % pip install ghp-import
    
If all that went to plan, you should now be able to build your jupyter-book using the command 

    % jupyter-book build contents
    
If that goes well, you should get a `file://` url pop out, like so

    file:///Users/stefan/work/notebooks/jupyter-book-template/contents/_build/html/index.html
    
Pop that into your browser. 

Commit your changes. If you want to publish on GHP, run something like

    % ghp-import -r github -n -p -f contents/_build/html


    docker build [--platform linux/amd64] -t dyjupy .

If you're running this on an Apple Silicon-based Mac, you may need the bits in the brackets.

To build your book, use

    docker run [--platform linux/amd64] \
        -v {YOUR/PATH}/contents:/home/dyalog/contents \
        dyjupy 

The rendered book will end up in `{YOUR/PATH}/contents/_build`. 
