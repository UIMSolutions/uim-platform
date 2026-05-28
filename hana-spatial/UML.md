# UML — UIM HANA Spatial Platform Service

## Hexagonal Architecture Overview

```mermaid
graph TB
    subgraph Presentation
        HTTP[HTTP Controllers<br/>geocoding, routing, poi,<br/>isoline, geofence, layers,<br/>features, providers, jobs]
        CLI[CLI MVC stub]
        WEB[Web MVC stub]
        GUI[GUI MVC stub]
    end

    subgraph Application
        UC[Use Cases<br/>ManageGeocodingResults<br/>ManageRoutes<br/>ManagePointsOfInterest<br/>ManageIsolines<br/>ManageGeofenceZones<br/>ManageSpatialLayers<br/>ManageSpatialFeatures<br/>ManageProviders<br/>ManageGeocodingJobs]
        DTO[DTOs]
    end

    subgraph Domain
        ENT[Entities<br/>GeocodingResult · Route · PointOfInterest<br/>Isoline · GeofenceZone · SpatialLayer<br/>SpatialFeature · Provider · GeocodingJob]
        PORTS[Repository Ports<br/>9 interfaces]
        VALS[Value Objects<br/>GeoCoordinate · BoundingBox · Address]
        ENUMS[Enumerations]
        SVC[Domain Services<br/>SpatialValidator]
    end

    subgraph Infrastructure
        MEM[Memory Repositories<br/>9 in-memory implementations]
        CFG[Config<br/>SrvConfig · loadConfig]
        CTR[DI Container<br/>buildContainer]
    end

    HTTP --> UC
    CLI --> UC
    WEB --> UC
    GUI --> UC
    UC --> PORTS
    UC --> ENT
    UC --> DTO
    PORTS --> MEM
    CTR --> MEM
    CTR --> UC
    CTR --> HTTP
```

## Domain Class Diagram

```mermaid
classDiagram
    class GeocodingResult {
        +GeocodingResultId id
        +TenantId tenantId
        +string inputAddress
        +GeocodingType type
        +GeoCoordinate coordinate
        +Address address
        +GeocodingMatchLevel matchLevel
        +double confidence
        +string providerId
        +string language
        +string countryCode
        +long createdAt
    }

    class Route {
        +RouteId id
        +TenantId tenantId
        +GeoCoordinate origin
        +GeoCoordinate destination
        +TravelMode travelMode
        +RouteOptimization optimization
        +RouteLeg[] legs
        +double totalDistanceMeters
        +long totalDurationSeconds
        +string providerId
        +long createdAt
    }

    class PointOfInterest {
        +PointOfInterestId id
        +TenantId tenantId
        +string name
        +string description
        +PoiCategory category
        +GeoCoordinate coordinate
        +Address address
        +string phoneNumber
        +string website
        +string openingHours
        +string providerId
        +string externalId
        +string[string] attributes
        +long createdAt
    }

    class Isoline {
        +IsolineId id
        +TenantId tenantId
        +GeoCoordinate center
        +IsolineMode mode
        +double rangeValue
        +TravelMode travelMode
        +GeoCoordinate[] polygon
        +string providerId
        +long createdAt
    }

    class GeofenceZone {
        +GeofenceZoneId id
        +TenantId tenantId
        +string name
        +GeofenceShapeType shapeType
        +GeoCoordinate center
        +double radiusMeters
        +GeoCoordinate[] polygon
        +bool active
        +string[string] metadata
        +long createdAt
    }

    class SpatialLayer {
        +SpatialLayerId id
        +TenantId tenantId
        +string name
        +SpatialLayerType type
        +string coordinateSystem
        +long featureCount
        +bool isPublic
        +string[string] metadata
        +long createdAt
    }

    class SpatialFeature {
        +SpatialFeatureId id
        +TenantId tenantId
        +SpatialLayerId layerId
        +string name
        +GeometryType geometryType
        +string geometry
        +string properties
        +string[string] tags
        +long createdAt
    }

    class Provider {
        +ProviderId id
        +TenantId tenantId
        +string name
        +ProviderType type
        +ProviderStatus status
        +string apiKey
        +string baseUrl
        +bool supportsGeocoding
        +bool supportsRouting
        +bool supportsMapping
        +bool supportsIsoline
        +bool supportsPoi
        +string[] supportedRegions
        +string[string] config
        +long createdAt
    }

    class GeocodingJob {
        +GeocodingJobId id
        +TenantId tenantId
        +string name
        +SpatialJobStatus status
        +string providerId
        +string language
        +string countryCode
        +long totalItems
        +long processedItems
        +long failedItems
        +GeocodingJobItem[] items
        +long createdAt
    }

    class GeoCoordinate {
        +double latitude
        +double longitude
    }

    class Address {
        +string street
        +string houseNumber
        +string city
        +string postalCode
        +string country
        +string countryCode
    }

    Route --> GeoCoordinate : origin/destination
    PointOfInterest --> GeoCoordinate : coordinate
    PointOfInterest --> Address : address
    Isoline --> GeoCoordinate : center
    GeofenceZone --> GeoCoordinate : center
    GeocodingResult --> GeoCoordinate : coordinate
    GeocodingResult --> Address : address
    SpatialFeature --> SpatialLayer : layerId
    GeocodingJob --> GeocodingJob : items[]
```

## Sequence: Forward Geocoding

```mermaid
sequenceDiagram
    participant Client
    participant GeocodingController
    participant ManageGeocodingResultsUseCase
    participant GeocodingResultRepository

    Client->>GeocodingController: POST /api/v1/spatial/geocode
    GeocodingController->>ManageGeocodingResultsUseCase: geocode(GeocodeAddressRequest)
    ManageGeocodingResultsUseCase->>GeocodingResultRepository: save(GeocodingResult)
    GeocodingResultRepository-->>ManageGeocodingResultsUseCase: CommandResult
    ManageGeocodingResultsUseCase-->>GeocodingController: CommandResult{id, success}
    GeocodingController-->>Client: 201 {id, message}
```

## Sequence: Geofence Point Check

```mermaid
sequenceDiagram
    participant Client
    participant GeofenceController
    participant ManageGeofenceZonesUseCase
    participant GeofenceZoneRepository

    Client->>GeofenceController: POST /api/v1/spatial/geofences/check
    GeofenceController->>ManageGeofenceZonesUseCase: checkPoint(GeofenceCheckRequest)
    ManageGeofenceZonesUseCase->>GeofenceZoneRepository: findById(tenantId, zoneId)
    GeofenceZoneRepository-->>ManageGeofenceZonesUseCase: GeofenceZone
    ManageGeofenceZonesUseCase->>ManageGeofenceZonesUseCase: haversineDistance(coord1, coord2)
    ManageGeofenceZonesUseCase-->>GeofenceController: GeofenceCheckResult{inside, zoneId, zoneName}
    GeofenceController-->>Client: 200 {inside, zoneId, zoneName}
```

## Deployment Architecture

```mermaid
graph LR
    subgraph Kubernetes Cluster
        SVC[Service<br/>ClusterIP:8098]
        DEP[Deployment<br/>cloud-hana-spatial]
        CM[ConfigMap<br/>cloud-hana-spatial-config]
    end

    subgraph Container
        APP[uim-hana-spatial-platform-service<br/>D + vibe.d]
    end

    Client --> SVC --> DEP --> APP
    CM --> DEP
```
