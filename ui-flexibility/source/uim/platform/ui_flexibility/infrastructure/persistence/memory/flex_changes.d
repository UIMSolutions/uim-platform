/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.persistence.memory.flex_changes;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

class MemoryFlexChangeRepository : TenantRepository!(FlexChange, FlexChangeId), FlexChangeRepository {

  bool existsById(string tenantId, FlexChangeId id) {
    return !findById(tenantId, id).isNull;
  }

  FlexChange findById(string tenantId, FlexChangeId id) {
    foreach (c; findByTenant(tenantId))
      if (c.id_ == id) return c;
    return FlexChange.init;
  }

  bool removeById(string tenantId, FlexChangeId id) {
    return remove(tenantId, id);
  }

  long countByTenant(string tenantId) {
    return cast(long) findByTenant(tenantId).length;
  }

  FlexChange[] findByTenantAll(string tenantId) {
    return findByTenant(tenantId);
  }

  FlexChange[] findByApp(string tenantId, string appId) {
    FlexChange[] result;
    foreach (c; findByTenant(tenantId))
      if (c.appId_ == appId) result ~= c;
    return result;
  }

  FlexChange[] findByLayer(string tenantId, string appId, ChangeLayer layer) {
    FlexChange[] result;
    foreach (c; findByTenant(tenantId))
      if (c.appId_ == appId && c.layer_ == layer) result ~= c;
    return result;
  }

  FlexChange[] findByChangeType(string tenantId, string appId, ChangeType changeType) {
    FlexChange[] result;
    foreach (c; findByTenant(tenantId))
      if (c.appId_ == appId && c.changeType_ == changeType) result ~= c;
    return result;
  }
}
