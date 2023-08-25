#
# Copyright 2021 OpsMx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Install the latest versions of our mods.  This is done as a separate step
# so it will pull from an image cache if possible, unless there are changes.
#

FROM --platform=${BUILDPLATFORM} golang:1.19-alpine AS buildmod
RUN mkdir /build
WORKDIR /build
COPY go.mod .
COPY go.sum .
RUN go mod download

#
# Compile the code.
#
FROM buildmod AS build-binaries
COPY . .
ARG GIT_BRANCH
ARG GIT_HASH
ARG BUILD_TYPE
ARG TARGETOS
ARG TARGETARCH
ENV GIT_BRANCH=${GIT_BRANCH} GIT_HASH=${GIT_HASH} BUILD_TYPE=${BUILD_TYPE}
ENV CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH}
RUN mkdir /out
RUN go build -o /out/opa-gate-poc -ldflags="-X 'github.com/OpsMx/go-app-base/version.buildType=${BUILD_TYPE}' -X 'github.com/OpsMx/go-app-base/version.gitHash=${GIT_HASH}' -X 'github.com/OpsMx/go-app-base/version.gitBranch=${GIT_BRANCH}'" .

#
# Establish a base OS image used by all the applications.
#
FROM alpine:3 AS base-image
WORKDIR /app
RUN apk update && apk upgrade && apk add curl jq && rm -rf /var/cache/apk/*
RUN mkdir /local /local/ca-certificates && rm -rf /usr/local/share/ca-certificates && ln -s  /local/ca-certificates /usr/local/share/ca-certificates
COPY docker/run.sh /app/run.sh
COPY example/* /app/
ENTRYPOINT ["/bin/sh", "/app/run.sh"]

#
# Build the opa-gate-poc image.  This should be a --target on docker build.
#
FROM base-image AS opa-gate-poc-image
RUN apk add --no-cache git
WORKDIR /app
COPY --from=build-binaries /out/opa-gate-poc /app
EXPOSE 8500
CMD ["/app/opa-gate-poc"]