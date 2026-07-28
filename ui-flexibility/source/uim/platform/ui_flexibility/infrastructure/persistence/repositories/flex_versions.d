/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.persistence.repositories.flex_versions;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

class MemoryFlexVersionRepository : TenantRepository!(FlexVersion, FlexVersionId), FlexVersionRepository {

  bool existsById(TenantId tenantId, FlexVersionId id) {
    return !findById(tenantId, id).isNull;
  }

  FlexVersion findById(TenantId tenantId, FlexVersionId id) {
    foreach (v; findByTenant(tenantId))
      if (v.id_ == id) return v;
    return FlexVersion.init;
  }

  bool removeById(TenantId tenantId, FlexVersionId id) {
    return remove(tenantId, id);
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) findByTenant(tenantId).length;
  }

  FlexVersion[] findByTenantAll(TenantId tenantId) {
    return findByTenant(tenantId);
  }

  FlexVersion[] findByApp(TenantId tenantId, string appId) {
    FlexVersion[] result;
    foreach (v; findByTenant(tenantId))
      if (v.appId_ == appId) result ~= v;
    return result;
  }

  FlexVersion findActiveByApp(TenantId tenantId, string appId) {
    foreach (v; findByTenant(tenantId))
      if (v.appId_ == appId && v.status_ == VersionStatus.active_) return v;
    return FlexVersion.init;
  }

  FlexVersion findByNumber(TenantId tenantId, string appId, long versionNumber) {
    foreach (v; findByTenant(tenantId))
      if (v.appId_ == appId && v.versionNumber_ == versionNumber) return v;
    return FlexVersion.init;
  }
}
