# NAF v4 Architecture Description — UIM Integration Automation

> NATO Architecture Framework v4 description of the UIM Integration Automation service 2.0: guided integration
> workflows across an SAP landscape (SAP Cloud Integration Automation style) with a D/vibe.d backend, an SAP Fiori 3 /
> OpenUI5 frontend, built-in JWT login or SAP XSUAA.

---

## 1. Grid mapping

| NAF v4 viewpoint | Subject | Section |
|---|---|---|
| C1 Capability Taxonomy · C2 Enterprise Vision | what the service is able to do and why | §2 |
| C4 Standard Processes / L4 Logical Activities | scenario design, workflow execution, automation, login | §3 |
| S1 Service Taxonomy · S4 Service Functions | OData, REST, CLI, GUI, auth | §4 |
| L2 Logical Scenario · L3 Node Interactions | operational nodes and information flows | §5 |
| L7 Logical Data Model | entities and relations | §6 |
| P1 Resource Types · P2 Resource Structure | software components and layers | §7 |
| P4 Resource Functions / P5 Resource Connectivity | deployment | §8 |
| A8 Standards Profile | standards and technologies | §9 |
| Cr Security / constraints | authentication, authorization, secrets | §10 |
| Ar Architecture decisions | decisions and rationale | §11 |

---

## 2. Capability viewpoint

### C1 — Capability taxonomy

```text
Integration Automation
├── C1.1 Landscape management
│   ├── C1.1.1 System registry (type, host, client, SID, environment, region)
│   ├── C1.1.2 Connection testing (simulated or TCP)
│   └── C1.1.3 Destination management (protocol, URL, authentication, proxy; no secrets)
├── C1.2 Scenario design
│   ├── C1.2.1 Scenario catalogue (category, version, system types, prerequisites)
│   ├── C1.2.2 Task templates (manual, approval, automated, notification; roles, instructions)
│   ├── C1.2.3 Dependency modelling (sequence, afterPrevious, dependsOn — acyclic by construction)
│   └── C1.2.4 Versioning (draft → active → deprecated → archived; copy as new version)
├── C1.3 Guided execution
│   ├── C1.3.1 Workflow instantiation (systems matched to the scenario, open workflow limit)
│   ├── C1.3.2 Task processing (start, complete/approve, fail/reject, skip, retry, assign)
│   ├── C1.3.3 Progress tracking (ready tasks, current task, % done, auto-completion)
│   └── C1.3.4 Workflow control (start, suspend, resume, terminate)
├── C1.4 Automation
│   ├── C1.4.1 Automated tasks through destinations (HTTP, timeouts, outcome mapping)
│   ├── C1.4.2 Notifications (webhook)
│   └── C1.4.3 Background worker (periodic runs, dependency order, no overlap)
├── C1.5 Monitoring
│   ├── C1.5.1 Execution log (actions, outcomes, actors, durations, details)
│   ├── C1.5.2 KPIs (open/failed workflows, ready and own tasks, reachability, failures 24 h, completion rate)
│   └── C1.5.3 Housekeeping (log retention, purge)
└── C1.6 Access management
    ├── C1.6.1 Built-in login (JWT, PBKDF2, lockout, password change)
    ├── C1.6.2 XSUAA integration (approuter, RS256)
    └── C1.6.3 Scopes Read / Execute / Manage / Admin
```

### C2 — Enterprise vision

| Goal | Measure |
|---|---|
| Integrations are set up the same way every time | scenarios with versioned, frozen task templates |
| Nobody works on a step too early | dependencies; only ready tasks can start |
| Repetitive technical steps are automated | automated tasks through destinations, worker runs |
| Everyone sees where an integration stands | progress, current task, KPI header, "my tasks" |
| Every step is traceable | execution log with actor, outcome and duration |
| Secrets stay out of the application | credentials only in the environment / credential store |
| Runs everywhere | one binary: local, container, Kubernetes, SAP BTP Cloud Foundry |

