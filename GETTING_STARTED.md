# Getting Started — DECP Microservices

This guide walks you through setting up and running the entire DECP platform locally.

## Prerequisites

| Tool               | Version | Install                                                       |
| ------------------ | ------- | ------------------------------------------------------------- |
| **Java JDK**       | 17      | [Adoptium](https://adoptium.net/)                             |
| **Node.js**        | 18+     | [nodejs.org](https://nodejs.org/)                             |
| **Docker Desktop** | Latest  | [docker.com](https://www.docker.com/products/docker-desktop/) |
| **Task**           | 3.x     | [taskfile.dev](https://taskfile.dev/installation/)            |

### Installing Task (one-time)

**Windows (winget):**

```powershell
winget install Task.Task
```

**Windows (Chocolatey):**

```powershell
choco install go-task
```

**macOS:**

```bash
brew install go-task
```

**Linux (snap):**

```bash
sudo snap install task --classic
```

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/DinethShakya23/uop-decp-microservices.git
cd uop-decp-microservices
```

### 2. Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` if you need to change any default credentials. The defaults work out of the box for local development.

### 3. Install frontend dependencies

```bash
task install:frontend
```
> **TROUBLESHOOT**
>
> If the task command is not recognized, you may need to add the Task installation directory to your PATH environment variable

### 4. Start everything with a single command

> **IMPORTANT**
>
> Make sure the Docker engine is running before executing this command.  

```bash
task start
```

This will:

1. Start infrastructure containers (PostgreSQL, MongoDB, Redis, RabbitMQ)
2. Build all 11 backend services
3. Launch all backend services + frontend dev server in parallel

Once running, open **http://localhost:5173** in your browser.

## Verify Services Are Running

```bash
task health
```

This checks the health endpoint of every service and reports UP or DOWN.

## Service Ports

| Service                  | Port  | URL                    |
| ------------------------ | ----- | ---------------------- |
| **Frontend**             | 5173  | http://localhost:5173  |
| **API Gateway**          | 8080  | http://localhost:8080  |
| **Auth Service**         | 8081  | http://localhost:8081  |
| **User Service**         | 8082  | http://localhost:8082  |
| **Post Service**         | 8083  | http://localhost:8083  |
| **Job Service**          | 8084  | http://localhost:8084  |
| **Event Service**        | 8085  | http://localhost:8085  |
| **Research Service**     | 8086  | http://localhost:8086  |
| **Messaging Service**    | 8087  | http://localhost:8087  |
| **Notification Service** | 8088  | http://localhost:8088  |
| **Analytics Service**    | 8089  | http://localhost:8089  |
| **Mentorship Service**   | 8090  | http://localhost:8090  |
| **PostgreSQL**           | 5433  | localhost:5433         |
| **MongoDB**              | 27018 | localhost:27018        |
| **Redis**                | 6379  | localhost:6379         |
| **RabbitMQ Management**  | 15672 | http://localhost:15672 |

## Available Tasks

Run `task` or `task --list` to see all available commands. Here are the most common ones:

### Starting & Stopping

| Command             | Description                                         |
| ------------------- | --------------------------------------------------- |
| `task start`        | Start everything (infra → build → run)              |
| `task stop`         | Stop infrastructure containers                      |
| `task infra`        | Start only infrastructure (databases, broker)       |
| `task run:all`      | Run all services + frontend (assumes already built) |
| `task run:backend`  | Run only backend services                           |
| `task run:frontend` | Run only the frontend dev server                    |

### Running Individual Services

You can run any single service on its own:

```bash
task run:gateway       # API Gateway (8080)
task run:auth          # Auth Service (8081)
task run:user          # User Service (8082)
task run:post          # Post Service (8083)
task run:job           # Job Service (8084)
task run:event         # Event Service (8085)
task run:research      # Research Service (8086)
task run:messaging     # Messaging Service (8087)
task run:notification  # Notification Service (8088)
task run:analytics     # Analytics Service (8089)
task run:mentorship    # Mentorship Service (8090)
```

### Building

| Command                   | Description                         |
| ------------------------- | ----------------------------------- |
| `task build:backend`      | Build all backend JARs (skip tests) |
| `task build:backend:test` | Build with tests                    |
| `task build:frontend`     | Production build of frontend        |

### Testing

| Command              | Description                |
| -------------------- | -------------------------- |
| `task test:backend`  | Run all backend unit tests |
| `task test:frontend` | Run frontend tests         |

### Docker (Production)

| Command             | Description                       |
| ------------------- | --------------------------------- |
| `task docker:build` | Build all Docker images           |
| `task docker:up`    | Start platform in production mode |
| `task docker:down`  | Stop production containers        |
| `task docker:logs`  | Tail production logs              |

### Utilities

| Command             | Description                            |
| ------------------- | -------------------------------------- |
| `task health`       | Check health of all running services   |
| `task infra:status` | Show infrastructure container status   |
| `task clean`        | Remove all build artifacts             |
| `task infra:clean`  | Stop infra and delete all data volumes |

## Typical Development Workflow

1. **Start infrastructure once:**

   ```bash
   task infra
   ```

2. **Build backend:**

   ```bash
   task build:backend
   ```

3. **Run only the services you're working on:**

   ```bash
   task run:gateway
   # In another terminal:
   task run:auth
   task run:user
   ```

4. **Run the frontend in a separate terminal:**

   ```bash
   task run:frontend
   ```

5. **Check health anytime:**

   ```bash
   task health
   ```

6. **When done for the day:**
   ```bash
   task stop
   ```

## Troubleshooting

### Port already in use

If a port (e.g. 5432 for PostgreSQL) is already in use by a local installation, the Docker container will fail to start. The project uses **port 5433** for PostgreSQL to avoid this. If you still have conflicts, stop the local service or change the port mapping in `docker-compose.yml`.

### Java version issues

The Taskfile sets `JAVA_HOME` to `C:\Program Files\Java\jdk-17`. If your JDK is installed elsewhere, update the `JAVA_HOME` variable in `Taskfile.yml`:

```yaml
vars:
  JAVA_HOME: /path/to/your/jdk-17
```

### Build fails

Make sure Docker is running before `task start` — the backend services need PostgreSQL, MongoDB, Redis, and RabbitMQ to start.

```bash
# Verify Docker is running
docker info

# Start infra first, then build
task infra
task build:backend
```

### Frontend can't reach the API

All frontend API requests go through the API Gateway on port **8080**. Make sure the gateway and the target service are both running. Check with `task health`.
