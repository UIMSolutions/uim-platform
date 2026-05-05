/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.infrastructure.persistence.memory.permissions;

// import uim.platform.dms.application.domain.entities.permission;
// import uim.platform.dms.application.domain.ports.repositories.permissions;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class MemoryPermissionRepository : TenantRepository!(Permission, PermissionId), IPermissionRepository {
  // #region byResource
  size_t countByResource(TenantId tenantId, string resourceId, ResourceType resourceType) {
    return findByResource(tenantId, resourceId, resourceType).count;
  }

  Permission[] findByResource(TenantId tenantId, string resourceId, ResourceType resourceType) {
    return findByTenant(tenantId).filter!(e => e.resourceId == resourceId && e.resourceType == resourceType).array;
  }

  void removeByResource(TenantId tenantId, string resourceId, ResourceType resourceType) {
    findByResource(tenantId, resourceId, resourceType).each!(e => remove(e));
  }
  // #endregion byResource

  // #region byUser
  size_t countByUser(TenantId tenantId, UserId userId) {
    return findByUser(tenantId, userId).count;
  }

    Permission[] findByUser(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).filter!(e => e.userId == userId).array;
  }

  void removeByUser(TenantId tenantId, UserId userId) {
    findByUser(tenantId, userId).each!(e => remove(e));
  }
  // #endregion byUser

  Permission findByResourceAndUser(TenantId tenantId, string resourceId, ResourceType resourceType,
      UserId userId) {
    foreach (e; findByTenant(tenantId))
      if (e.resourceId == resourceId && e.resourceType == resourceType && e.userId == userId)
        return e;
    return Permission.init;
  }
}
