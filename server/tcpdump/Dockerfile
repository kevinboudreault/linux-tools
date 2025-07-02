FROM alpine:latest

RUN apk update
RUN apk add -u --no-cache tcpdump
CMD ["tcpdump", "-i any"]