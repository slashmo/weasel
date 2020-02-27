# Builder 🏗
FROM swift:5.1.3 as builder

WORKDIR /app

COPY Package.swift .
COPY Package.resolved .
RUN swift package resolve

COPY Sources Sources
COPY Tests Tests

RUN mkdir /build
RUN swift build --enable-test-discovery -c release && mv `swift build -c release --show-bin-path` /build/bin

# Release 🚢
FROM swift:5.1.3-slim

WORKDIR /app

COPY --from=builder /build/bin/Run .

EXPOSE 80

ENTRYPOINT [ "./Run" ]
