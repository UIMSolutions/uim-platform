module uim.platform.xyz.domain.ports.master_data_object_repository;

import uim.platform.xyz.domain.entities.master_data_object;
import uim.platform.xyz.domain.types;

/// Port: outgoing — master data object persistence.
interface MasterDataObjectRepository
{
    MasterDataObject findById(MasterDataObjectId id);
    MasterDataObject[] findByTenant(TenantId tenantId);
    MasterDataObject[] findByCategory(TenantId tenantId, MasterDataCategory category);
    MasterDataObject[] findByDataModel(TenantId tenantId, DataModelId dataModelId);
    MasterDataObject[] findBySourceSystem(TenantId tenantId, string sourceSystem);
    MasterDataObject findByGlobalId(TenantId tenantId, string globalId);
    void save(MasterDataObject obj);
    void update(MasterDataObject obj);
    void remove(MasterDataObjectId id);
}
