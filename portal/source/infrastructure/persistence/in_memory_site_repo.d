module infrastructure.persistence.memory.site_repo;

import domain.entities.site;
import domain.types;
import domain.ports.site_repository;

class InMemorySiteRepository : SiteRepository
{
    private Site[SiteId] store;

    Site findById(SiteId id)
    {
        if (auto p = id in store)
            return *p;
        return Site.init;
    }

    Site findByAlias(TenantId tenantId, string alias_)
    {
        foreach (s; store.byValue())
        {
            if (s.tenantId == tenantId && s.alias_ == alias_)
                return s;
        }
        return Site.init;
    }

    Site[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        Site[] result;
        uint idx;
        foreach (s; store.byValue())
        {
            if (s.tenantId == tenantId)
            {
                if (idx >= offset && result.length < limit)
                    result ~= s;
                idx++;
            }
        }
        return result;
    }

    Site[] findByStatus(TenantId tenantId, SiteStatus status, uint offset = 0, uint limit = 100)
    {
        Site[] result;
        uint idx;
        foreach (s; store.byValue())
        {
            if (s.tenantId == tenantId && s.status == status)
            {
                if (idx >= offset && result.length < limit)
                    result ~= s;
                idx++;
            }
        }
        return result;
    }

    void save(Site site)
    {
        store[site.id] = site;
    }

    void update(Site site)
    {
        store[site.id] = site;
    }

    void remove(SiteId id)
    {
        store.remove(id);
    }

    ulong countByTenant(TenantId tenantId)
    {
        ulong count;
        foreach (s; store.byValue())
        {
            if (s.tenantId == tenantId)
                count++;
        }
        return count;
    }
}
