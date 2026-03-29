module infrastructure.persistence.in_memory_catalog_repo;

import domain.entities.catalog;
import domain.types;
import domain.ports.catalog_repository;

class InMemoryCatalogRepository : CatalogRepository
{
    private Catalog[CatalogId] store;

    Catalog findById(CatalogId id)
    {
        if (auto p = id in store)
            return *p;
        return Catalog.init;
    }

    Catalog[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        Catalog[] result;
        uint idx;
        foreach (c; store.byValue())
        {
            if (c.tenantId == tenantId)
            {
                if (idx >= offset && result.length < limit)
                    result ~= c;
                idx++;
            }
        }
        return result;
    }

    Catalog[] findByProvider(ProviderId providerId)
    {
        Catalog[] result;
        foreach (c; store.byValue())
        {
            if (c.providerId == providerId)
                result ~= c;
        }
        return result;
    }

    void save(Catalog catalog)
    {
        store[catalog.id] = catalog;
    }

    void update(Catalog catalog)
    {
        store[catalog.id] = catalog;
    }

    void remove(CatalogId id)
    {
        store.remove(id);
    }
}
