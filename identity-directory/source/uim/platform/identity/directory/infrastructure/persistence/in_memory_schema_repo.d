module uim.platform.xyz.infrastructure.persistence.memory.schema_repo;

import uim.platform.xyz.domain.entities.schema;
import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.ports.schema_repository;

/// In-memory adapter for custom schema persistence.
class MemorySchemaRepository : SchemaRepository
{
    private Schema[SchemaId] store;

    Schema findById(SchemaId id)
    {
        if (auto p = id in store)
            return *p;
        return Schema.init;
    }

    Schema findByName(TenantId tenantId, string name)
    {
        foreach (s; store.byValue())
        {
            if (s.tenantId == tenantId && s.name == name)
                return s;
        }
        return Schema.init;
    }

    Schema[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        Schema[] result;
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

    void save(Schema schema)
    {
        store[schema.id] = schema;
    }

    void update(Schema schema)
    {
        store[schema.id] = schema;
    }

    void remove(SchemaId id)
    {
        store.remove(id);
    }
}
