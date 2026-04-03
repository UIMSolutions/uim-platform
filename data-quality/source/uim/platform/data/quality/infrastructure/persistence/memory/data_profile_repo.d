/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.infrastructure.persistence.memory.data_profile_repo;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.data_profile;
import uim.platform.data.quality.domain.ports.data_profile_repository;

// import std.algorithm : filter, sort;
// import std.array : array;

class MemoryDataProfileRepository : DataProfileRepository
{
  private DataProfile[ProfileId] store;

  DataProfile[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(p => p.tenantId == tenantId).array;
  }

  DataProfile* findById(ProfileId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  DataProfile* findLatestByDataset(TenantId tenantId, DatasetId datasetId)
  {
    DataProfile* latest;
    long latestTime = 0;
    foreach (ref p; store.byValue())
    {
      if (p.tenantId == tenantId && p.datasetId == datasetId && p.profiledAt > latestTime)
      {
        latest = &p;
        latestTime = p.profiledAt;
      }
    }
    return latest;
  }

  DataProfile[] findByDataset(TenantId tenantId, DatasetId datasetId)
  {
    return store.byValue().filter!(p => p.tenantId == tenantId && p.datasetId == datasetId).array;
  }

  void save(DataProfile profile)
  {
    store[profile.id] = profile;
  }

  void remove(ProfileId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
