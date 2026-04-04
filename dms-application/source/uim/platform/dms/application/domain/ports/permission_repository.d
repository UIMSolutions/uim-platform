/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.ports.repositories.permissions;

// import uim.platform.dms.application.domain.entities.permission;
// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
interface IPermissionRepository {
  Permission[] findByTenant(TenantId tenantId);
  Permission findById(PermissionId id, TenantId tenantId);
  Permission[] findByResource(string resourceId, ResourceType resourceType, TenantId tenantId);
  Permission[] findByUser(UserId userId, TenantId tenantId);
  Permission findByResourceAndUser(string resourceId, ResourceType resourceType,
      UserId userId, TenantId tenantId);
  void save(Permission perm);
  void update(Permission perm);
  void remove(PermissionId id, TenantId tenantId);
  void removeByResource(string resourceId, ResourceType resourceType, TenantId tenantId);
}
