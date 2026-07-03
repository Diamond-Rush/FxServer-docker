# FXServer Docker (Pterodactyl Compatible)

This repository provides a lightweight, highly optimized Docker setup to run [FXServer](https://fivem.net/) (for FiveM and RedM) with txAdmin. The image is designed specifically to be fully compatible with **Pterodactyl Panel**

## Local Testing (Docker Compose)

If you want to test the server on your local machine before putting it on Pterodactyl:

1. Copy the environment variables template:
   ```bash
   cp .env.example .env
   ```
2. Build and start the server:
   ```bash
   docker compose up --build
   ```
3. Open your browser and go to `http://localhost:40120` to access the txAdmin interface. Follow the setup wizard to configure your server.

