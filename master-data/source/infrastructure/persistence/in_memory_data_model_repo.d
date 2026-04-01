module infrastructure.persistence.memory.data_model_repo;

import domain.types;
import domain.entities.data_model;
import domain.ports.data_model_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryDataModelRepository : DataModelRepository
{
    private DataModel[DataModelId] store;

    DataModel findById(DataModelId id)
    {
        if (auto p = id in store)
            return *p;
        return DataModel.init;
    }

    DataModel[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    DataModel[] findByCategory(TenantId tenantId, MasterDataCategory category)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.category == category)
            .array;
    }

    DataModel findByName(TenantId tenantId, string name)
    {
        foreach (ref m; store.byValue())
        {
            if (m.tenantId == tenantId && m.name == name)
                return m;
        }
        return DataModel.init;
    }

    void save(DataModel model) { store[model.id] = model; }
    void update(DataModel model) { store[model.id] = model; }
    void remove(DataModelId id) { store.remove(id); }
}
