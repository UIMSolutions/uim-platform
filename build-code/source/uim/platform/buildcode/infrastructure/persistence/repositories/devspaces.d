/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.repositories.devspaces;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class DevSpaceRepository : TenantRepository!(DevSpace, DevSpaceId), IDevSpaceRepository {

  size_t countByProject(TenantId tenantId, string projectId) {
    return findByProject(tenantId, projectId).length;
  }

  DevSpace[] filterByProject(DevSpace[] spaces, string projectId) {
    return spaces.filter!(ds => ds.projectId.value == projectId).array;
  }

  DevSpace[] findByProject(TenantId tenantId, string projectId) {
    return filterByProject(findByTenant(tenantId), projectId);
  }

  void removeByProject(TenantId tenantId, string projectId) {
    findByProject(tenantId, projectId).each!remove(ds);
  }

  override DevSpace[] findByStatus(TenantId tenantId, DevSpaceStatus status) {
    DevSpace[] result;
    foreach (ds; _store.byValue)
      if (ds.tenantId == tenantId && ds.status == status) result ~= ds;
    return result;
  }
}
