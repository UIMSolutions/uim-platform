/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.infrastructure.persistence.memory.match_groups;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.match_group;
import uim.platform.data.quality.domain.ports.repositories.match_groups;

// import std.algorithm : filter;
// import std.array : array;

class MemoryMatchGroupRepository : TenantRepository!(MatchGroup, MatchGroupId), MatchGroupRepository {

  // #region ByDataset
  size_t countByDataset(TenantId tenantId, DatasetId datasetId) {
    return findByDataset(tenantId, datasetId).length;
  }

  MatchGroup[] filterByDataset(MatchGroup[] groups, DatasetId datasetId) {
    return groups.filter!(g => g.datasetId == datasetId).array;
  }

  MatchGroup[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    return filterByDataset(findByTenant(tenantId), datasetId);
  }

  void removeByDataset(TenantId tenantId, DatasetId datasetId) {
    findByDataset(tenantId, datasetId).each!(entity => remove(entity.id));
  }
  // #endregion ByDataset

  // #region Unresolved
  size_t countUnresolved(TenantId tenantId) {
    return findUnresolved(tenantId).length;
  }

  MatchGroup[] filterUnresolved(MatchGroup[] groups, TenantId tenantId) {
    return groups.filter!(g => g.tenantId == tenantId && !g.resolved).array;
  }

  MatchGroup[] findUnresolved(TenantId tenantId) {
    return filterUnresolved(findByTenant(tenantId), tenantId);
  }

  void removeUnresolved(TenantId tenantId) {
    findUnresolved(tenantId).each!(entity => remove(entity.id));
  }
  // #endregion Unresolved

}
