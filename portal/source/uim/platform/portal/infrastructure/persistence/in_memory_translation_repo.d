module infrastructure.persistence.memory.translation_repo;

import domain.entities.translation;
import domain.types;
import domain.ports.translation_repository;

class MemoryTranslationRepository : TranslationRepository
{
    private Translation[TranslationId] store;

    Translation findById(TranslationId id)
    {
        if (auto p = id in store)
            return *p;
        return Translation.init;
    }

    Translation[] findByResource(string resourceType, string resourceId, string language = "")
    {
        Translation[] result;
        foreach (t; store.byValue())
        {
            if (t.resourceType == resourceType && t.resourceId == resourceId)
            {
                if (language.length == 0 || t.language == language)
                    result ~= t;
            }
        }
        return result;
    }

    Translation[] findByLanguage(TenantId tenantId, string language, uint offset = 0, uint limit = 100)
    {
        Translation[] result;
        uint idx;
        foreach (t; store.byValue())
        {
            if (t.tenantId == tenantId && t.language == language)
            {
                if (idx >= offset && result.length < limit)
                    result ~= t;
                idx++;
            }
        }
        return result;
    }

    void save(Translation translation)
    {
        store[translation.id] = translation;
    }

    void update(Translation translation)
    {
        store[translation.id] = translation;
    }

    void remove(TranslationId id)
    {
        store.remove(id);
    }

    void removeByResource(string resourceType, string resourceId)
    {
        TranslationId[] toRemove;
        foreach (kv; store.byKeyValue())
        {
            if (kv.value.resourceType == resourceType && kv.value.resourceId == resourceId)
                toRemove ~= kv.key;
        }
        foreach (id; toRemove)
            store.remove(id);
    }
}
