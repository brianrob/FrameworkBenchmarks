FROM golang:1.10.1 AS build

ADD ./ /fasthttp
WORKDIR /fasthttp

RUN mkdir bin
ENV GOPATH /fasthttp
ENV PATH ${GOPATH}/bin:${PATH}

RUN rm -rf ./pkg/*
RUN go get -d -u github.com/go-sql-driver/mysql
RUN go get -d -u github.com/valyala/fasthttp/...
RUN go get -u github.com/valyala/quicktemplate/qtc
RUN go get -u github.com/mailru/easyjson/...

RUN rm -f ./server-mysql
RUN go generate templates
RUN go build -gcflags='-l=4' server-mysql

FROM debian:stretch AS runtime

COPY --from=0 /fasthttp/server-mysql /

CMD /server-mysql
