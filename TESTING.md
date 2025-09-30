# Local Testing Guide

This guide explains how to test the Bonfire Docker implementation locally without needing a full YunoHost server.

## Prerequisites

- Docker installed ([Install Docker](https://docs.docker.com/get-docker/))
- Docker Compose (included in Docker Desktop, or install separately)
- At least 3GB free disk space
- At least 2GB free RAM

## Quick Start

### 1. Run the test script

```bash
cd /Users/ivan/Sites/bonfire_ynh
./test-local.sh
```

This will:
- Create test data directories
- Start PostgreSQL, Meilisearch, and Bonfire containers
- Wait for all services to be ready
- Display access URLs and useful commands

### 2. Access Bonfire

Open your browser to: **http://localhost:4000**

**Important:** The first user to sign up will automatically become the administrator.

### 3. Test the application

- Sign up for an account (becomes admin)
- Create a post
- Upload an image
- Try the search functionality
- Check settings and admin panel

## Manual Testing (without script)

If you prefer to run commands manually:

```bash
# Start services
docker compose -f docker-compose.local-test.yml up -d

# View logs
docker compose -f docker-compose.local-test.yml logs -f

# Stop services
docker compose -f docker-compose.local-test.yml down

# Stop and remove all data
docker compose -f docker-compose.local-test.yml down -v
```

## Architecture Notes

### For ARM64/Apple Silicon

If you're on Apple Silicon (M1/M2/M3), you need to edit `docker-compose.local-test.yml`:

Change line 29:
```yaml
# FROM:
image: bonfirenetworks/bonfire:latest-social-amd64

# TO:
image: bonfirenetworks/bonfire:latest-social-aarch64
```

Or use multi-arch (if available):
```yaml
image: bonfirenetworks/bonfire:latest-social
```

## Ports Used

- **4000** - Bonfire web interface
- **5432** - PostgreSQL database
- **7700** - Meilisearch (optional dashboard)

## Useful Commands

### View logs
```bash
docker compose -f docker-compose.local-test.yml logs -f app
docker compose -f docker-compose.local-test.yml logs -f search
docker compose -f docker-compose.local-test.yml logs -f db
```

### Check service status
```bash
docker compose -f docker-compose.local-test.yml ps
```

### Access database
```bash
docker compose -f docker-compose.local-test.yml exec db psql -U bonfire
```

### Access Bonfire shell (Elixir console)
```bash
docker compose -f docker-compose.local-test.yml exec app ./bin/bonfire remote
```

Example Elixir commands:
```elixir
# List users
Bonfire.Me.Users.list_users()

# Reindex search
Bonfire.Search.Indexer.maybe_reindex_all()

# Exit
Ctrl+C twice or Ctrl+D
```

### Restart services
```bash
docker compose -f docker-compose.local-test.yml restart
```

### Clean restart (removes data)
```bash
docker compose -f docker-compose.local-test.yml down -v
rm -rf test-data/
./test-local.sh
```

## Testing Different Scenarios

### Test without search
Comment out the `search` service in `docker-compose.local-test.yml` and remove `SEARCH_MEILI_INSTANCE` variable.

### Test with invite-only mode
In `docker-compose.local-test.yml`, change:
```yaml
- INVITE_ONLY=true
```

### Test different upload limits
Change `UPLOAD_LIMIT`:
```yaml
- UPLOAD_LIMIT=50000000  # 50MB
```

### Test database migrations
```bash
# Stop app, clear database, restart
docker compose -f docker-compose.local-test.yml stop app
docker compose -f docker-compose.local-test.yml exec db psql -U bonfire -c "DROP DATABASE bonfire; CREATE DATABASE bonfire;"
docker compose -f docker-compose.local-test.yml start app
# Watch logs to see migrations run
docker compose -f docker-compose.local-test.yml logs -f app
```

## Differences from Production YunoHost

| Aspect | Local Test | YunoHost Package |
|--------|-----------|------------------|
| **PostgreSQL** | Separate container | Host PostgreSQL |
| **Database Host** | `db` (container name) | `172.17.0.1` (Docker bridge) |
| **Port** | 4000 (exposed) | YunoHost-assigned (via nginx) |
| **Mail** | Test mode (no emails) | YunoHost SMTP |
| **HTTPS** | None (HTTP only) | YunoHost nginx with Let's Encrypt |
| **Domain** | localhost | Your domain |

## Verifying YunoHost Compatibility

After local testing succeeds, verify these aspects are compatible:

1. **Database connectivity from container to host**
   ```bash
   # In YunoHost setup, app connects to 172.17.0.1
   docker exec bonfire-app psql -h 172.17.0.1 -U bonfire -d bonfire -c "SELECT 1;"
   ```

2. **Port mapping**
   YunoHost assigns a port dynamically, which is mapped in the compose file

3. **Volume permissions**
   YunoHost uses specific user/group permissions for data directories

## Troubleshooting

### Services won't start
```bash
# Check what's running
docker ps -a

# Check for port conflicts
lsof -i :4000
lsof -i :5432
lsof -i :7700
```

### Database connection errors
```bash
# Check PostgreSQL is accepting connections
docker compose -f docker-compose.local-test.yml exec db pg_isready -U bonfire

# Check network connectivity
docker compose -f docker-compose.local-test.yml exec app ping -c 3 db
```

### Container keeps restarting
```bash
# Check logs for errors
docker compose -f docker-compose.local-test.yml logs app

# Common issues:
# - Insufficient memory (need 2GB+)
# - Database not ready (healthcheck should prevent this)
# - Invalid environment variables
```

### Search not working
```bash
# Check Meilisearch health
curl http://localhost:7700/health

# Check app can reach search
docker compose -f docker-compose.local-test.yml exec app curl http://search:7700/health
```

### Can't access http://localhost:4000
```bash
# Check if app is running
docker compose -f docker-compose.local-test.yml ps

# Check if port is mapped
docker port $(docker compose -f docker-compose.local-test.yml ps -q app)

# Check logs for binding errors
docker compose -f docker-compose.local-test.yml logs app | grep -i "endpoint"
```

## Clean Up

Remove everything (containers, volumes, data):
```bash
docker compose -f docker-compose.local-test.yml down -v
rm -rf test-data/
```

## Next Steps

Once local testing is successful:

1. Test on a real YunoHost instance
2. Verify database connectivity with host PostgreSQL
3. Test backup and restore procedures
4. Test upgrade process
5. Verify nginx reverse proxy configuration
6. Test mail notifications with YunoHost's SMTP

## Support

If you encounter issues:
- Check the [Bonfire documentation](https://bonfirenetworks.org/docs/)
- Review the [coop-cloud recipe](https://git.coopcloud.tech/coop-cloud/bonfire)
- Check YunoHost [app packaging guidelines](https://yunohost.org/packaging_apps)