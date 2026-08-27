FROM debian:stable-slim AS builder
# to use:
# docker build -t ghcr.io/validator/validator .
# docker run -it --rm \
#    -e CONNECTION_TIMEOUT_SECONDS=15 \
#    -e SOCKET_TIMEOUT_SECONDS=15 \
#    -p 8888:8888 \
#    ghcr.io/validator/validator
LABEL name="vnu"
LABEL version="dev"
LABEL maintainer="Michael[tm] Smith <mike@w3.org>"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# Se descarga con curl (sigue redirects de GitHub releases de forma fiable;
# el ADD <url> del builder de Cloud Build guardaba archivos vacíos).
ARG VNU_RELEASE=latest
RUN apt-get update && apt-get install --no-install-recommends -y \
       ca-certificates curl unzip \
    && base="https://github.com/validator/validator/releases/download/${VNU_RELEASE}" \
    && curl -fsSL --retry 5 --retry-all-errors -o vnu.linux.zip      "${base}/vnu.linux.zip" \
    && curl -fsSL --retry 5 --retry-all-errors -o vnu.linux.zip.sha1 "${base}/vnu.linux.zip.sha1" \
    && echo "$(cat vnu.linux.zip.sha1)  vnu.linux.zip" | sha1sum -c - \
    && unzip ./vnu.linux.zip \
    && rm ./vnu.linux.zip* \
    && apt-get purge -y --auto-remove curl unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# hadolint ignore=DL3006
FROM debian:stable-slim
COPY --from=builder /vnu-runtime-image /vnu-runtime-image
ENV LANG C.UTF-8
ENV JAVA_TOOL_OPTIONS ""
ENV CONNECTION_TIMEOUT_SECONDS 5
ENV SOCKET_TIMEOUT_SECONDS 5
ENV BIND_ADDRESS 0.0.0.0
ENV PATH=/vnu-runtime-image/bin:$PATH
# Cloud Run inyecta $PORT (8080). En local sin $PORT se usa 8888.
EXPOSE 8080
CMD ["sh", "-c", "exec /vnu-runtime-image/bin/java -m vnu/nu.validator.servlet.Main ${PORT:-8888}"]
