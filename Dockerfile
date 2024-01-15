# FROM --platform=$BUILDPLATFORM golang:1.20-alpine AS build
FROM --platform=$BUILDPLATFORM alpine AS build

ARG TARGETOS TARGETARCH
ARG META_VERSION=v1.18.0
ARG META_REPO=https://github.com/MetaCubeX/mihomo

ENV CONFIG_PATH=/clash.meta-config/

# ENV META_PATH=/Clash.Meta
# RUN apk add git
# RUN git clone $META_REPO $META_PATH
# WORKDIR $META_PATH
# RUN git checkout tags/$META_VERSION
# RUN go mod download
# RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /bin/clash .

# ENV META_BINARY=mihomo-$TARGETOS-$TARGETARCH-$META_VERSION.gz
RUN apk add wget
RUN if [ "$TARGETARCH" == "amd64" ]; then \
        export META_BINARY="mihomo-$TARGETOS-$TARGETARCH-compatible-$META_VERSION.gz" ; \
    else \
        export META_BINARY="mihomo-$TARGETOS-$TARGETARCH-$META_VERSION.gz" ; \
    fi ; \
    wget $META_REPO/releases/download/$META_VERSION/$META_BINARY ; \
    gunzip -c $META_BINARY > /bin/clash ; \
    chmod +x /bin/clash ; \
    rm -f $META_BINARY

# add geox and ui
RUN apk add unzip
RUN mkdir -p $CONFIG_PATH
WORKDIR $CONFIG_PATH
RUN wget https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat
RUN wget https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat
RUN wget https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb
RUN wget https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip && \
    unzip gh-pages.zip && \
    mkdir -p ui/ && \
    mv metacubexd-gh-pages/ ui/xd/
RUN rm -f gh-pages.zip

# clean up
RUN apk del wget unzip

RUN touch /config.yaml
ENTRYPOINT /bin/clash -f /config.yaml -d $CONFIG_PATH
