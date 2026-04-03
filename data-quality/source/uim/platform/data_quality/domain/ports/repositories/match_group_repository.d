module uim.platform.xyz.domain.ports.match_group_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.match_group;

/// Port for persisting duplicate match groups.
interface MatchGroupRepository
{
    MatchGroup[] findByTenant(TenantId tenantId);
    MatchGroup* findById(MatchGroupId id, TenantId tenantId);
    MatchGroup[] findByDataset(TenantId tenantId, DatasetId datasetId);
    MatchGroup[] findUnresolved(TenantId tenantId);
    void save(MatchGroup group);
    void update(MatchGroup group);
    void remove(MatchGroupId id, TenantId tenantId);
}
