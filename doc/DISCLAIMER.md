## Important Notes

### Docker Requirement
This package requires Docker and Docker Compose to be installed. It uses containerization to simplify dependency management and ensure consistency with upstream's recommended deployment method.

### PostgreSQL Configuration
During installation, PostgreSQL is configured to accept connections from Docker containers (172.17.0.0/16 network). This is necessary for the containerized Bonfire app to access the database.

### Resource Usage
- **Disk Space:** Requires approximately 3GB for Docker images and data storage
- **RAM:** Requires at least 1GB of available RAM for runtime
- **CPU:** Moderate CPU usage during startup and when processing media

### Multi-Instance Support
Currently, multi-instance is **disabled** in the manifest. Installing multiple instances on the same server may cause conflicts with Docker container names and ports.

### First User as Admin
The first user account created after installation automatically receives administrator privileges. Make sure to create your admin account immediately after installation.

### Backup and Restore
- Backups include the PostgreSQL database, uploaded files, and Meilisearch index
- Docker images are re-downloaded during restore
- Full restore may take several minutes due to Docker image pulls

### Known Limitations
- Search functionality requires both containers to be running
- Federation requires proper HTTPS setup (handled by YunoHost)
- Email notifications depend on YunoHost's mail system configuration

### Upstream Resources
- [Official Documentation](https://bonfirenetworks.org/docs/)
- [GitHub Repository](https://github.com/bonfire-networks/bonfire-app)
- [Production Docker Recipe](https://git.coopcloud.tech/coop-cloud/bonfire)