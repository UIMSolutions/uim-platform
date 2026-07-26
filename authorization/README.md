# UIM Platform - Authorization Management Service

Authorization Management Service implemented with D and vibe.d using a combination of Clean Architecture and Hexagonal Architecture.

This service mirrors the core concepts and workflows described for SAP Cloud Identity Service Authorization Management Service (AMS):

- Business objects: Applications, Application APIs, Policies (base and custom), Policy Assignments, Authorization Decisions
- Core functions: policy authoring, assignment to principals, and runtime evaluation
- APIs for delegated authorization administration and application authorization checks
- IAM-style scoping via policy conditions (for example user attributes and application organization)

References:
- https://community.sap.com/t5/technology-blogs-by-sap/authorization-management-service-in-sap-cloud-identity-service/ba-p/13881014
- https://github.com/SAP-samples/btp-developer-guide-cap/blob/main/documentation/xsuaa-to-ams/README.md

## Architecture

Layering:

- Domain: entities, policy evaluation rules, repository ports
- Application: use cases and DTOs
- Infrastructure: adapters for memory, file, and MongoDB persistence
- Presentation: MVC in three adapters
  - presentation/web
  - presentation/cli
  - presentation/gui

## API Summary

All API calls require X-Tenant-Id header.

- POST /api/v1/applications
- GET /api/v1/applications
- GET /api/v1/applications/{id}
- PUT /api/v1/applications/{id}
- DELETE /api/v1/applications/{id}

- POST /api/v1/application-apis
- GET /api/v1/application-apis
- GET /api/v1/application-apis/{id}
- PUT /api/v1/application-apis/{id}
- DELETE /api/v1/application-apis/{id}

- POST /api/v1/policies
- POST /api/v1/policies/seed-base
- GET /api/v1/policies
- GET /api/v1/policies/base
- GET /api/v1/policies/{id}
- PUT /api/v1/policies/{id}
- DELETE /api/v1/policies/{id}

- POST /api/v1/policy-assignments
- GET /api/v1/policy-assignments
- GET /api/v1/policy-assignments/{id}
- DELETE /api/v1/policy-assignments/{id}

- POST /api/v1/authorization/evaluate
- GET /api/v1/health
- GET /api/v1/web

## Persistence Backends

Configured via AUTHORIZATION_STORAGE_BACKEND:

- MEMORY
- FILE
- MONGODB

Environment variables:

- AUTHORIZATION_HOST (default 0.0.0.0)
- AUTHORIZATION_PORT (default 8117)
- AUTHORIZATION_STORAGE_BACKEND (default MEMORY)
- AUTHORIZATION_FILE_PATH (default /data/authorization)
- AUTHORIZATION_MONGO_URI (default mongodb://localhost:27017)
- AUTHORIZATION_MONGO_DB (default uim_authorization)
- AUTHORIZATION_MONGO_COLLECTION (default tenant_state)
- AUTHORIZATION_SEED_BASE_POLICIES (default true)
- AUTHORIZATION_SEED_TENANT_ID (default default)
- AUTHORIZATION_SEED_APP_NAME (default authorization-management)
- AUTHORIZATION_SEED_ORGANIZATION_ID (default global)

## OpenAPI

- OpenAPI contract: openapi.yaml

## Build and Run

Build:

- dub build --config=defaultRun

Run:

- ./build/uim-authorization-platform-service

## Docker

Build and run:

- docker build -t uim-authorization .
- docker run -p 8117:8117 -e AUTHORIZATION_STORAGE_BACKEND=MEMORY uim-authorization

## Podman

Build and run:

- podman build -f Containerfile -t uim-authorization .
- podman run -p 8117:8117 -e AUTHORIZATION_STORAGE_BACKEND=MEMORY uim-authorization

## Kubernetes

- kubectl apply -f k8s/configmap.yaml
- kubectl apply -f k8s/deployment.yaml
- kubectl apply -f k8s/service.yaml
