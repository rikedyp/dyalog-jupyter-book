FROM python:3.11

WORKDIR /app

COPY . /app

RUN pip install jupyter-book

CMD ["bash"]
