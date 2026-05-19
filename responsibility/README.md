# UIM Responsibility Management Platform Service

## Overview

The **Responsibility Management Service** is a microservice within the UIM Platform that provides agent determination capabilities for SAP BTP-inspired scenarios. It allows tenants to define teams, team types, team categories, member functions, responsibility contexts, rules, and definitions — and then resolve the responsible agents for any business object at runtime.

## Key Features

- **RACI-based agent assignment**: Responsible, Accountable, Consulted, Informed roles on team members
- **Multiple rule types**: Direct assignment, Business rule expression, Team-based, Hierarchical fallback
- **Responsibility contexts**: Map business object types to determination rules
- **Responsibility definitions**: Bind contexts, rules, and teams with optional validity periods and scope (global, regional, site)
- **Agent determination**: Single POST endpoint resolves agents for any object at runtime
- **Determination logs**: Full audit trail of every determination call
- **Multi-tenant**: All resources are tenant-scoped via `X-Tenant-Id` header

## Architecture

Clean + Hexagonal Architecture:

```
Presentation (HTTP)  →  Application (Use Cases)  →  Domain (Entities + Interfaces)
                                                    ↑
                                         Infrastructure (Memory Repos)
```

## Port

`8118`

## Environment Variables

| Variable               | Default     | Description              |
|------------------------|-------------|--------------------------|
| `RESPONSIBILITY_HOST`  | `0.0.0.0`   | Bind address             |
| `RESPONSIBILITY_PORT`  | `8118`      | Listening port           |

## API Endpoints

| Method | Path                                              | Description                        |
|--------|---------------------------------------------------|------------------------------------|
| GET    | `/health`                                         | Health check                       |
| GET    | `/api/v1/responsibility/rules`                    | List responsibility rules          |
| POST   | `/api/v1/responsibility/rules`                    | Create a rule                      |
| GET    | `/api/v1/responsibility/rules/:id`                | Get a rule                         |
| PUT    | `/api/v1/responsibility/rules/:id`                | Update a rule                      |
| DELETE | `/api/v1/responsibility/rules/:id`                | Delete a rule                      |
| GET    | `/api/v1/responsibility/team-categories`          | List team categories               |
| POST   | `/api/v1/responsibility/team-categories`          | Create a team category             |
| GET    | `/api/v1/responsibility/team-categories/:id`      | Get a category                     |
| PUT    | `/api/v1/responsibility/team-categories/:id`      | Update a category                  |
| DELETE | `/api/v1/responsibility/team-categories/:id`      | Delete a category                  |
| GET    | `/api/v1/responsibility/team-types`               | List team types                    |
| POST   | `/api/v1/responsibility/team-types`               | Create a team type                 |
| GET    | `/api/v1/responsibility/team-types/:id`           | Get a team type                    |
| PUT    | `/api/v1/responsibility/team-types/:id`           | Update a team type                 |
| DELETE | `/api/v1/responsibility/team-types/:id`           | Delete a team type                 |
| GET    | `/api/v1/responsibility/teams`                    | List teams                         |
| POST   | `/api/v1/responsibility/teams`                    | Create a team                      |
| GET    | `/api/v1/responsibility/teams/:id`                | Get a team                         |
| PUT    | `/api/v1/responsibility/teams/:id`                | Update a team                      |
| DELETE | `/api/v1/responsibility/teams/:id`                | Delete a team                      |
| GET    | `/api/v1/responsibility/team-members`             | List team members                  |
| POST   | `/api/v1/responsibility/team-members`             | Add a team member                  |
| GET    | `/api/v1/responsibility/team-members/:id`         | Get a member                       |
| PUT    | `/api/v1/responsibility/team-members/:id`         | Update a member                    |
| DELETE | `/api/v1/responsibility/team-members/:id`         | Remove a member                    |
| GET    | `/api/v1/responsibility/functions`                | List member functions              |
| POST   | `/api/v1/responsibility/functions`                | Create a function                  |
| GET    | `/api/v1/responsibility/functions/:id`            | Get a function                     |
| PUT    | `/api/v1/responsibility/functions/:id`            | Update a function                  |
| DELETE | `/api/v1/responsibility/functions/:id`            | Delete a function                  |
| GET    | `/api/v1/responsibility/contexts`                 | List responsibility contexts       |
| POST   | `/api/v1/responsibility/contexts`                 | Create a context                   |
| GET    | `/api/v1/responsibility/contexts/:id`             | Get a context                      |
| PUT    | `/api/v1/responsibility/contexts/:id`             | Update a context                   |
| DELETE | `/api/v1/responsibility/contexts/:id`             | Delete a context                   |
| GET    | `/api/v1/responsibility/definitions`              | List definitions                   |
| POST   | `/api/v1/responsibility/definitions`              | Create a definition                |
| GET    | `/api/v1/responsibility/definitions/:id`          | Get a definition                   |
| PUT    | `/api/v1/responsibility/definitions/:id`          | Update a definition                |
| DELETE | `/api/v1/responsibility/definitions/:id`          | Delete a definition                |
| POST   | `/api/v1/responsibility/determine`                | Determine responsible agents       |
| GET    | `/api/v1/responsibility/determination-logs`       | List determination logs            |
| GET    | `/api/v1/responsibility/determination-logs/:id`   | Get a log entry                    |
| DELETE | `/api/v1/responsibility/determination-logs/:id`   | Delete a log entry                 |

## Building

```bash
cd responsibility
dub build --compiler=ldc2 --build=release
```

## Docker / Podman

```bash
# Build
docker build -t uim-platform/responsibility:latest .
# or
podman build -t uim-platform/responsibility:latest .

# Run
docker run -p 8118:8118 uim-platform/responsibility:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## License

Apache 2.0 — see [LICENSE](../LICENSE)
