/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.ports.repositories.match_groups;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.match_group;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
/// Port for persisting duplicate match groups.
interface MatchGroupRepository {
  MatchGroup[] findByTenant(TenantId tenantId);
  MatchGroup findById(TenantId tenantId, MatchGroupId groupId);
  MatchGroup[] findByDataset(TenantId tenantId, DatasetId datasetId);
  MatchGroup[] findUnresolved(TenantId tenantId);
  void save(MatchGroup group);
  void update(MatchGroup group);
  void remove(TenantId tenantId, MatchGroupId groupId);
}
