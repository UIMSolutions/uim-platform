# UML - Authorization Management Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

## Domain Class Diagram

```mermaid
classDiagram
  class ManagedApplication {
    +id: string
    +tenantId: string
    +name: string
    +organizationId: string
    +description: string
  }

  class ApplicationApi {
    +id: string
    +applicationId: string
    +name: string
    +endpoint: string
    +operations: string[]
  }

  class AuthorizationPolicy {
    +id: string
    +applicationId: string
    +name: string
    +resource: string
    +action: string
    +isBasePolicy: bool
  }

  class PolicyCondition {
    +attribute: string
    +op: string
    +value: string
  }

  class PolicyAssignment {
    +id: string
    +policyId: string
    +principalType: string
    +principalId: string
  }

  class AuthorizationDecision {
    +allowed: bool
    +reason: string
    +matchedPolicyIds: string[]
  }

  ManagedApplication "1" --> "*" ApplicationApi
  ManagedApplication "1" --> "*" AuthorizationPolicy
  AuthorizationPolicy "1" --> "*" PolicyCondition
  AuthorizationPolicy "1" --> "*" PolicyAssignment
```

## Component Diagram

```mermaid
flowchart LR
  Web[Presentation Web MVC]
  Cli[Presentation CLI MVC]
  Gui[Presentation GUI MVC]

  AppsUC[ManageApplicationsUseCase]
  PoliciesUC[ManagePoliciesUseCase]
  AssignUC[ManageAssignmentsUseCase]
  EvalUC[EvaluateAuthorizationsUseCase]

  RepoPort[AuthorizationRepository Port]
  MemRepo[Memory Adapter]
  FileRepo[File Adapter]
  MongoRepo[MongoDB Adapter]

  Web --> AppsUC
  Web --> PoliciesUC
  Web --> AssignUC
  Web --> EvalUC
  Cli --> AppsUC
  Gui --> PoliciesUC

  AppsUC --> RepoPort
  PoliciesUC --> RepoPort
  AssignUC --> RepoPort
  EvalUC --> RepoPort

  RepoPort --> MemRepo
  RepoPort --> FileRepo
  RepoPort --> MongoRepo
```
