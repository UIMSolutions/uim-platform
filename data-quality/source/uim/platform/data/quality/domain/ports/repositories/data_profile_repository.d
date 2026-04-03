module uim.platform.data.quality.domain.ports.data_profile_repository;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.data_profile;

/// Port for persisting data profiling results.
interface DataProfileRepository
{
  DataProfile[] findByTenant(TenantId tenantId);
  DataProfile* findById(ProfileId id, TenantId tenantId);
  DataProfile* findLatestByDataset(TenantId tenantId, DatasetId datasetId);
  DataProfile[] findByDataset(TenantId tenantId, DatasetId datasetId);
  void save(DataProfile profile);
  void remove(ProfileId id, TenantId tenantId);
}
