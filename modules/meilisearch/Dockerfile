FROM alpine:3.12

WORKDIR /modules/meilisearch

RUN apk add --no-cache ca-certificates wget unzip

RUN --mount=type=tmpfs,target=/tmp \
    wget -O /tmp/meilisearch.zip https://github.com/mbround18/wikijs-module-meilisearch/releases/download/v0.0.1/meilisearch.zip \
    && unzip /tmp/meilisearch.zip -d /modules/meilisearch
