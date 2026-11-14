# Deployment and Branch Setup

## Current deployment block

The inspected DigitalOcean Droplet has 1 GB total RAM and already hosts `breadofgraceministries.org`. Do not install or start the two Battle Pets API/PostgreSQL stacks on that machine at its current size. The preflight requires at least 2 GiB **free** RAM and 10 GiB free disk after existing services are running. Dad must upgrade it or provide another host/database before deployment.

Repository implementation and CI can proceed without a live server. Deployment workflows fail closed when their GitHub environment secrets are absent.

## Branches and GitHub rules

The local branch chain is `main` -> `staging` -> `feature/online-account-foundation`. After review:

1. Push `staging` and set it as the repository default branch so new pull requests target staging.
2. Add rulesets for `staging` and `main`: require pull requests, block force pushes/deletion, require `server-tests`, `admin-build`, and `gamemaker-source-checks`, and require branches to be current.
3. Require `staging-only-promotion` on `main`. This check fails any production PR whose head branch is not `staging`.
4. Create GitHub environments named `staging` and `production` with `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY`, and `DEPLOY_KNOWN_HOSTS` secrets.
5. Keep DigitalOcean/GitHub automatic repository deployment disabled. The deploy workflow runs only after repository CI succeeds.

## Dad-supervised Droplet preflight

Before changing the server, record and review:

```bash
lsb_release -a
free -h
df -h /
sudo ss -lntup
sudo nginx -T
sudo ufw status verbose
```

Back up `/etc/nginx`, the existing website configuration, and its data. Verify the ministry website before and after every Nginx change. Never replace its existing server block.

After the resource requirement passes:

1. Install Docker Engine and the Compose plugin from Docker's official Ubuntu repository.
2. Create `/opt/battlepets`, copy `deploy/compose.yml`, and create root-owned `staging.env` and `production.env` files from `deploy/environment.example` with mode `0600`.
3. Use different long random PostgreSQL passwords and JWT secrets for each environment.
4. Set staging to `REGISTRATION_MODE=invite`; production remains `REGISTRATION_MODE=closed`.
5. Create a restricted `battlepets-deploy` SSH user. Permit passwordless sudo only for `/usr/local/sbin/deploy-battlepets`; do not grant general sudo.
6. Install `deploy/deploy-battlepets` as that root-owned command and configure read-only GHCR authentication on the host.
7. Reserve the DuckDNS names and point them to the Droplet. Add the Nginx server blocks without changing the ministry host, validate with `sudo nginx -t`, then obtain trusted certificates.
8. Run a manual staging deployment and health check before enabling GitHub deployment secrets.

## Mail and invitations

Local development uses Mailpit. Staging uses Mailtrap Sandbox so messages do not reach real recipients. Dad can create a single-use invitation after migrations with:

```bash
docker compose -p battlepets-staging -f /opt/battlepets/compose.yml run --rm api npm run invite:create -- 7
```

The plaintext invitation is displayed once; only its SHA-256 hash is stored. Mailtrap live sending stays disabled until Battle Pets owns and verifies a custom domain.

## Rollback and isolation

Each environment uses its own Compose project, internal network, PostgreSQL volume, credentials, API port, and image tag. PostgreSQL is never published. Nginx reaches only APIs bound to localhost ports 3101 and 3100.

The deployment command stores the last healthy image. If a new health check fails, it restores that image. Database migrations must remain backward compatible because application rollback does not automatically reverse schema migrations.
