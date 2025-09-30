Bonfire is a federated social networking platform built on the ActivityPub protocol. This YunoHost package uses Docker containers for easy deployment and maintenance.

**Key Features:**
- Federated social networking with ActivityPub
- Full-text search powered by Meilisearch
- Media uploads support
- Email notifications via SMTP
- Invite-only registration by default

**Technical Implementation:**
- Uses Docker Compose with two containers: Bonfire app and Meilisearch
- Integrates with YunoHost's PostgreSQL, Nginx, and mail system
- Social flavor with all features enabled
- Automatic database migrations on startup
- First user to sign up becomes administrator

**Requirements:**
- Docker and Docker Compose
- ~3GB disk space for containers and data
- 1GB RAM for runtime

**Note:** This implementation follows the production-proven [coop-cloud Bonfire recipe](https://git.coopcloud.tech/coop-cloud/bonfire), ensuring reliability and best practices.