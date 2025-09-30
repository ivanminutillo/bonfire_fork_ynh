#!/bin/bash
set -e

# Local testing script for Bonfire YunoHost package
# This simulates the YunoHost environment locally using Docker Compose

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Bonfire YunoHost Local Testing${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Check Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not available${NC}"
    echo "Please install Docker Compose or update Docker to include compose plugin"
    exit 1
fi

# Check architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    echo -e "${GREEN}✓${NC} Architecture: x86_64 (amd64)"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    echo -e "${YELLOW}⚠${NC}  Architecture: ARM64"
    echo -e "${YELLOW}Note: You may need to edit docker-compose.local-test.yml to use aarch64 image${NC}"
else
    echo -e "${RED}✗${NC} Unsupported architecture: $ARCH"
    exit 1
fi

# Create test data directories
echo ""
echo -e "${GREEN}Creating test data directories...${NC}"
mkdir -p test-data/uploads
mkdir -p test-data/meilisearch

# Start services
echo ""
echo -e "${GREEN}Starting services...${NC}"
echo "This will:"
echo "  1. Start PostgreSQL database"
echo "  2. Start Meilisearch search engine"
echo "  3. Start Bonfire application"
echo ""
echo -e "${YELLOW}This may take a few minutes on first run (downloading images)${NC}"
echo ""

docker compose -f docker-compose.local-test.yml up -d

# Wait for services to be ready
echo ""
echo -e "${GREEN}Waiting for services to be ready...${NC}"
echo -n "Checking PostgreSQL"
for i in {1..30}; do
    if docker compose -f docker-compose.local-test.yml exec -T db pg_isready -U bonfire &>/dev/null; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

echo -n "Checking Meilisearch"
for i in {1..30}; do
    if curl -s http://localhost:7700/health &>/dev/null; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

echo -n "Checking Bonfire"
for i in {1..60}; do
    if curl -s http://localhost:4000 &>/dev/null; then
        echo -e " ${GREEN}✓${NC}"
        break
    fi
    echo -n "."
    sleep 3
done

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Services are ready!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Access Bonfire at: ${GREEN}http://localhost:4000${NC}"
echo "Meilisearch dashboard: ${GREEN}http://localhost:7700${NC}"
echo ""
echo "Useful commands:"
echo "  ${YELLOW}docker compose -f docker-compose.local-test.yml logs -f${NC}         # View logs"
echo "  ${YELLOW}docker compose -f docker-compose.local-test.yml ps${NC}               # Check status"
echo "  ${YELLOW}docker compose -f docker-compose.local-test.yml restart${NC}          # Restart services"
echo "  ${YELLOW}docker compose -f docker-compose.local-test.yml down${NC}             # Stop and remove"
echo "  ${YELLOW}docker compose -f docker-compose.local-test.yml down -v${NC}          # Stop and remove volumes"
echo ""
echo "Database access:"
echo "  ${YELLOW}docker compose -f docker-compose.local-test.yml exec db psql -U bonfire${NC}"
echo ""
echo "App shell:"
echo "  ${YELLOW}docker compose -f docker-compose.local-test.yml exec app ./bin/bonfire remote${NC}"
echo ""
echo -e "${GREEN}First user to sign up will be the admin!${NC}"
echo ""