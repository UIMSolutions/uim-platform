module uim.platform.xyz.infrastructure.persistence.memory.health_check_repo;

import domain.types;
import domain.entities.health_check;
import domain.ports.health_check_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryHealthCheckRepository : HealthCheckRepository
{
    private HealthCheck[HealthCheckId] store;

    HealthCheck findById(HealthCheckId id)
    {
        if (auto p = id in store)
            return *p;
        return HealthCheck.init;
    }

    HealthCheck[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    HealthCheck[] findByResource(TenantId tenantId, MonitoredResourceId resourceId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.resourceId == resourceId)
            .array;
    }

    HealthCheck[] findByType(TenantId tenantId, CheckType checkType)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.checkType == checkType)
            .array;
    }

    void save(HealthCheck check) { store[check.id] = check; }
    void update(HealthCheck check) { store[check.id] = check; }
    void remove(HealthCheckId id) { store.remove(id); }
}
