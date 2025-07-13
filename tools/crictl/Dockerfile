FROM alpine:latest

ARG VERSION="v1.33.0"

RUN apk add --no-cache ca-certificates curl bash socat iproute2
RUN curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/${VERSION}/crictl-${VERSION}-linux-amd64.tar.gz -o /tmp/crictl.tar.gz \
    && tar -zxvf /tmp/crictl.tar.gz -C /usr/local/bin \
    && chmod +x /usr/local/bin/crictl \
    && rm -f /tmp/crictl.tar.gz

COPY crictl.yml /etc/crictl.yml