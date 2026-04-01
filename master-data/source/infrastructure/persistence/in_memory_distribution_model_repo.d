module infrastructure.persistence.memory.distribution_model_repo;

import domain.types;
import domain.entities.distribution_model;
import domain.ports.distribution_model_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryDistributionModelRepository : DistributionModelRepository
{
    private DistributionModel[DistributionModelId] store;

    DistributionModel findById(DistributionModelId id)
    {
        if (auto p = id in store)
            return *p;
        return DistributionModel.init;
    }

    DistributionModel[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    DistributionModel[] findByStatus(TenantId tenantId, DistributionModelStatus status)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.status == status)
            .array;
    }

    DistributionModel[] findBySourceClient(TenantId tenantId, ClientId sourceClientId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.sourceClientId == sourceClientId)
            .array;
    }

    void save(DistributionModel model) { store[model.id] = model; }
    void update(DistributionModel model) { store[model.id] = model; }
    void remove(DistributionModelId id) { store.remove(id); }
}
