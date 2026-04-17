# Setup Instructions

## Prerequisites

```bash
brew install pulumi
brew install gh
brew install awscli
gh auth login
aws configure   # enter Access Key ID, Secret, region: ap-south-1, output: json
```

---

## 1. Clone & Install

```bash
git clone https://github.com/your-user/your-repo.git
cd your-repo
npm install
cd infra && npm install && cd ..
```

---

## 2. Configure Secrets

**App secrets** — variables the app uses at runtime:
```bash
# edit .env with your values
cp .env.local .env

# push to GitHub Secrets
npm run push-secrets
```

**CI secrets** — variables the pipeline uses to deploy:
```bash
# edit .env.ci with your values
# DOCKER_HUB_USER, DOCKER_HUB_PASSWORD, DOCKER_HUB_REPO, CI_COMMIT_REF_NAME
# leave SSH_PRIVATE_KEY and API_SERVER empty for now

npm run push-ci-secrets
```

---

## 3. Provision EC2 (run once)

```bash
cd infra
pulumi stack init dev
pulumi config set aws:region ap-south-1
pulumi up        # creates EC2, key pair, security group, Elastic IP
```

After `pulumi up` finishes:
- Note the `publicIp` output → set as `API_SERVER` in `.env.ci`
- `app-server.pem` is saved in `infra/` automatically

```bash
# push SSH key directly (multiline — cannot go through .env.ci)
gh secret set SSH_PRIVATE_KEY < infra/app-server.pem --repo your-user/your-repo

# push remaining CI secrets
npm run push-ci-secrets
```

---

## 4. One-time EC2 Setup (run once in order)

```bash
npm run workflow:transfer   # upload nginx.conf, docker-compose.yml, scripts to EC2
npm run workflow:setup      # install Docker + Docker Compose on EC2
```

Point your domain DNS A record to the EC2 IP, then:

```bash
npm run workflow:ssl        # generate Let's Encrypt SSL cert
```

---

## 5. Deploy

```bash
npm run workflow:deploy     # manual: build image, deploy to EC2, cleanup
```

Or just push to main — deploy runs automatically:

```bash
git push origin main
```

---

## Day-to-day Commands

| Command | What it does |
|---------|-------------|
| `npm run push-secrets` | Sync `.env` → GitHub Secrets |
| `npm run push-ci-secrets` | Sync `.env.ci` → GitHub Secrets |
| `npm run workflow:deploy` | Manually trigger build + deploy |
| `npm run workflow:transfer` | Re-upload server config files to EC2 |
| `npm run workflow:ssl` | Regenerate SSL cert |
| `npm run workflow:setup` | Re-run Docker install on EC2 |
| `git push origin main` | Auto-triggers full deploy pipeline |

---

## Adding a New Environment Variable

```bash
# 1. add to .env
echo "NEW_VAR=value" >> .env

# 2. push to GitHub Secrets
npm run push-secrets

# 3. add to ci.yml build step
#    echo "NEW_VAR=${{ secrets.NEW_VAR }}" >> .env

# 4. push — pipeline picks it up automatically
git add . && git commit -m "add NEW_VAR" && git push
```

---

## Re-provisioning (replace EC2)

```bash
cd infra
pulumi destroy              # destroys all AWS resources
pulumi up                   # recreates everything fresh

gh secret set SSH_PRIVATE_KEY < infra/app-server.pem --repo your-user/your-repo
# update API_SERVER in .env.ci with new IP
npm run push-ci-secrets

npm run workflow:transfer
npm run workflow:setup
npm run workflow:ssl
git push origin main        # deploys app
```

---

## SSL Renewal

Cert expires every 90 days:

```bash
npm run workflow:ssl
```
