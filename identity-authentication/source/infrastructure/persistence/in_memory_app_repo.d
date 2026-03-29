module uim.platform.identity_authentication.infrastructure.persistence.in_memory_app;

import domain.entities.application;
import domain.types;
import domain.ports.application;

/// In-memory adapter for application/service provider persistence.
class InMemoryApplicationRepository : ApplicationRepository
{
    private Application[ApplicationId] store;

    Application findById(ApplicationId id)
    {
        if (auto p = id in store)
            return *p;
        return Application.init;
    }

    Application findByClientId(string clientId)
    {
        foreach (a; store.byValue())
        {
            if (a.clientId == clientId)
                return a;
        }
        return Application.init;
    }

    Application[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        Application[] result;
        uint idx;
        foreach (a; store.byValue())
        {
            if (a.tenantId == tenantId)
            {
                if (idx >= offset && result.length < limit)
                    result ~= a;
                idx++;
            }
        }
        return result;
    }

    void save(Application app)
    {
        store[app.id] = app;
    }

    void update(Application app)
    {
        store[app.id] = app;
    }

    void remove(ApplicationId id)
    {
        store.remove(id);
    }
}