---

## 3. Processes (C4 / L4)

| Process | Actor | Steps |
|---|---|---|
| P1 Maintain landscape | Integration expert (Manage) | create systems → test connections → create destinations |
| P2 Design scenario | Integration expert (Manage) | create draft → add task templates with dependencies → activate (graph checked) |
| P3 New version | Integration expert (Manage) | copy active scenario (draft 1.0 → 1.1, templates remapped) → change → activate → deprecate the old one |
| P4 Run integration | Operator (Execute) | new workflow (scenario, source, target) → start → process ready tasks → automation runs → completed |
| P5 Handle failure | Operator (Execute) | failed task fails the workflow → retry (attempts) or skip with reason → workflow continues |
| P6 Approve | Approver (Execute) | approval task → complete = approve / fail = reject (cannot be skipped) |
| P7 Pause / stop | Operator (Execute) | suspend → resume, or terminate with reason |
| P8 Monitor | Viewer (Read) | KPIs, workflows, tasks, execution log |
| P9 Housekeeping | Worker / Manage | daily purge after `logRetentionDays`, manual purge |
| P10 Log in | any user | `/auth/login` → token → scopes drive UI and API |

---

## 4. Service viewpoint (S1 / S4)

| Service | Interface | Function |
|---|---|---|
| S1 OData v4 | `/odata/v4/integration-automation` | entity sets Systems, Destinations, Scenarios, ScenarioTasks, Workflows, WorkflowTasks, ExecutionLogs, Users, Statistics; 18 actions; `$metadata` with Fiori annotations; `$batch` |
| S2 REST | `/api/v1/integration-automation` | resources, operations (`/workflows/{id}/start`, `/tasks/{id}/complete`, …), children, `/my-tasks`, `/automation/run` |
| S3 Authentication | `/auth/config`, `/auth/login`, `/auth/me`, `/auth/password`, `/auth/logout` | built-in JWT login |
| S4 Health | `/health`, `/api/v1/health` | liveness / readiness |
| S5 Web | `/app/*` | Fiori app for local development |
| S6 CLI | `uim-integration-automation-cli` | model driven entity commands + workflow, task and automation commands |
| S7 GUI | `uim-integration-automation-gui` | GtkD entity browser and action runner |
| S8 Automation (outbound) | destination URLs, webhook | automated tasks, notifications |

All driving adapters (S1, S2, S6, S7) use the same `ODataEngine` bound to the same driving ports, so validation,
authorization and errors are identical.

---

## 5. Logical / operational viewpoint (L2 / L3)

```text
 ┌────────────┐  HTTPS   ┌────────────┐  OData/REST + JWT   ┌──────────────────────────┐   HTTP(S)   ┌──────────────────┐
 │  Browser   │────────▶│ Approuter  │────────────────────▶│ integration-automation   │────────────▶│ Destination APIs │
 │ Fiori app  │          │  (XSUAA)   │                     │ backend (D / vibe.d)     │             │ S/4HANA, SF, BTP │
 └────────────┘          └────────────┘                     │                          │   TCP probe ┌──────────────────┐
       │ local: /app + /auth/login (jwt)                    │  worker ─ automation      │────────────▶│ landscape systems │
       └───────────────────────────────────────────────────▶│  file / memory store      │  webhook   ┌──────────────────┐
                                                             └──────────────────────────┘───────────▶│ notification hook │
 ┌────────────┐  same container & data file                          ▲                              └──────────────────┘
 │ CLI / GUI  │──────────────────────────────────────────────────────┘
 └────────────┘
```

| Interaction | From → to | Information |
|---|---|---|
| I1 | Browser → backend | queries, workflow and task operations (bearer token) |
| I2 | Approuter → XSUAA | login, token exchange |
| I3 | Backend → destination API | automated task call (payload, correlation ids, Authorization from the environment) |
| I4 | Backend → system | connection test (TCP connect) |
| I5 | Backend → webhook | notification JSON (tenant, workflow, task, role, assignee, message) |
| I6 | CLI/GUI ↔ data file | shared JSON snapshot (single node) |
| I7 | Backend → log | structured JSON lines of business events |

