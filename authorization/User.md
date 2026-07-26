# User Guide - Authorization Management Service

## Typical Flow

1. Create an application
2. Create one or more application APIs
3. Create base or custom policies
4. Assign policies to users or groups
5. Evaluate a request at runtime

## Example Requests

Set header in all requests:

- X-Tenant-Id: demo-tenant

Create application:

- POST /api/v1/applications

{
  "name": "incident-management",
  "organizationId": "global",
  "description": "Incident app"
}

Create policy:

- POST /api/v1/policies

{
  "applicationId": "<app-id>",
  "name": "support",
  "description": "Support can read incidents in US",
  "resource": "Incident",
  "action": "Read",
  "isBasePolicy": false,
  "conditions": [
    { "attribute": "country", "op": "eq", "value": "US" }
  ]
}

Assign policy:

- POST /api/v1/policy-assignments

{
  "policyId": "<policy-id>",
  "principalType": "user",
  "principalId": "alice"
}

Evaluate:

- POST /api/v1/authorization/evaluate

{
  "principalId": "alice",
  "applicationId": "<app-id>",
  "resource": "Incident",
  "action": "Read",
  "attributes": {
    "country": "US",
    "organization": "global"
  }
}
