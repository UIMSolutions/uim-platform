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
interface IPermissionRepository : ITenantRepository!(Permission, PermissionId) {
  size_t countByResource(TenantId tenantId, string resourceId, ResourceType resourceType, );
  Permission[] findByResource(TenantId tenantId, string resourceId, ResourceType resourceType, );
  void removeByResource(TenantId tenantId, string resourceId, ResourceType resourceType);
  
  size_t countByUser(TenantId tenantId, UserId userId);
  Permission[] findByUser(TenantId tenantId, UserId userId);
  void removeByUser(TenantId tenantId, UserId userId);
  
  Permission findByResourceAndUser(TenantId tenantId, string resourceId, ResourceType resourceType,
      UserId userId);

}