---

## 6. Logical data model (L7)

| Entity | Key | Main attributes | Relations |
|---|---|---|---|
| SystemConnection | tenantId + id | name, systemType, host, port, protocol, client, sid, environment, region, status, lastTestedAt | ← Destination, ← Workflow (source/target) |
| Destination | tenantId + id | name (unique), destinationType, url, authentication, proxyType, locationId, user, tokenServiceUrl, enabled | → SystemConnection, ← ScenarioTask |
| IntegrationScenario | tenantId + id | name, category, version, status, source/target system type, prerequisites, basedOnId | ◆ ScenarioTask, ← Workflow |
| ScenarioTask | tenantId + id | scenarioId, sequenceNumber, taskType, priority, role, instructions, endpoint, payload, afterPrevious, dependsOn | → Destination, → ScenarioTask |
| Workflow | tenantId + id | scenarioId, scenarioVersion, name, status, systems, counters, progressPercent, currentTaskId | ◆ WorkflowTask, ← ExecutionLog |
| WorkflowTask | tenantId + id | workflowId, templateId, status, assignedTo, dependsOn, result, errorMessage, attempts, timestamps | → WorkflowTask |
| ExecutionLog | tenantId + id | workflowId, taskId, action, outcome, message, details, executedBy, durationMs | → Workflow |
| UserAccount | tenantId + id (user name) | displayName, passwordHash, scopes, locked, failedLogins, lockedUntil | — |

Records are flat JSON documents per collection (`ia.systems`, `ia.workflowTasks`, …) with std-time audit fields;
mapping is derived from the entity declarations at compile time.

---

## 7. Resource viewpoint (P1 / P2)

| Resource | Type | Content |
|---|---|---|
| R1 backend | D executable | layers domain → ports → application → persistence / infrastructure → presentation |
| R2 CLI / R3 GUI | D executables | same container, other driving adapters |
| R4 frontend | OpenUI5 app | Main (7 tabs, KPI header), WorkflowDetail, ScenarioDetail, 14 fragments, i18n en/de |
| R5 approuter | Node.js | routes, CSRF, XSUAA |
| R6 uim-platform:service | D library | OData engine/controller, document stores, HS256/RS256, CLI and GUI frameworks |
| R7 data file | JSON | snapshot (batched writes, reload on change) |

```text
backend/source/uim/platform/integration_automation/
  domain          entities · types · enumerations · exceptions · services (WorkflowEngine, ScenarioPlanner)
  ports           usecases · services · repositories · storages · messaging · gateways
  application     usecases (landscape, scenarios, workflows, tasks, monitoring, access) · services · dtos
  persistence     repositories · storages · mappers · records
  infrastructure  configuration · logging · security · clients · workers · container
  presentation    odata · http · web · cli · gui
```

---

## 8. Physical deployment (P4 / P5)

### SAP BTP (Cloud Foundry) — `mta.yaml`

| Module / resource | Type | Notes |
|---|---|---|
| integration-automation-srv | binary_buildpack | `ldc2` release build, `/health` check, `IA_AUTOMATION_MODE=http`, `IA_CONNECTIVITY_MODE=tcp` |
| integration-automation-approuter | approuter.nodejs | serves the Fiori app from `resources/`, destination with `forwardAuthToken` |
| integration-automation-xsuaa | xsuaa / application | `approuter/xs-security.json`: scopes, 4 role templates, 4 role collections |
| integration-automation-config | user-provided | runtime overrides in `VCAP_SERVICES` |

### Kubernetes — `k8s/`

