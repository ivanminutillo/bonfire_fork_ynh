#!/bin/bash
# Start background log collector for Docker containers
cd __INSTALL_DIR__
/usr/bin/docker-compose -f __INSTALL_DIR__/docker-compose.yml logs -f >> /var/log/__APP__/__APP__.log 2>&1 &