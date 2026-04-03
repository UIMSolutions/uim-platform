module uim.platform.master_data_integration.domain.ports.key_mapping_repository;

import uim.platform.master_data_integration.domain.entities.key_mapping;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — key mapping persistence.
interface KeyMappingRepository
{
    KeyMapping findById(KeyMappingId id);
    KeyMapping[] findByTenant(TenantId tenantId);
    KeyMapping[] findByObjectId(TenantId tenantId, MasterDataObjectId objectId);
    KeyMapping[] findByCategory(TenantId tenantId, MasterDataCategory category);
    KeyMapping findByClientKey(TenantId tenantId, ClientId clientId, string localKey);
    void save(KeyMapping mapping);
    void update(KeyMapping mapping);
    void remove(KeyMappingId id);
}
