🧬 3X-UI Compose
===

This repository contains ready-made images for running [3X-UI](https://github.com/MHSanaei/3x-ui) in isolated containers
(docker/podman).

### What is 3X-UI

**3X-UI** — is a modern and functional web control panel designed for easy configuration and administration of the powerful
Xray core. It allows you to deploy a full-fledged proxy server in a few clicks with support for the most up-to-date and secure
protocols such as VLESS, VMess, Trojan, Shadowsocks, and Hysteria2.

**Main advantages:**

1. Versatility: Support for advanced blocking bypass mechanisms, including Reality, XTLS, and gRPC.
1. Convenience: Intuitive multi-language web interface with detailed traffic consumption statistics for each user.
1. Flexibility: Built-in tools for managing SSL certificates, generating QR codes for client connections, and configuring routing
   rules.
1. Security: Ability to restrict access to the panel by IP, change ports, and configure multi-user access with individual limits.

### ⚠️ Disclaimer

This project and the provided Docker images are intended for educational purposes and personal use only.

1. Responsibility: The author is not responsible for any damage, data loss, or consequences resulting from the use of this
   software. You use it at your own risk.
1. Legality: You are fully personally responsible for complying with the local laws of your country when using this tool.
   The author does not encourage or support actions that violate the law.
1. Security: Despite the use of proven components, always check the configurations before using them in production
   environments.

**Implementation features:**

- ✅ Root & Rootless container launch modes.
- ✅ Using packages from official repositories (3X-UI/XRay Core).
- ✅ Automatic update of 3X-UI, XRay & GeoData.
- ✅ Easy customization of container launch (ENTRYPOINT).
- ✅ Configuration control via environment variables.
- ✅ Built-in `healtcheck` to control the service status.

## 🚀 Quick start

Example commands to start the service via [Docker Run](https://docs.docker.com/engine/containers/run/):

```shell
# Root
$ docker run -d --name 3x-ui -p 2053:2053 crasivo/3x-ui
# Rootless
$ docker run -d --name 3x-ui -p 2053:2053 --user xray crasivo/3x-ui
```

After a successful launch, you can go to the control panel at http://localhost:2053
Login details — `admin:admin`. Fine-tuning for starting the container is described below.

Below is an example of a simple `docker-compose.yml` configuration file for starting the service
via [Docker Compose](https://docs.docker.com/compose/).

```yaml
name: 3x-ui

services:
  3x-ui:
    image: crasivo/3x-ui
    container_name: 3x-ui
    restart: unless-stopped
    environment:
      - "XUI_ADMIN_USERNAME=admin"
      - "XUI_ADMIN_PASSWORD=2UWGn9Ptw6mHmYEPqsvH"
    network_mode: host
    hostname: 3x-ui
```

Example of customizing `healthcheck` with the port `13890` and a secret URL (path) `/secret-path/`:

```yaml
healthcheck:
  test: [ "CMD-SHELL", "curl -sf http://localhost:13890/secret-path/ -o /dev/null || exit 1"]
  retries: 5
  interval: 15s
  timeout: 15s
  start_period: 15s
```

## 🕹️ Usage

### Environment variables

The image supports service configuration via environment variables.

Summary table of available environment variables:

| Env variable              | Example                                 | Default | Additional description                                  |
|:--------------------------|:----------------------------------------|:--------|:--------------------------------------------------------|
| `XUI_ADMIN_USERNAME`      | `admin`                                 | `admin` | Username (administrator) of the Web panel               |
| `XUI_ADMIN_USERNAME_FILE` | `/run/secrets/xui_admin.name`           | —       | Absolute path to the file where the username is stored  |
| `XUI_ADMIN_PASSWORD`      | `2UWGn9Ptw6mHmYEPqsvH`                  | `admin` | Administrator password for the Web panel                |
| `XUI_ADMIN_PASSWORD_FILE` | `/run/secrets/xui_admin.pass`           | —       | Absolute path to the file where the password is stored  |
| `XUI_WEB_BASEPATH`        | `/x-ui/`                                | `/`     | Web path to the control panel                           |
| `XUI_WEB_CERT`            | `/usr/local/x-ui/certs/certificate.pem` | —       | Absolute path to the public SSL certificate             |
| `XUI_WEB_CERT_KEY`        | `/usr/local/x-ui/certs/private_key.pem` | —       | Absolute path to the private key of the SSL certificate |

> [!NOTE]
> A complete list of supported variables can be found in the
> file [xui-bootstrap.sh](docker/images/install/bin/xui-bootstrap.sh).

## 📜 License

This project is distributed under the [MIT](https://en.wikipedia.org/wiki/MIT_License) license.
The full text of the license can be found in the corresponding [file](LICENSE).
