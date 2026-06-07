/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.persistence.memory.flex_applications;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

class MemoryFlexApplicationRepository : TenantRepository!(FlexApplication, FlexApplicationId), FlexApplicationRepository {

  bool existsById(TenantId tenantId, FlexApplicationId id) {
    return !findById(tenantId, id).isNull;
  }

  FlexApplication findById(TenantId tenantId, FlexApplicationId id) {
    foreach (a; findByTenant(tenantId))
      if (a.id_ == id) return a;
    return FlexApplication.init;
  }

  bool removeById(TenantId tenantId, FlexApplicationId id) {
    return remove(tenantId, id);
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) findByTenant(tenantId).length;
  }

  FlexApplication[] findByTenantAll(TenantId tenantId) {
    return findByTenant(tenantId);
  }

  FlexApplication findByApp(TenantId tenantId, string appId) {
    foreach (a; findByTenant(tenantId))
      if (a.appId_ == appId) return a;
    return FlexApplication.init;
  }

  FlexApplication[] findActiveByTenant(TenantId tenantId) {
    FlexApplication[] result;
    foreach (a; findByTenant(tenantId))
      if (a.isActive_) result ~= a;
    return result;
  }

  FlexApplication[] findByNamespace(TenantId tenantId, string ns) {
    FlexApplication[] result;
    foreach (a; findByTenant(tenantId))
      if (a.namespace_ == ns) result ~= a;
    return result;
  }
}
