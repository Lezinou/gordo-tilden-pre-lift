FROM python:3.6-slim-stretch

RUN pip install pyyaml
WORKDIR /code
COPY ./echo_config.py /code/echo_config.py

CMD ["python", "/code/echo_config.py"]
