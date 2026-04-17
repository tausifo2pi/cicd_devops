# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# cicd_devops

Minimal Node.js/Express app used as a testbed for CI/CD pipelines, load balancing, and server provisioning automation.

## Commands

```bash
npm install       # install dependencies
node index.js     # run the app (port 5000 by default)
```

There are no tests or linting configured.

## App

- Entry: `index.js` — Express 5 app with two routes: `GET /` and `GET /health`
- Port: `PORT` env var, defaults to `5000`
- Uses `dotenv` for env var loading

## Architecture & Deploy Flow

The deployment stack runs on a single Amazon Linux 2 EC2 instance:

1. **GitHub Actions** (`.github/workflows/ci.yml`) — manually triggered `workflow_dispatch`; each step is an independent job toggled by boolean inputs. `deploy` depends on `build`; `cleanup` depends on `deploy`.
2. **Docker Hub** — built image is tagged via `CI_COMMIT_REF_NAME` secret (e.g. `latest` or `v2`) and pushed to `DOCKER_HUB_USER/DOCKER_HUB_REPO`.
3. **EC2** — `docker-compose.yml` runs two containers: the app (`picqer` service, image `pelyform/picqer:v2`) and nginx. The deploy step SSHs in, runs `docker-compose down && pull && up -d` from `/home/ec2-user/server/`.
4. **nginx** proxies HTTPS → `http://picqer:5000` using Let's Encrypt certs stored at `~/data/certbot/` on the EC2 host. Domain: `anthonys-kicks.coelor.com`.

### One-time EC2 Setup Order

1. `transfer_file` — SCP `server/` configs to EC2
2. `update_ec2` — installs Docker + Docker Compose (runs `update_ec2.sh`)
3. `generate_ssl` — obtains Let's Encrypt cert via certbot Docker container (runs `ssl.sh`)
4. `build` + `deploy` — normal deploy cycle

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `SSH_PRIVATE_KEY` | PEM key to SSH into EC2 |
| `API_SERVER` | EC2 public IP or domain |
| `DOCKER_HUB_USER` | Docker Hub username |
| `DOCKER_HUB_PASSWORD` | Docker Hub password |
| `DOCKER_HUB_REPO` | Docker Hub repo name |
| `CI_COMMIT_REF_NAME` | Docker image tag (e.g. `latest` or `v2`) |

## Goals

- [ ] Auto-trigger deploy on push to main
- [ ] Pulumi-based provisioning (EC2 + security group + Elastic IP + GitHub secrets)
- [ ] Load balancer setup
