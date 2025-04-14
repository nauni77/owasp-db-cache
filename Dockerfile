#FROM oraclelinux:9-slim AS supercronic
FROM --platform=linux/amd64 alpine:latest AS supercronic-amd64

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.33/supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=71b0d58cc53f6bd72cf2f293e09e294b79c666d8 \
    SUPERCRONIC=supercronic-linux-amd64

RUN set -ex  \
    && apk add curl \
    && curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic


FROM --platform=linux/arm64 alpine:latest AS supercronic-arm64

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.33/supercronic-linux-arm64 \
    SUPERCRONIC=supercronic-linux-arm64 \
    SUPERCRONIC_SHA1SUM=e0f0c06ebc5627e43b25475711e694450489ab00

RUN set -ex  \
    && apk add curl \
    && curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

### at the COPY --from you can't use global ARGs. Because of this it needs to be wrapped here!!!
FROM supercronic-${TARGETARCH} AS supercronic


FROM mysql:8.4.4

LABEL maintainer="Stefan Neuhaus <stefan@stefanneuhaus.org>"

# these ENV variables will used by MYSQL for startup
ENV MYSQL_DATABASE=dependencycheck \
    MYSQL_RANDOM_ROOT_PASSWORD=true \
    MYSQL_ONETIME_PASSWORD=true \
    MYSQL_USER=dc \
    MYSQL_PASSWORD=dc

WORKDIR /dependencycheck

RUN set -ex && \
    microdnf install java-21-openjdk-headless procps; \
    microdnf clean all

COPY overlays/wrapper.sh /
COPY overlays/dependencycheck /dependencycheck/
COPY overlays/docker-entrypoint-initdb.d /docker-entrypoint-initdb.d/

RUN set -ex && \
    /dependencycheck/gradlew wrapper; \
    chown --recursive mysql:mysql /dependencycheck

COPY --from=supercronic /usr/local/bin/supercronic /usr/local/bin/

VOLUME /var/lib/mysql
VOLUME /var/lib/owasp-db-cache

EXPOSE 3306

CMD ["/wrapper.sh"]
