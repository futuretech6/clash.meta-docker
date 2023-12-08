FROM --platform=$BUILDPLATFORM golang:1.20-alpine AS build
# FROM --platform=$BUILDPLATFORM alpine AS build

ARG TARGETOS TARGETARCH
ARG META_VERSION=v1.17.0

ENV CONFIG_PATH=/clash.meta-config/

ENV META_PATH=/Clash.Meta
RUN apk add git
RUN git clone https://github.com/MetaCubeX/Clash.Meta.git $META_PATH
WORKDIR $META_PATH
RUN git checkout tags/$META_VERSION
RUN go mod download
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 go build -o /bin/clash .
RUN rm -rf $META_PATH

# ENV META_BINARY=mihomo-$TARGETOS-$TARGETARCH-cgo-$META_VERSION.gz
# RUN apk add wget
# RUN wget https://github.com/MetaCubeX/Clash.Meta/releases/download/$META_VERSION/$META_BINARY
# RUN gunzip -c $META_BINARY > /bin/clash
# RUN chmod +x /bin/clash
# RUN rm -f $META_BINARY

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
RUN rm -f gh-pages.zip

# clean up
RUN apk del git unzip
RUN rm -rf /go /root /usr

RUN touch /config.yaml
ENTRYPOINT /bin/clash -f /config.yaml -d $CONFIG_PATH
