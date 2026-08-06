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

  size_t countByStatus(TenantId tenantId, DevSpaceStatus status) {
    return findByStatus(tenantId, status).length;
  }

  DevSpace[] filterByStatus(DevSpace[] spaces, DevSpaceStatus status) {
    return spaces.filter!(ds => ds.status == status).array;
  }

  DevSpace[] findByStatus(TenantId tenantId, DevSpaceStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, DevSpaceStatus status) {
    findByStatus(tenantId, status).each!remove(ds);
  }

}
