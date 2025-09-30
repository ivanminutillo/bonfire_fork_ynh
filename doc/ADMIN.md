## Administration

### First Setup

1. After installation, navigate to your Bonfire domain
2. Click "Sign up" to create your account
3. **Important:** The first account created automatically becomes the administrator

### Managing Containers

View container status:
```bash
cd /var/www/bonfire
docker compose ps
```

View logs:
```bash
docker compose logs -f
# or
journalctl -fu bonfire
```

Restart containers:
```bash
systemctl restart bonfire
# or
cd /var/www/bonfire
docker compose restart
```

### Database Access

Access PostgreSQL database:
```bash
sudo -u postgres psql bonfire
```

### Search Index (Meilisearch)

Check search health:
```bash
docker exec bonfire-bonfire curl http://search:7700/health
```

Rebuild search index (if needed):
```bash
docker exec -it bonfire-bonfire ./bin/bonfire remote
# In Elixir console:
Bonfire.Search.Indexer.maybe_reindex_all()
```

### Troubleshooting

**Containers won't start:**
```bash
# Check PostgreSQL is accessible from Docker
docker exec bonfire-bonfire psql -h 172.17.0.1 -U bonfire -d bonfire -c "SELECT 1;"
```

**Search not working:**
```bash
# Check meilisearch container
docker logs bonfire-bonfire-search
```

**Database connection errors:**
Check that PostgreSQL is configured to accept connections from Docker network:
```bash
grep "172.17.0.0/16" /etc/postgresql/*/main/pg_hba.conf
```

### Updating

Updates are handled through YunoHost:
```bash
sudo yunohost app upgrade bonfire
```

This will pull the latest Docker images and restart the containers.