# FROM --platform=$BUILDPLATFORM golang:1.20-alpine AS build
FROM --platform=$BUILDPLATFORM alpine AS build

ARG TARGETOS TARGETARCH
ARG META_VERSION=v1.16.0

ENV CONFIG_PATH=/clash.meta-config/

# ARG META_PATH=/Clash.Meta
# RUN apk add git
# RUN git clone https://github.com/MetaCubeX/Clash.Meta.git $META_PATH
# WORKDIR $META_PATH
# RUN git checkout tags/$META_VERSION
# RUN go mod download
# RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /bin/clash .

ARG META_BINARY=clash.meta-$TARGETOS-$TARGETARCH-$META_VERSION
RUN apk add wget
RUN wget https://github.com/MetaCubeX/Clash.Meta/releases/download/$META_VERSION/$META_BINARY.gz
RUN gunzip -c $META_BINARY.gz > /bin/clash
RUN chmod +x /bin/clash

RUN apk add unzip
RUN mkdir -p $CONFIG_PATH
WORKDIR $CONFIG_PATH
RUN wget https://fastly.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat
RUN wget https://fastly.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat
RUN wget https://fastly.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb
RUN wget https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip && \
    unzip gh-pages.zip && \
    mkdir -p ui/ && \
    mv metacubexd-gh-pages/ ui/xd/

RUN touch /config.yaml
ENTRYPOINT /bin/clash -f /config.yaml -d $CONFIG_PATH