| Object | Notes |
|---|---|
| Deployment | 1 replica (file store), `Recreate`, non-root, read-only root FS, probes on `/health` |
| Service | port 80 → 8090 |
| ConfigMap | `IA_*` settings (jwt mode, worker, automation and connectivity modes, retention) |
| Secret | `IA_JWT_SECRET`, `IA_ADMIN_PASSWORD`, optionally `IA_DESTINATION_<NAME>_AUTHORIZATION` |
| PVC | `/data` for the snapshot |

Container: multi-stage `Dockerfile` / `Containerfile` (ldc 1.40 → ubuntu 24.04), build context = repository root.

---

## 9. Standards profile (A8)

| Area | Standard / technology |
|---|---|
| Language / runtime | D (dmd 2.112, ldc 1.40), vibe.d 0.10.5, uim-framework 26.11 |
| API | OData v4.01 (JSON, CSDL XML, `$batch`), REST/JSON, RFC 7807-like error bodies |
| UI | SAP Fiori 3 design, OpenUI5 1.120 (`sap.m`, `sap.f`), OData V4 model |
| Security | OAuth 2.0 bearer tokens, JWT (RFC 7519) HS256 / RS256, PBKDF2-HMAC-SHA256 (RFC 8018), XSUAA |
| Deployment | MTA 3.3, Cloud Foundry, OCI images, Kubernetes |
| Observability | structured JSON log lines, health endpoint |
| Documentation | Mermaid UML, NAF v4 |

---

## 10. Security and constraints

| Topic | Measure |
|---|---|
| Authentication | XSUAA (RS256, approuter) or built-in JWT (HS256, ≥ 32 character secret, TTL 1 h); `open` only for development |
| Authorization | scopes enforced by the OData engine for OData, REST, actions; Manage ⇒ Execute ⇒ Read; Admin for users |
| Passwords | PBKDF2 120 000 rounds, random salt, rehash on login, min. 10 characters, lockout after 5 failures, equal answers for unknown users |
| Secrets of destinations | never stored or returned; injected per destination from `IA_DESTINATION_<NAME>_AUTHORIZATION` |
| Outbound calls | only to configured destination URLs / webhook; timeouts; response excerpt limited to 16 KiB, log detail to 8 000 characters |
| Multi-tenancy | every record and query scoped by tenant (`zid` claim, `X-Tenant-Id` in open mode) |
| Input | payloads validated against the EDM model, ids `[A-Za-z0-9._-]{1,64}`, length limits, enumerations checked |
| Constraints | file store = single node; automation is at-least-once per claim (a task is claimed before the call); change sets of `$batch` are not atomic |

---

## 11. Architecture decisions

| # | Decision | Rationale |
|---|---|---|
| AD1 | Hexagonal layers with ports for repositories, automation, connectivity, clock, credentials | domain and use cases testable without network, time or storage |
| AD2 | Workflow progress and dependency resolution as pure domain services | one answer for UI, API, worker and tests |
| AD3 | Dependencies only to lower sequence numbers | acyclic by construction, sequence = valid execution order, parallel steps via equal numbers |
| AD4 | Templates frozen outside drafts; copy as new version | running and future workflows stay reproducible |
| AD5 | Tasks copied into the workflow at instantiation | later scenario versions never change running workflows |
| AD6 | One EDM model drives OData, REST, CLI and GUI | no duplicated validation or authorization |
| AD7 | Automation gateway with `simulate` default and `http` adapter | safe demos and tests; production calls only when switched on |
| AD8 | Secrets outside the service | no credential storage, fits BTP Credential Store / Kubernetes secrets |
| AD9 | Built-in JWT login next to XSUAA | usable outside BTP with the same scopes and token claims |
| AD10 | Batched document writes (unit of work) | instantiating a workflow writes the snapshot once |
| AD11 | Open workflow limit configurable (default 15) | mirrors SAP CIAS, adjustable per installation |
| AD12 | uim-framework pinned to 26.11.1 | 26.11.2 removed `uim.services`, which the shared service library requires |
