module infrastructure.persistence.memory.module_repo;

import domain.types;
import domain.entities.kyma_module;
import domain.ports.module_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryModuleRepository : ModuleRepository
{
    private KymaModule[ModuleId] store;

    KymaModule findById(ModuleId id)
    {
        if (auto p = id in store)
            return *p;
        return KymaModule.init;
    }

    KymaModule findByName(KymaEnvironmentId envId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.environmentId == envId && e.name == name)
                return e;
        return KymaModule.init;
    }

    KymaModule[] findByEnvironment(KymaEnvironmentId envId)
    {
        return store.byValue().filter!(e => e.environmentId == envId).array;
    }

    KymaModule[] findByStatus(ModuleStatus status)
    {
        return store.byValue().filter!(e => e.status == status).array;
    }

    KymaModule[] findByType(ModuleType moduleType)
    {
        return store.byValue().filter!(e => e.moduleType == moduleType).array;
    }

    void save(KymaModule mod) { store[mod.id] = mod; }
    void update(KymaModule mod) { store[mod.id] = mod; }
    void remove(ModuleId id) { store.remove(id); }
}
