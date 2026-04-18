# Field Service Management

A microservice implementing features similar to SAP Field Service Management (SAP FSM) - a comprehensive cloud solution for optimizing field service operations, improving technician utilization, dispatching, service call management, equipment tracking, smartforms, and workforce scheduling.

Built with D (dlang) and vibe.d using a combination of clean and hexagonal architecture patterns.

## Features

- **Service Call Management** - Customer service requests with priority, category, origin tracking, contact information, and resolution workflows
- **Activity Management** - Scheduled work activities with planned/actual time tracking, travel time, feedback codes, and geolocation
- **Assignment Management** - Technician-to-activity assignments with scheduling policies, match scoring, and status lifecycle
- **Equipment Management** - Customer equipment registry with serial numbers, warranty tracking, measuring points, and service history
- **Technician Management** - Field technician profiles with availability windows, travel radius, workload capacity, and regional assignments
- **Customer Management** - Business partner master data with contact information, geolocation, industry classification, and account management
- **Skill Management** - Technician skills and certifications with proficiency levels, expiration tracking, and issuing authority
- **Smartform Management** - Digital forms, checklists, and service reports with templates, safety labels, signature capture, and approval workflows

## Architecture

```
source/
  uim/platform/field_service/
    domain/           # Entities, repository interfaces, domain services
    application/      # DTOs, use cases
    infrastructure/   # Config, container (DI), in-memory persistence
    presentation/     # HTTP controllers, JSON serialization
```

### Layers

| Layer | Responsibility |
|-------|---------------|
| **Domain** | ServiceCall, Activity, Assignment, Equipment, Technician, Customer, Skill, Smartform entities; repository interfaces; FieldServiceValidator |
| **Application** | ServiceCallDTO/ActivityDTO/etc.; ManageServiceCalls/ManageActivities/etc. use cases |
| **Infrastructure** | AppConfig (port 8107); Container (DI wiring); Memory repositories |
| **Presentation** | REST controllers; JSON serialization helpers |

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/field-service/service-calls` | List service calls |
| POST | `/api/v1/field-service/service-calls` | Create service call |
| GET | `/api/v1/field-service/service-calls/:id` | Get service call by ID |
| PUT | `/api/v1/field-service/service-calls/:id` | Update service call |
| DELETE | `/api/v1/field-service/service-calls/:id` | Delete service call |
| GET | `/api/v1/field-service/activities` | List activities |
| POST | `/api/v1/field-service/activities` | Create activity |
| GET | `/api/v1/field-service/activities/:id` | Get activity by ID |
| PUT | `/api/v1/field-service/activities/:id` | Update activity |
| DELETE | `/api/v1/field-service/activities/:id` | Delete activity |
| GET | `/api/v1/field-service/assignments` | List assignments |
| POST | `/api/v1/field-service/assignments` | Create assignment |
| GET | `/api/v1/field-service/assignments/:id` | Get assignment by ID |
| PUT | `/api/v1/field-service/assignments/:id` | Update assignment |
| DELETE | `/api/v1/field-service/assignments/:id` | Delete assignment |
| GET | `/api/v1/field-service/equipment` | List equipment |
| POST | `/api/v1/field-service/equipment` | Create equipment |
| GET | `/api/v1/field-service/equipment/:id` | Get equipment by ID |
| PUT | `/api/v1/field-service/equipment/:id` | Update equipment |
| DELETE | `/api/v1/field-service/equipment/:id` | Delete equipment |
| GET | `/api/v1/field-service/technicians` | List technicians |
| POST | `/api/v1/field-service/technicians` | Create technician |
| GET | `/api/v1/field-service/technicians/:id` | Get technician by ID |
| PUT | `/api/v1/field-service/technicians/:id` | Update technician |
| DELETE | `/api/v1/field-service/technicians/:id` | Delete technician |
| GET | `/api/v1/field-service/customers` | List customers |
| POST | `/api/v1/field-service/customers` | Create customer |
| GET | `/api/v1/field-service/customers/:id` | Get customer by ID |
| PUT | `/api/v1/field-service/customers/:id` | Update customer |
| DELETE | `/api/v1/field-service/customers/:id` | Delete customer |
| GET | `/api/v1/field-service/skills` | List skills |
| POST | `/api/v1/field-service/skills` | Create skill |
| GET | `/api/v1/field-service/skills/:id` | Get skill by ID |
| PUT | `/api/v1/field-service/skills/:id` | Update skill |
| DELETE | `/api/v1/field-service/skills/:id` | Delete skill |
| GET | `/api/v1/field-service/smartforms` | List smartforms |
| POST | `/api/v1/field-service/smartforms` | Create smartform |
| GET | `/api/v1/field-service/smartforms/:id` | Get smartform by ID |
| PUT | `/api/v1/field-service/smartforms/:id` | Update smartform |
| DELETE | `/api/v1/field-service/smartforms/:id` | Delete smartform |
| GET | `/health` | Health check |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `FIELD_SERVICE_HOST` | `0.0.0.0` | Bind host |
| `FIELD_SERVICE_PORT` | `8107` | Bind port |

## Build and Run

```bash
# Build and run
dub run

# Run tests
dub test
```

## Docker / Podman

```bash
# Build with Docker
docker build -t uim-platform/field-service .

# Build with Podman
podman build -t uim-platform/field-service -f Containerfile .

# Run
docker run -p 8107:8107 uim-platform/field-service
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
