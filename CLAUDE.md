# cicd_devops

Minimal Node.js/Express app used as a testbed for CI/CD pipelines, load balancing, and server provisioning automation.

## App

- Entry: `index.js`
- Port: `PORT` env var, defaults to `5000`
- Endpoints:
  - `GET /` — Hello World
  - `GET /health` — health check

## Running locally

```bash
npm install
node index.js
```

## Server & Deployment

All server/infra files live in `server/`:

- `docker-compose.yml` — runs the app + nginx containers on EC2
- `nginx.conf` — reverse proxy HTTPS → app on port 5000
- `update_ec2.sh` — installs Docker + Docker Compose on a fresh Amazon Linux 2 EC2
- `ssl.sh` — generates Let's Encrypt SSL cert via certbot
- `renew_ssl.sh` — renews SSL cert
- `info.txt` — EC2 server IP

`Dockerfile` — builds the app image (node:22-alpine, port 5000).

## GitHub Actions (`.github/workflows/ci.yml`)

Manual `workflow_dispatch` with toggles:

| Step | Default | What it does |
|------|---------|--------------|
| `build` | on | Builds Docker image, pushes to Docker Hub |
| `deploy` | on | SSHs into EC2, pulls new image, restarts containers |
| `cleanup` | on | Prunes unused Docker images on EC2 |
| `transfer_file` | off | SCPs server config files to EC2 |
| `update_ec2` | off | Runs `update_ec2.sh` on EC2 (one-time setup) |
| `generate_ssl` | off | Runs `ssl.sh` on EC2 (one-time SSL setup) |

## Required GitHub Secrets

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
