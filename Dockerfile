FROM bash:5

RUN apk add --no-cache coreutils sed

WORKDIR /app
COPY . .

ENTRYPOINT ["bash", "main.sh"]
