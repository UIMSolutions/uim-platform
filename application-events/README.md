# SAP Cloud Application Event Hub — UIM Platform Adapter

A D/vibe.d microservice that mirrors the capabilities of **SAP Cloud Application Event Hub** on SAP BTP, following **Clean Architecture** combined with **Hexagonal Architecture** (Ports & Adapters).

## Overview

SAP Cloud Application Event Hub distributes business events between SAP cloud applications in a customer landscape. This service replicates the core domain — event subscriptions, topics, channels, message routing, filtering, dead-letter queues, BTP formations and system registrations — with three persistence backends (memory, file, MongoDB) and four presentation layers (HTTP REST, CLI, Web MVC, GUI MVC).

## Domain Model

| Entity | Description |
|---|---|
| `EventSubscription` | Subscription pairing a producer system to a consumer system for an event type |
| `EventTopic` | Named event type/topic definition with versioning |
| `EventChannel` | Transport channel (queue, topic, webhook) backed by a topic |
| `EventMessage` | Individual event envelope routed through a channel |
| `EventFilter` | Filter rule applied to a subscription to restrict event delivery |
| `DeadLetterEntry` | Failed message entry awaiting manual re-processing |
| `Formation` | SAP BTP landscape formation grouping producer/consumer systems |
| `SystemRegistration` | SAP cloud system registered as producer and/or consumer |

## API Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/appevents/subscriptions` | List event subscriptions |
| POST | `/api/v1/appevents/subscriptions` | Create subscription |
| GET | `/api/v1/appevents/subscriptions/:id` | Get subscription |
| PUT | `/api/v1/appevents/subscriptions/:id` | Update subscription |
| DELETE | `/api/v1/appevents/subscriptions/:id` | Delete subscription |
| GET | `/api/v1/appevents/topics` | List event topics |
| POST | `/api/v1/appevents/topics` | Create topic |
| GET | `/api/v1/appevents/channels` | List channels |
| POST | `/api/v1/appevents/channels` | Create channel |
| GET | `/api/v1/appevents/messages` | List messages |
| POST | `/api/v1/appevents/messages` | Publish message |
| GET | `/api/v1/appevents/filters` | List filters |
| POST | `/api/v1/appevents/filters` | Create filter |
| GET | `/api/v1/appevents/dead-letters` | List dead-letter entries |
| GET | `/api/v1/appevents/formations` | List formations |
| POST | `/api/v1/appevents/formations` | Create formation |
| GET | `/api/v1/appevents/systems` | List system registrations |
| POST | `/api/v1/appevents/systems` | Register system |
| GET | `/api/v1/health` | Health check |

## Configuration (env vars)

| Variable | Default | Description |
|---|---|---|
| `APPEVENTS_HOST` | `0.0.0.0` | Bind address |
| `APPEVENTS_PORT` | `8132` | HTTP port |
| `APPEVENTS_PERSISTENCE` | `memory` | Backend: `memory`, `file`, `mongodb` |
| `APPEVENTS_FILE_PATH` | `./data` | Base path for file persistence |
| `APPEVENTS_MONGODB_URI` | `mongodb://localhost:27017` | MongoDB connection URI |
| `APPEVENTS_MONGODB_DB` | `appevents` | MongoDB database name |

## Running

```bash
# Development (memory)
dub run

# Docker
docker build -t uim-appevents-platform-service .
docker run -p 8132:8132 uim-appevents-platform-service

# Podman
podman build -t uim-appevents-platform-service .
podman run -p 8132:8132 uim-appevents-platform-service

# Kubernetes
kubectl apply -f k8s/
```

## Architecture

Clean Architecture layers:

```
Domain → Application → Infrastructure
                  ↑
             Presentation (HTTP / CLI / Web / GUI)
```

Hexagonal ports: `ITenantRepository`, `ServiceXxxRepository` interfaces in the domain; adapters in `infrastructure/persistence/{memory,file,mongodb}`.

## References

- [SAP Cloud Application Event Hub](https://help.sap.com/docs/sap-cloud-application-event-hub)
- [Feature Scope Description](https://help.sap.com/doc/a0f0c0abb23c4a8eb36cd486c652557a/Cloud/en-US/fc64847588234ac6945a4b89c87bbd02.pdf)
