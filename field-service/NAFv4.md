# NAF v4 Architecture Views - Field Service Management

NATO Architecture Framework v4 (NAFv4) views for the Field Service Management Service, modeled after SAP Field Service Management (SAP FSM).

## C1 - Capability Taxonomy

```mermaid
graph TB
    FSM[Field Service Management]
    FSM --> SCM[Service Call Management]
    FSM --> PAD[Planning and Dispatching]
    FSM --> EQM[Equipment Management]
    FSM --> TEM[Technician Management]
    FSM --> CUM[Customer Management]
    FSM --> SKM[Skill Management]
    FSM --> SFM[Smartform Management]
    FSM --> ASM[Assignment Management]

    SCM --> SCM1[Create Service Calls]
    SCM --> SCM2[Track Call Status]
    SCM --> SCM3[Prioritize Requests]
    SCM --> SCM4[Resolve and Close]

    PAD --> PAD1[Schedule Activities]
    PAD --> PAD2[Dispatch Technicians]
    PAD --> PAD3[Best Match Scheduling]
    PAD --> PAD4[Route Optimization]

    EQM --> EQM1[Register Equipment]
    EQM --> EQM2[Track Warranty]
    EQM --> EQM3[Service History]
    EQM --> EQM4[Measuring Points]

    TEM --> TEM1[Manage Technician Profiles]
    TEM --> TEM2[Track Availability]
    TEM --> TEM3[Manage Workload]
    TEM --> TEM4[Regional Assignment]

    CUM --> CUM1[Customer Registry]
    CUM --> CUM2[Contact Management]
    CUM --> CUM3[Account Classification]
    CUM --> CUM4[Location Tracking]

    SKM --> SKM1[Define Skills]
    SKM --> SKM2[Certification Tracking]
    SKM --> SKM3[Proficiency Levels]
    SKM --> SKM4[Expiration Management]

    SFM --> SFM1[Build Checklists]
    SFM --> SFM2[Service Reports]
    SFM --> SFM3[Signature Capture]
    SFM --> SFM4[Safety Labels]

    ASM --> ASM1[Propose Assignments]
    ASM --> ASM2[Accept/Reject]
    ASM --> ASM3[Track Progress]
    ASM --> ASM4[Match Scoring]
```

## C2 - Enterprise Vision

The Field Service Management Service provides a comprehensive platform for field service operations optimization. It enables:

1. **Service Call Management** through customer request creation, priority-based classification, multi-channel origin tracking, and resolution workflows
2. **Planning and Dispatching** through activity scheduling, technician assignment, skill-based matching, and route optimization
3. **Equipment Management** through equipment registration, serial number tracking, warranty management, measuring points, and service history
4. **Technician Workforce** through profile management, availability windows, workload capacity, travel radius, and regional assignment
5. **Customer Master Data** through business partner registration, contact management, geolocation, industry classification, and account tracking
6. **Skill and Certification** through skill definitions, proficiency levels, certification tracking, expiration management, and issuing authority
7. **Smartforms and Reporting** through digital checklists, service reports, work instructions, safety labels, signature capture, and approval workflows
8. **Assignment Lifecycle** through technician-activity matching, scheduling policies, match scoring, acceptance tracking, and completion management

## L1 - Node Types

```mermaid
graph TB
    subgraph Logical["Logical Nodes"]
        API[API Gateway Node]
        APP[Application Node]
        DATA[Data Node]
    end

    subgraph Physical["Physical Mapping"]
        K8SVC[K8s Service :8107]
        K8POD[K8s Pod - vibe.d Server]
        MEM[In-Memory Store]
    end

    API --> K8SVC
    APP --> K8POD
    DATA --> MEM
```

## L2 - Logical Scenario

```mermaid
sequenceDiagram
    participant CS as Customer Self-Service
    participant DP as Dispatcher
    participant FT as Field Technician
    participant API as FSM API :8107
    participant DB as Data Store

    CS->>API: POST /service-calls (report issue)
    API->>DB: Save service call
    API-->>CS: 201 Created

    DP->>API: GET /service-calls (review queue)
    API->>DB: Query service calls
    API-->>DP: Service call list

    DP->>API: GET /technicians?status=available
    API->>DB: Query available technicians
    API-->>DP: Technician list with skills

    DP->>API: POST /activities (create task)
    API->>DB: Save activity
    API-->>DP: 201 Created

    DP->>API: POST /assignments (assign best match)
    API->>DB: Save assignment
    API-->>DP: 201 Created

    FT->>API: PUT /assignments/:id (accept)
    API->>DB: Update assignment status
    API-->>FT: 200 Updated

    FT->>API: PUT /activities/:id (on-site, in-progress)
    API->>DB: Update activity status
    API-->>FT: 200 Updated

    FT->>API: POST /smartforms (submit checklist)
    API->>DB: Save smartform with signature
    API-->>FT: 201 Created

    FT->>API: PUT /activities/:id (complete)
    API->>DB: Update activity completed
    API-->>FT: 200 Updated

    DP->>API: PUT /service-calls/:id (resolve)
    API->>DB: Update service call resolved
    API-->>DP: 200 Updated
```

## L4 - Logical Activity

```mermaid
graph TB
    subgraph ServiceCallFlow["Service Call Flow"]
        A1[Receive Request] --> A2[Classify Priority]
        A2 --> A3[Plan Activities]
        A3 --> A4[Find Best Technician]
        A4 --> A5[Create Assignment]
        A5 --> A6[Dispatch]
    end

    subgraph FieldWorkFlow["Field Work Flow"]
        B1[Accept Job] --> B2[Travel to Site]
        B2 --> B3[Perform Service]
        B3 --> B4[Fill Smartform]
        B4 --> B5[Capture Signature]
        B5 --> B6[Complete Activity]
    end

    subgraph ResolutionFlow["Resolution Flow"]
        C1[Review Completion] --> C2[Approve Smartform]
        C2 --> C3[Resolve Service Call]
        C3 --> C4[Close Call]
    end

    A6 --> B1
    B6 --> C1
```

