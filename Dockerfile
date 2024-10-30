FROM golang:1.22.8-alpine3.20 AS sygma
ARG OTEL_VERSION=0.109.0
WORKDIR /app
COPY otelcol-builder.yaml .
RUN <<-EOF
apk update && apk add git
go install go.opentelemetry.io/collector/cmd/builder@v${OTEL_VERSION}
builder --config=otelcol-builder.yaml
EOF

FROM gcr.io/distroless/base-debian11
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=sygma /app/bin/otelcol-sygma /
COPY otelcol-config.yaml /etc/otelcol-contrib/config.yaml
LABEL org.opencontainers.image.source=https://github.com/sygmaprotocol/sygma-opentelemetry-collector
LABEL org.opencontainers.image.description="Sygma Opentelemetry Collector Agent"

CMD ["--config", "/etc/otelcol-contrib/config.yaml", "--feature-gates=-component.UseLocalHostAsDefaultHost"]
ENTRYPOINT ["/otelcol-sygma"]