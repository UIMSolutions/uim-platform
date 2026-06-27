/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.infrastructure.persistence.memory.match_groups;


// import uim.platform.data_quality.domain.entities.match_group;
// import uim.platform.data_quality.domain.ports.repositories.match_groups;

import uim.platform.data_quality;

// mixin(ShowModule!());

@safe:

class MemoryMatchGroupRepository : TentRepository!(MatchGroup, MatchGroupId), MatchGroupRepository {

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
    findByDataset(tenantId, datasetId).each!(entity => remove(entity));
  }
  // #endregion ByDataset

  // #region Unresolved
  size_t countUnresolved(TenantId tenantId) {
    return findUnresolved(tenantId).length;
  }

  MatchGroup[] filterUnresolved(MatchGroup[] groups) {
    return groups.filter!(g => !g.resolved).array;
  }

  MatchGroup[] findUnresolved(TenantId tenantId) {
    return filterUnresolved(findByTenant(tenantId));
  }

  void removeUnresolved(TenantId tenantId) {
    findUnresolved(tenantId).each!(entity => remove(entity));
  }
  // #endregion Unresolved

}
