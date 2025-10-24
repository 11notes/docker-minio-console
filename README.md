![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# MINIO-CONSOLE
![size](https://img.shields.io/docker/image-size/11notes/minio-console/1.8.1?color=0eb305)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![pulls](https://img.shields.io/docker/pulls/11notes/minio-console?color=2b75d6)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)[<img src="https://img.shields.io/github/issues/11notes/docker-minio-console?color=7842f5">](https://github.com/11notes/docker-minio-console/issues)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

Run minio-console rootless and distroless.

# INTRODUCTION 📢

[MinIO Console](https://github.com/huncrys/minio-console) (created by [huncrys](https://github.com/huncrys/)) is a library that provides a management and browser UI overlay for the MinIO Server.

# SYNOPSIS 📖
**What can I do with this?** This image will run minio-console [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md), for maximum security and performance. In addition to being small and secure, it will also automatically create the required user with the required privileges to access minio for you.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| 11notes/minio-console:1.8.1 | 53MB | 1000:1000 | ✅ | amd64, arm64 |
| huncrys/minio-console | 97MB | 0:0 | ❌ | amd64, arm64, ppc64le |

# VOLUMES 📁
* **/minio-console/etc** - Directory of policies and config for [mc]
* **/minio-console/ssl** - Directory of SSL certificates used

# COMPOSE ✂️
Checkout [compose.secrets.yml](https://github.com/11notes/docker-minio-console/blob/master/compose.secrets.yml) if you want to use secrets instead of environment variables.
```yaml
name: "s3"

x-lockdown: &lockdown
  # prevents write access to the image itself
  read_only: true
  # prevents any process within the container to gain more privileges
  security_opt:
    - "no-new-privileges=true"

services:
  minio:
    # for more information about this image checkout:
    # https://github.com/11notes/docker-minio
    image: "11notes/minio:2025.10.15"
    hostname: "minio"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
      MINIO_ROOT_PASSWORD: "${MINIO_ROOT_PASSWORD}"
    command: "/mnt"
    volumes:
      - "minio.var:/mnt"
    networks:
      backend:
    restart: "always"

  minio-console:
    depends_on:
      minio:
        condition: "service_healthy"
        restart: true
    image: "11notes/minio-console:1.8.1"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
      MINIO_CONSOLE_MINIO_URL: "https://minio:9000"
      MINIO_CONSOLE_MINIO_PASSWORD: "${MINIO_ROOT_PASSWORD}"
      MINIO_CONSOLE_PASSWORD: "${MINIO_CONSOLE_PASSWORD}"
      # only for testing, use a valid SSL certificate in production
      MC_INSECURE: true
    ports:
      - "3000:9090/tcp"
    volumes:
      - "minio-console.etc:/minio-console/etc"
      - "minio-console.ssl:/minio-console/ssl"
    networks:
      frontend:
      backend:
    restart: "always"

volumes:
  minio.var:
  minio-console.etc:
  minio-console.ssl:

networks:
  frontend:
  backend:
    internal: true
```
To find out how you can change the default UID/GID of this container image, consult the [RTFM](https://github.com/11notes/RTFM/blob/main/linux/container/image/11notes/how-to.changeUIDGID.md#change-uidgid-the-correct-way).

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /minio-console | home directory of user docker |
| `--certs-dir` | /minio-console/ssl | where to store SSL certificates (if used) |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |
| `MINIO_CONSOLE_MINIO_USER` | username of admin user on minio | admin |
| `MINIO_CONSOLE_USER` | username of console user | console |
| `MINIO_CONSOLE_POLICY` | access policy to use (check /minio-console/etc for available policies) | full |
| `MINIO_CONSOLE_POLICY_NAME` | name of policy on minio | consoleAdmin |
# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [1.8.1](https://hub.docker.com/r/11notes/minio-console/tags?name=1.8.1)

### There is no latest tag, what am I supposed to do about updates?
It is of my opinion that the ```:latest``` tag is dangerous. Many times, I’ve introduced **breaking** changes to my images. This would have messed up everything for some people. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:1.8.1``` you can use ```:1``` or ```:1.8```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/minio-console:1.8.1
docker pull ghcr.io/11notes/minio-console:1.8.1
docker pull quay.io/11notes/minio-console:1.8.1
```

# SOURCE 💾
* [11notes/minio-console](https://github.com/11notes/docker-minio-console)

# PARENT IMAGE 🏛️
> [!IMPORTANT]
>This image is not based on another image but uses [scratch](https://hub.docker.com/_/scratch) as the starting layer.
>The image consists of the following distroless layers that were added:
>* [11notes/distroless](https://github.com/11notes/docker-distroless/blob/master/arch.dockerfile) - contains users, timezones and Root CA certificates, nothing else
>* [11notes/distroless:localhealth](https://github.com/11notes/docker-distroless/blob/master/localhealth.dockerfile) - app to execute HTTP requests only on 127.0.0.1
>* [11notes/distroless:mc](https://github.com/11notes/docker-distroless/blob/master/mc.dockerfile) - app to manage minio

# BUILT WITH 🧰
* [huncrys/minio-console](https://github.com/huncrys/minio-console)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# CAUTION ⚠️
> [!CAUTION]
>* The compose example uses ```MC_INSECURE```. Never do this in production! Use a valid SSL certificate to terminate your minio!

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-minio-console/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-minio-console/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-minio-console/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 24.10.2025, 11:36:39 (CET)*