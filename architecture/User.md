# User Guide - TOGAF Building Blocks Service

## Who Should Use This Service

- Enterprise Architects
- Solution Architects
- Data Architects
- Business Analysts
- Technology Platform Teams

## Authentication and Tenant Scope

All endpoints are tenant-aware and rely on tenant scoping in the underlying UIM service controller base. Include the tenant header used in this platform, for example `X-Tenant-Id`.

## Typical Workflow

1. Create a building block with a TOGAF type.
2. Retrieve all blocks or filter by type.
3. Update lifecycle, ownership, and version as architecture evolves.
4. Delete obsolete blocks.

## Example Usage

Create:

```bash
curl -X POST http://localhost:8122/api/v1/building-blocks \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: demo-tenant" \
  -d '{
    "type": "technology",
    "name": "Central API Gateway",
    "description": "Shared ingress and policy enforcement",
    "owner": "platform-team",
    "lifecycleState": "identified",
    "status": "active",
    "versionLabel": "1.0.0",
    "tags": ["gateway", "security"]
  }'
```

List by type:

```bash
curl -H "X-Tenant-Id: demo-tenant" \
  http://localhost:8122/api/v1/building-blocks/types/technology
```

Health:

```bash
curl http://localhost:8122/api/v1/health
```
