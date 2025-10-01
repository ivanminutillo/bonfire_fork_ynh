## Administration

### First Setup

After installation, an admin account is automatically created using:
- **Username:** The YunoHost user you selected during installation
- **Email:** The email associated with that YunoHost user
- **Password:** The password you provided during installation

You can log in immediately at your Bonfire domain.

### Configuring Bonfire Settings

Bonfire provides a **Config Panel** for easy post-installation configuration.

#### Via Web Admin (Recommended)

1. Go to **YunoHost Admin Panel** → **Applications** → **Bonfire** → **Config**
2. Modify settings in the web interface:
   - **Email Settings:** SMTP server, port, authentication, from address
   - **Instance Settings:** Name, invite-only mode, description, upload limits, log level
   - **Advanced Settings:** Feature flags (image processing, AI features, LiveView native)
3. Click **Apply** to save changes
4. Bonfire will automatically restart with new settings

#### Via Command Line

```bash
# View current configuration
yunohost app config get bonfire

# Set a specific value
yunohost app config set bonfire main.instance.app_name="My Bonfire Instance"
yunohost app config set bonfire main.instance.log_level="debug"
yunohost app config set bonfire main.instance.invite_only=false

# Enable/disable features
yunohost app config set bonfire advanced.features.with_ai=true
```

### Email Configuration

By default, Bonfire uses **YunoHost's built-in SMTP server** (localhost:25) with no authentication required. Emails are sent from `bonfire@yourdomain.com`.

To use an external SMTP provider (Gmail, SendGrid, etc.):

1. Go to Config Panel → **Email Settings**
2. Configure:
   - SMTP server hostname
   - Port (usually 587 for STARTTLS)
   - Username and password
   - From address
3. Apply changes

### Managing the Service

View service status:
```bash
systemctl status bonfire
```

View logs:
```bash
journalctl -fu bonfire
# or
tail -f /var/log/bonfire/bonfire.log
```

Restart Bonfire:
```bash
systemctl restart bonfire
```

### Database Access

Access PostgreSQL database:
```bash
sudo -u postgres psql bonfire
```

Common database commands:
```sql
-- List all users
SELECT * FROM bonfire_data_identity_user;

-- Count posts
SELECT COUNT(*) FROM bonfire_data_social_post;
```

### Search Index (Meilisearch)

Meilisearch runs as a separate systemd service.

Check status:
```bash
systemctl status meilisearch-bonfire
```

View logs:
```bash
journalctl -fu meilisearch-bonfire
```

Rebuild search index (if needed):
```bash
cd /var/www/bonfire
sudo -u bonfire /var/www/bonfire/_build/prod/rel/bonfire/bin/bonfire rpc "Bonfire.Search.Indexer.maybe_reindex_all()"
```

### Troubleshooting

**Service won't start:**
```bash
# Check for errors
journalctl -u bonfire -n 100

# Check if port is already in use
ss -tlnp | grep 50160
```

**Search not working:**
```bash
# Check meilisearch service
systemctl status meilisearch-bonfire
journalctl -u meilisearch-bonfire -n 50
```

**Database connection errors:**
```bash
# Test database connection
sudo -u bonfire psql -h localhost -U bonfire -d bonfire -c "SELECT 1;"
```

**Email not sending:**
```bash
# Check postfix is running (for local SMTP)
systemctl status postfix

# Test SMTP connection
telnet localhost 25
```

### Performance Tuning

#### Increase Upload Limits

Via Config Panel: **Main** → **Instance Settings** → **Max upload size**

Or via CLI:
```bash
yunohost app config set bonfire main.instance.upload_limit="100MB"
```

#### Adjust Logging Level

For production, use `info` level. For debugging issues, use `debug`:
```bash
yunohost app config set bonfire main.instance.log_level="debug"
# Don't forget to set back to "info" when done
```

#### Database Optimization

```bash
# Vacuum and analyze database
sudo -u postgres psql bonfire -c "VACUUM ANALYZE;"
```

### Updating

Updates are handled through YunoHost:
```bash
yunohost app upgrade bonfire
```

The upgrade process will:
1. Stop the Bonfire service
2. Update the application files
3. Run database migrations
4. Restart the service

### Backup and Restore

YunoHost automatically handles backups including:
- Application files
- Database
- Configuration files
- User data

Create manual backup:
```bash
yunohost backup create --apps bonfire
```

Restore from backup:
```bash
yunohost backup restore <backup_name>
```

### Federation and Domain Changes

⚠️ **Warning:** After initial setup, **DO NOT CHANGE YOUR DOMAIN**. This will break federation with other ActivityPub instances.

The domain is permanently tied to your instance's identity in the fediverse.
