# cavewomen.coelor.com — Setup Steps

## 1. Provision EC2

```bash
cd infra
pulumi stack init cavewomen
pulumi config set aws:region ap-south-1
pulumi config set appName cavewomen
pulumi up
```

Note the `publicIp` output.

## 2. Point DNS

Set `cavewomen.coelor.com` A record → EC2 IP from pulumi output.

## 3. Fill .env.ci

```
API_SERVER=<pulumi publicIp>
DOCKER_HUB_PASSWORD=<your password>
SSH_PRIVATE_KEY=<see infra/cavewomen.pem>
```

## 4. Push Secrets

```bash
# from repo root
npm run push-secrets                                          # app vars
bash infra/push-secrets.sh projects/cavewomen/.env.ci        # CI vars
gh secret set SSH_PRIVATE_KEY < infra/cavewomen.pem --repo tausifo2pi/cicd_devops
```

## 5. Transfer Server Files

```bash
# SSH into EC2 manually and run:
scp -i infra/cavewomen.pem -r projects/cavewomen/server ec2-user@<IP>:/home/ec2-user/
```

## 6. Setup EC2

```bash
ssh -i infra/cavewomen.pem ec2-user@<IP>
bash /home/ec2-user/server/update_ec2.sh
bash /home/ec2-user/server/ssl.sh
```

## 7. Deploy

```bash
git push origin main
```
