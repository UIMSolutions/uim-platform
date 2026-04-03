module infrastructure.persistence.memory.theme_repo;

import domain.entities.theme;
import domain.types;
import domain.ports.theme_repository;

class MemoryThemeRepository : ThemeRepository
{
    private Theme[ThemeId] store;

    Theme findById(ThemeId id)
    {
        if (auto p = id in store)
            return *p;
        return Theme.init;
    }

    Theme findDefault(TenantId tenantId)
    {
        foreach (t; store.byValue())
        {
            if (t.tenantId == tenantId && t.isDefault)
                return t;
        }
        return Theme.init;
    }

    Theme[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        Theme[] result;
        uint idx;
        foreach (t; store.byValue())
        {
            if (t.tenantId == tenantId)
            {
                if (idx >= offset && result.length < limit)
                    result ~= t;
                idx++;
            }
        }
        return result;
    }

    void save(Theme theme)
    {
        store[theme.id] = theme;
    }

    void update(Theme theme)
    {
        store[theme.id] = theme;
    }

    void remove(ThemeId id)
    {
        store.remove(id);
    }
}
