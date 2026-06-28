/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.persistence.memory.flex_changes;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

class MemoryFlexChangeRepository : TenantRepository!(FlexChange, FlexChangeId), FlexChangeRepository {

  bool existsById(TenantId tenantId, FlexChangeId id) {
    return !findById(tenantId, id).isNull;
  }

  FlexChange findById(TenantId tenantId, FlexChangeId id) {
    foreach (c; find(tenantId))
      if (c.id_ == id) return c;
    return FlexChange.init;
  }

  bool removeById(TenantId tenantId, FlexChangeId id) {
    return remove(tenantId, id);
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) find(tenantId).length;
  }

  FlexChange[] findByTenantAll(TenantId tenantId) {
    return find(tenantId);
  }

  FlexChange[] findByApp(TenantId tenantId, string appId) {
    FlexChange[] result;
    foreach (c; find(tenantId))
      if (c.appId_ == appId) result ~= c;
    return result;
  }

  FlexChange[] findByLayer(TenantId tenantId, string appId, ChangeLayer layer) {
    FlexChange[] result;
    foreach (c; find(tenantId))
      if (c.appId_ == appId && c.layer_ == layer) result ~= c;
    return result;
  }

  FlexChange[] findByChangeType(TenantId tenantId, string appId, ChangeType changeType) {
    FlexChange[] result;
    foreach (c; find(tenantId))
      if (c.appId_ == appId && c.changeType_ == changeType) result ~= c;
    return result;
  }
}
