module domain.ports.monitored_resource_repository;

import domain.entities.monitored_resource;
import domain.types;

/// Port: outgoing - monitored resource persistence.
interface MonitoredResourceRepository
{
    MonitoredResource findById(MonitoredResourceId id);
    MonitoredResource[] findByTenant(TenantId tenantId);
    MonitoredResource[] findByType(TenantId tenantId, ResourceType type);
    MonitoredResource findByName(TenantId tenantId, string name);
    void save(MonitoredResource resource);
    void update(MonitoredResource resource);
    void remove(MonitoredResourceId id);
}
