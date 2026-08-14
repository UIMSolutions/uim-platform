# NAFv4 - TOGAF Building Blocks Service

## NV-1 Overview

- System Name: UIM Architecture Building Blocks Service
- Version: 1.0.0
- Language: D (dlang)
- Framework: vibe.d
- Pattern: Clean Architecture + Hexagonal Architecture
- Purpose: manage TOGAF building blocks across architecture domains

## NV-2 Capability Taxonomy

- Building Block Governance
- Lifecycle and Version Management
- Domain-specific Architecture Cataloging
- Tenant-scoped Architecture Repository
- Health and Operability

Building block categories:

- Architecture Building Blocks (ABB)
- Solution Building Blocks (SBB)
- Data Building Blocks (DBB)
- Business Building Blocks (BBB)
- Technology Building Blocks (TBB)

## NOV-1 Operational Concept

- Users and tooling call REST endpoints to manage building blocks.
- Presentation layer validates and forwards requests to use cases.
- Use case layer enforces business rules and orchestration.
- Domain defines entities and repository ports.
- Infrastructure provides memory repository adapter and DI container.

## NSV-1 Service Taxonomy

- REST/JSON API over HTTP
- Health endpoint for orchestration
- Stateless service container

## NTV-1 Technical Standards

- D + vibe.d runtime
- DUB build and test pipeline
- OCI-compatible container images (Docker, Podman)
- Kubernetes deployment manifests

## NCV-1 Container View

- Dockerfile for Docker image build.
- Containerfile for Podman/OCI workflow.
- Runtime variables: `ARCHITECTURE_HOST`, `ARCHITECTURE_PORT`.

## NCV-2 Deployment View

Kubernetes resources included:

- ConfigMap: `architecture-config`
- Deployment: `architecture`
- Service: `architecture`

The deployment exposes port `8122` and uses readiness/liveness probes at `/api/v1/health`.

## NSOV-1 Security View

- Tenant scoping inherited from UIM service controller base.
- Minimal endpoint surface with explicit CRUD routes.
- Non-root runtime can be applied in platform hardening profiles.
