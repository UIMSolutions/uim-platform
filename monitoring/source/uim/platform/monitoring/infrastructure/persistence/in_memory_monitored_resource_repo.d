module infrastructure.persistence.in_memory_monitored_resource_repo;

import domain.types;
import domain.entities.monitored_resource;
import domain.ports.monitored_resource_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryMonitoredResourceRepository : MonitoredResourceRepository
{
    private MonitoredResource[MonitoredResourceId] store;

    MonitoredResource findById(MonitoredResourceId id)
    {
        if (auto p = id in store)
            return *p;
        return MonitoredResource.init;
    }

    MonitoredResource[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    MonitoredResource[] findByType(TenantId tenantId, ResourceType type)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.resourceType == type)
            .array;
    }

    MonitoredResource findByName(TenantId tenantId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.tenantId == tenantId && e.name == name)
                return e;
        return MonitoredResource.init;
    }

    void save(MonitoredResource resource) { store[resource.id] = resource; }
    void update(MonitoredResource resource) { store[resource.id] = resource; }
    void remove(MonitoredResourceId id) { store.remove(id); }
}
