FROM python:3.10-alpine

RUN adduser -D -H 1000

RUN mkdir /app
WORKDIR /app

RUN apk add --update --no-cache \
    linux-headers \
    libstdc++ \
    postgresql-client \
    && apk add --virtual .build-deps gcc g++ musl-dev

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

RUN apk --purge del .build-deps gcc g++ musl-dev

COPY api api

RUN chown -R 1000 /app

USER 1000

EXPOSE 8000

CMD [ "uvicorn", "api.main:app", "--reload", "--port", "8000", "--host", "0.0.0.0" ]
