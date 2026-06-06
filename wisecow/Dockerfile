FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    fortune-mod \
    cowsay \
    netcat-openbsd \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/games:${PATH}"

WORKDIR /app

COPY wisecow.sh .

RUN dos2unix wisecow.sh && chmod +x wisecow.sh

EXPOSE 4499

CMD ["./wisecow.sh"]