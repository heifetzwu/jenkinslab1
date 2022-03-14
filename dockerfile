FROM golang:1.17.8-alpine3.15 as debug

# installing git
RUN apk update && apk upgrade && \
    apk add --no-cache git \
        dpkg \
        gcc \
        git \
        musl-dev

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN go get github.com/sirupsen/logrus
RUN go get github.com/buaazp/fasthttprouter
RUN go get github.com/valyala/fasthttp
RUN go install github.com/go-delve/delve/cmd/dlv@latest

WORKDIR /go/src/work
COPY ./src /go/src/work/

RUN go mod init
RUN go mod tidy
RUN go build -o app
### Run the Delve debugger ###
COPY ./dlv.sh /
RUN chmod +x /dlv.sh 
ENTRYPOINT [ "/dlv.sh"]

###########START NEW IMAGE###################

FROM alpine:3.9 as prod
COPY --from=debug /go/src/work/app /
CMD ./app
