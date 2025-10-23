# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      BUILD_ROOT=/go/minio-console \
      BUILD_SRC=huncrys/minio-console.git \
      BUILD_BIN=/console

# :: FOREIGN IMAGES
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:mc AS distroless-mc
  FROM 11notes/distroless:localhealth AS distroless-localhealth

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: UI
  FROM 11notes/go:1.25 AS build
  ARG APP_VERSION \
      APP_VERSION_BUILD \
      BUILD_ROOT \
      BUILD_SRC \
      BUILD_BIN

  RUN set -ex; \
    apk --update --no-cache add \
      nodejs \
      npm;

  RUN set -ex; \
    npm install -g npm; \
    npm install -g corepack; \
    corepack enable;

  RUN set -ex; \
    eleven git clone ${BUILD_SRC} v${APP_VERSION};

  RUN set -ex; \
    cd ${BUILD_ROOT}/web-app; \
    echo "y" | yarn install; \
    yarn build;

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    eleven go build ${BUILD_BIN} ./cmd/console;

  RUN set -ex; \
    eleven distroless ${BUILD_BIN};

# :: ENTRYPOINT
  FROM 11notes/go:1.25 AS entrypoint
  COPY ./build /
  ARG APP_VERSION \
      APP_VERSION_BUILD

  RUN set -ex; \
    cd /go/entrypoint; \
    eleven go build /entrypoint main.go;

  RUN set -ex; \
    eleven distroless /entrypoint;

# :: FILE SYSTEM
  FROM alpine AS file-system
  ARG APP_ROOT \
      APP_UID \
      APP_GID

  RUN set -ex; \
    mkdir -p /distroless${APP_ROOT}/etc; \
    mkdir -p /distroless${APP_ROOT}/ssl/CAs;

# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: app specific environment
    ENV MINIO_CONSOLE_MINIO_USER="admin" \
        MINIO_CONSOLE_USER="console" \
        MINIO_CONSOLE_POLICY="full" \
        MINIO_CONSOLE_POLICY_NAME="consoleAdmin" \
        MC_CONFIG_DIR=${APP_ROOT}/etc \
        MC_JSON="true"

  # :: multi-stage
    COPY --from=distroless / /
    COPY --from=distroless-mc / /
    COPY --from=distroless-localhealth / /
    COPY --from=build /distroless/ /
    COPY --from=entrypoint /distroless/ /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /
    COPY --chown=${APP_UID}:${APP_GID} ./rootfs /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:9090/"]


# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/entrypoint"]