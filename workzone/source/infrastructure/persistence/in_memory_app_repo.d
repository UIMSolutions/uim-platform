module infrastructure.persistence.memory.app_repo;

import domain.types;
import domain.entities.app_registration;
import domain.ports.app_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryAppRepository : AppRepository
{
    private AppRegistration[AppId] store;

    AppRegistration[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(a => a.tenantId == tenantId).array;
    }

    AppRegistration* findById(AppId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    AppRegistration[] findByStatus(AppStatus status, TenantId tenantId)
    {
        return store.byValue().filter!(a => a.tenantId == tenantId && a.status == status).array;
    }

    void save(AppRegistration app) { store[app.id] = app; }
    void update(AppRegistration app) { store[app.id] = app; }
    void remove(AppId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}
