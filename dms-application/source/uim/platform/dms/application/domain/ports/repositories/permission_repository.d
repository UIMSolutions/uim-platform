/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.domain.ports.repositories.permission_repository;

// import uim.platform.dms.application.domain.entities.permission;
// import uim.platform.dms.application.domain.types;
import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
interface IPermissionRepository {
  Permission[] findByTenant(TenantId tenantId);
  Permission findById(PermissionId tenantId, id tenantId);
  Permission[] findByResource(string resourceId, ResourceType resourceType, TenantId tenantId);
  Permission[] findByUser(UserId usertenantId, id tenantId);
  Permission findByResourceAndUser(string resourceId, ResourceType resourceType,
      UserId usertenantId, id tenantId);
  void save(Permission perm);
  void update(Permission perm);
  void remove(PermissionId tenantId, id tenantId);
  void removeByResource(string resourceId, ResourceType resourceType, TenantId tenantId);
}
