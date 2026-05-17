# UML — Service Library (uim-platform-service)

> The `service` package is a **shared D library** — not an HTTP service.
> It provides the hexagonal-architecture scaffolding mixins, interfaces,
> base entities, and use-case helpers that every UIM Platform service depends on.

## Module Structure

```mermaid
classDiagram
    class IEntity {
        <<interface>>
        +Id id
        +Json toJson()
    }
    class IRepository~T~ {
        <<interface>>
        +T findById(Id)
        +T[] findAll()
        +void save(T)
        +void remove(Id)
    }
    class IService {
        <<interface>>
        +void start()
        +void stop()
    }
    class IConfig {
        <<interface>>
        +string host
        +ushort port
    }
    class ITenantEntity {
        <<interface>>
        +TenantId tenantId
    }
    class CommandResult {
        +bool success
        +string id
        +string errorMessage
    }

    IEntity <|-- ITenantEntity
    IRepository~T~ ..> IEntity : T
    IService --> IConfig : uses
```

---

## Mixin / Template Hierarchy

```mermaid
flowchart TB
    subgraph Mixins["Mixins (source/uim/platform/service/mixins/)"]
        M1[ObjMixin — id + toJson scaffolding]
        M2[DomainMixin — entity + repository]
        M3[RepositoryMixin — in-memory CRUD]
        M4[StoreMixin — store interface impl]
        M5[ServiceMixin — vibe.d server bootstrap]
        M6[ConfigMixin — env-based SrvConfig]
    end
    subgraph Entities["Base Entities (mixins/entities/)"]
        E1[GlobalEntity — tenantId + id]
        E2[IdEntity — strong-typed Id wrapper]
        E3[ResourceEntity — ResourceId + name]
    end
    subgraph Application["Application Helpers (application/)"]
        A1[dto.d — CommandResult + QueryResult]
        A2[usecases/id.d — IdUseCase base]
        A3[usecases/tenant.d — TenantUseCase base]
    end
    subgraph Interfaces["Interfaces (interfaces/)"]
        I1[IEntity, ITenantEntity]
        I2[IRepository~T~]
        I3[IService, IConfig, IStore]
    end

    M2 --> I1
    M3 --> I2
    M5 --> I3
    A2 --> A1
```

---

## Usage Pattern — Service Bootstrap

```mermaid
sequenceDiagram
    participant main as app main()
    participant CFG as SrvConfig (ConfigMixin)
    participant CTR as Container (buildContainer)
    participant SVC as HTTPService (ServiceMixin)

    main->>CFG: load from env (HOST/PORT)
    main->>CTR: buildContainer(cfg)
    CTR-->>main: DI container with repos + use cases
    main->>SVC: new HTTPService(container)
    SVC->>SVC: URLRouter + Controllers
    SVC-->>main: listenHTTP(cfg.host, cfg.port)
```
