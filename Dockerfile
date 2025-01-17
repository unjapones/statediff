FROM node:14-alpine AS js
WORKDIR /usr/src/app
COPY ./npm/app .
RUN npm install

FROM golang:alpine AS builder
WORKDIR /go/src/app/

COPY . .
COPY --from=js /usr/src/app ./npm/app
# Fetch dependencies.
RUN go get -d -v ./...
RUN go generate ./...
RUN go build -o stateexplorer ./cmd/stateexplorer

FROM alpine
# Copy our static executable.
COPY --from=builder /go/src/app/stateexplorer /stateexplorer
ENTRYPOINT ["/stateexplorer"]
