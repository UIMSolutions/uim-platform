module uim.platform.kyma.infrastructure.persistence.memory.application_repo;

import uim.platform.kyma.domain.types;
import uim.platform.kyma.domain.entities.application;
import uim.platform.kyma.domain.ports.application_repository;

// import std.algorithm : filter;
// import std.array : array;

class MemoryApplicationRepository : ApplicationRepository
{
    private Application[ApplicationId] store;

    Application findById(ApplicationId id)
    {
        if (auto p = id in store)
            return *p;
        return Application.init;
    }

    Application findByName(KymaEnvironmentId envId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.environmentId == envId && e.name == name)
                return e;
        return Application.init;
    }

    Application[] findByEnvironment(KymaEnvironmentId envId)
    {
        return store.byValue().filter!(e => e.environmentId == envId).array;
    }

    Application[] findByStatus(AppConnectivityStatus status)
    {
        return store.byValue().filter!(e => e.status == status).array;
    }

    Application[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    void save(Application app) { store[app.id] = app; }
    void update(Application app) { store[app.id] = app; }
    void remove(ApplicationId id) { store.remove(id); }
}