## P1 - Resource Types

```mermaid
graph TB
    subgraph Compute["Compute Resources"]
        POD[Kubernetes Pod]
        CTR[Container - Alpine 3.20]
        BIN[uim-field-service-platform-service]
    end

    subgraph Network["Network Resources"]
        SVC[K8s ClusterIP Service]
        PORT[Port 8107]
        HEALTH[Health Endpoint /health]
    end

    subgraph Storage["Storage Resources"]
        MEM[In-Memory Store]
        CFG[ConfigMap]
    end

    POD --> CTR
    CTR --> BIN
    SVC --> PORT
    PORT --> POD
    HEALTH --> BIN
    CFG --> CTR
    BIN --> MEM
```

## S1 - Service Taxonomy

```mermaid
graph TB
    subgraph External["External Services"]
        REST[REST API /api/v1/field-service]
        HEALTH[Health Check /health]
    end

    subgraph Internal["Internal Services"]
        SC[ServiceCallService]
        ACT[ActivityService]
        ASN[AssignmentService]
        EQ[EquipmentService]
        TECH[TechnicianService]
        CUST[CustomerService]
        SKL[SkillService]
        SF[SmartformService]
    end

    REST --> SC
    REST --> ACT
    REST --> ASN
    REST --> EQ
    REST --> TECH
    REST --> CUST
    REST --> SKL
    REST --> SF
```

## Sv1 - Service Interface

| Service | Method | Path | Description |
|---------|--------|------|-------------|
| Service Calls | GET | `/api/v1/field-service/service-calls` | List all service calls |
| Service Calls | POST | `/api/v1/field-service/service-calls` | Create service call |
| Service Calls | GET | `/api/v1/field-service/service-calls/:id` | Get by ID |
| Service Calls | PUT | `/api/v1/field-service/service-calls/:id` | Update |
| Service Calls | DELETE | `/api/v1/field-service/service-calls/:id` | Delete |
| Activities | GET | `/api/v1/field-service/activities` | List all activities |
| Activities | POST | `/api/v1/field-service/activities` | Create activity |
| Activities | GET | `/api/v1/field-service/activities/:id` | Get by ID |
| Activities | PUT | `/api/v1/field-service/activities/:id` | Update |
| Activities | DELETE | `/api/v1/field-service/activities/:id` | Delete |
| Assignments | GET | `/api/v1/field-service/assignments` | List all assignments |
| Assignments | POST | `/api/v1/field-service/assignments` | Create assignment |
| Assignments | GET | `/api/v1/field-service/assignments/:id` | Get by ID |
| Assignments | PUT | `/api/v1/field-service/assignments/:id` | Update |
| Assignments | DELETE | `/api/v1/field-service/assignments/:id` | Delete |
| Equipment | GET | `/api/v1/field-service/equipment` | List all equipment |
| Equipment | POST | `/api/v1/field-service/equipment` | Create equipment |
| Equipment | GET | `/api/v1/field-service/equipment/:id` | Get by ID |
| Equipment | PUT | `/api/v1/field-service/equipment/:id` | Update |
| Equipment | DELETE | `/api/v1/field-service/equipment/:id` | Delete |
| Technicians | GET | `/api/v1/field-service/technicians` | List all technicians |
| Technicians | POST | `/api/v1/field-service/technicians` | Create technician |
| Technicians | GET | `/api/v1/field-service/technicians/:id` | Get by ID |
| Technicians | PUT | `/api/v1/field-service/technicians/:id` | Update |
| Technicians | DELETE | `/api/v1/field-service/technicians/:id` | Delete |
| Customers | GET | `/api/v1/field-service/customers` | List all customers |
| Customers | POST | `/api/v1/field-service/customers` | Create customer |
| Customers | GET | `/api/v1/field-service/customers/:id` | Get by ID |
| Customers | PUT | `/api/v1/field-service/customers/:id` | Update |
| Customers | DELETE | `/api/v1/field-service/customers/:id` | Delete |
| Skills | GET | `/api/v1/field-service/skills` | List all skills |
| Skills | POST | `/api/v1/field-service/skills` | Create skill |
| Skills | GET | `/api/v1/field-service/skills/:id` | Get by ID |
| Skills | PUT | `/api/v1/field-service/skills/:id` | Update |
| Skills | DELETE | `/api/v1/field-service/skills/:id` | Delete |
| Smartforms | GET | `/api/v1/field-service/smartforms` | List all smartforms |
| Smartforms | POST | `/api/v1/field-service/smartforms` | Create smartform |
| Smartforms | GET | `/api/v1/field-service/smartforms/:id` | Get by ID |
| Smartforms | PUT | `/api/v1/field-service/smartforms/:id` | Update |
| Smartforms | DELETE | `/api/v1/field-service/smartforms/:id` | Delete |
| Health | GET | `/health` | Service health check |

## Cr1 - Security Policies

| Policy | Implementation |
|--------|---------------|
| Tenant Isolation | X-Tenant-Id header required for all write operations |
| Input Validation | FieldServiceValidator validates all domain objects before persistence |
| Error Handling | Controllers catch all exceptions, return generic error messages |
| Transport Security | HTTPS termination at ingress/load balancer level |
| Container Security | Minimal Alpine base image, non-root execution recommended |
