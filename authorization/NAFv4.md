# NAF v4 - Authorization Management Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

## Capability View

- Application authorization domain management
- Policy lifecycle management
- Policy assignment management
- Runtime authorization decisioning
- Multi-backend persistence abstraction

## Service View

- Application CRUD APIs
- Application API CRUD APIs
- Policy CRUD APIs
- Policy assignment APIs
- Authorization evaluation API
- Health endpoint

## Operational View

- Security administrators manage policies and assignments
- Business applications request authorization decisions
- Tenant-aware routing via X-Tenant-Id

## Logical View

- ManagedApplication
- ApplicationApi
- AuthorizationPolicy
- PolicyCondition
- PolicyAssignment
- AuthorizationDecision

## Physical View

- Docker and Podman container runtime
- Kubernetes deployment with ConfigMap
- Backends: memory, file, MongoDB
