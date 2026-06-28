/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.infrastructure.persistence.memory.data_profiles;


// import uim.platform.data_quality.domain.entities.data_profile;
// import uim.platform.data_quality.domain.ports.repositories.data_profiles;
import uim.platform.data_quality;

// mixin(ShowModule!());

@safe:
 

class MemoryDataProfileRepository : TenantRepository!(DataProfile, DataProfileId), DataProfileRepository {

  DataProfile findLatestByDataset(TenantId tenantId, DatasetId datasetId) {
    DataProfile latest;
    long latestTime = 0;
    foreach (p; find(tenantId)) {
      if (p.datasetId == datasetId && p.profiledAt > latestTime) {
        latest = p;
        latestTime = p.profiledAt;
      }
    }
    return latest;
  }

  // #region ByDataset
  size_t countByDataset(TenantId tenantId, DatasetId datasetId) {
    return findByDataset(tenantId, datasetId).length;
  }

  DataProfile[] filterByDataset(DataProfile[] profiles, DatasetId datasetId) {
    return profiles.filter!(p => p.datasetId == datasetId).array;
  }

  DataProfile[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    return find(tenantId).filter!(p => p.datasetId == datasetId).array;
  }

  void removeByDataset(TenantId tenantId, DatasetId datasetId) {
    findByDataset(tenantId, datasetId).removeAll;
  }
  // #endregion ByDataset

}
