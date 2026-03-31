module domain.ports.data_model_repository;

import domain.entities.data_model;
import domain.types;

/// Port: outgoing — data model/schema persistence.
interface DataModelRepository
{
    DataModel findById(DataModelId id);
    DataModel[] findByTenant(TenantId tenantId);
    DataModel[] findByCategory(TenantId tenantId, MasterDataCategory category);
    DataModel findByName(TenantId tenantId, string name);
    void save(DataModel model);
    void update(DataModel model);
    void remove(DataModelId id);
}
