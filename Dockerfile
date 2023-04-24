FROM golang:alpine3.17 as sygma
ARG OTEL_VERSION=0.75
WORKDIR /app
COPY otelcol-builder.yaml .
RUN go install go.opentelemetry.io/collector/cmd/builder@v${OTEL_VERSION}
RUN builder --config=otelcol-builder.yaml

FROM gcr.io/distroless/base-debian11
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=sygma /app/bin/otelcol-sygma /
COPY otelcol-config.yaml /etc/otelcol-contrib/config.yaml
LABEL org.opencontainers.image.source https://github.com/sygmaprotocol/sygma-opentelemetry-collector
EXPOSE 4317/tcp 4318/tcp 55678/tcp 55679/tcp 8888/tcp
CMD ["--config", "/etc/otelcol-contrib/config.yaml"]
ENTRYPOINT ["/otelcol-sygma"]