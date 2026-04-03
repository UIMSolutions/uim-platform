module uim.platform.xyz.domain.ports.data_model_repository;

import uim.platform.xyz.domain.entities.data_model;
import uim.platform.xyz.domain.types;

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
