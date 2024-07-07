FROM python:3.10.14-slim-bullseye

WORKDIR /app

ARG UID=1000
ARG GID=1000

RUN apt-get update \
  && groupadd -g "${GID}" python \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" python \
  && chown python:python -R /app

USER python

COPY --chown=python:python requirements.txt ./

RUN pip3 install --no-cache-dir --user -r requirements.txt

ARG FLASK_DEBUG="false"
ENV FLASK_DEBUG="${FLASK_DEBUG}" \
  PYTHONUNBUFFERED="true" \
  PYTHONPATH="." \
  PATH="${PATH}:/home/python/.local/bin" \
  USER="python"

COPY --chown=python:python app .

EXPOSE 8000

CMD ["gunicorn", "--workers", "1", "--bind", "0.0.0.0:8000", "app:app"]