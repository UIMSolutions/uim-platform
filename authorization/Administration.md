# Administration Guide - Authorization Management Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

## Runtime Configuration

- AUTHORIZATION_HOST
- AUTHORIZATION_PORT
- AUTHORIZATION_STORAGE_BACKEND
- AUTHORIZATION_FILE_PATH
- AUTHORIZATION_MONGO_URI
- AUTHORIZATION_MONGO_DB
- AUTHORIZATION_MONGO_COLLECTION
- AUTHORIZATION_SEED_BASE_POLICIES
- AUTHORIZATION_SEED_TENANT_ID
- AUTHORIZATION_SEED_APP_NAME
- AUTHORIZATION_SEED_ORGANIZATION_ID

## Backend Selection

Set AUTHORIZATION_STORAGE_BACKEND:

- MEMORY
- FILE
- MONGODB

## Base Policy Bootstrap

Startup bootstrap:

- Enable with AUTHORIZATION_SEED_BASE_POLICIES=true
- Tenant is selected by AUTHORIZATION_SEED_TENANT_ID
- Application name is selected by AUTHORIZATION_SEED_APP_NAME

Runtime seeding endpoint:

- POST /api/v1/policies/seed-base
- If applicationId is omitted, applicationName is used (or created automatically)

## Docker and Podman

Docker:

- docker build -t uim-authorization .
- docker run -p 8117:8117 -e AUTHORIZATION_STORAGE_BACKEND=FILE -e AUTHORIZATION_FILE_PATH=/data/authorization uim-authorization

Podman:

- podman build -f Containerfile -t uim-authorization .
- podman run -p 8117:8117 -e AUTHORIZATION_STORAGE_BACKEND=MONGODB -e AUTHORIZATION_MONGO_URI=mongodb://host:27017 uim-authorization

## Kubernetes

- kubectl apply -f k8s/configmap.yaml
- kubectl apply -f k8s/deployment.yaml
- kubectl apply -f k8s/service.yaml
- kubectl get pods -l app=authorization
- kubectl port-forward svc/authorization 8117:8117
