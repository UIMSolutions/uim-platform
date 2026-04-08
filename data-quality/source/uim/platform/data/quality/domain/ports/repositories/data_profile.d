/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.ports.repositories.data_profiles;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.data_profile;

/// Port for persisting data profiling results.
interface DataProfileRepository {
  DataProfile[] findByTenant(TenantId tenantId);
  DataProfile findById(TenantId tenantId, ProfileId profileId);
  DataProfile findLatestByDataset(TenantId tenantId, DatasetId datasetId);
  DataProfile[] findByDataset(TenantId tenantId, DatasetId datasetId);
  void save(DataProfile profile);
  void remove(TenantId tenantId, ProfileId profileId);
}
