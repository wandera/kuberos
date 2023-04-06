FROM node:9.8-alpine as node
ADD frontend/ .
RUN npm install && npm run build

FROM golang:1.20.3-alpine3.17 as golang
RUN apk --no-cache add git
WORKDIR /go/src/github.com/wandera/kuberos/
ENV CGO_ENABLED=0

ADD . .
COPY --from=node dist/ dist/frontend
COPY --from=node index.html dist/frontend/

RUN go get -u github.com/Masterminds/glide && \
  go get -u github.com/rakyll/statik && \
  glide install

RUN cd statik && go generate && cd ..
RUN go build -o /kuberos ./cmd/kuberos

FROM alpine:3.7

RUN apk --no-cache add ca-certificates
COPY --from=golang /kuberos /
