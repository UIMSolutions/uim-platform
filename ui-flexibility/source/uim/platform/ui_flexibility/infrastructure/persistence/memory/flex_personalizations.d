/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.persistence.memory.flex_personalizations;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

class MemoryFlexPersonalizationRepository : TenantRepository!(FlexPersonalization, FlexPersonalizationId), FlexPersonalizationRepository {

  bool existsById(TenantId tenantId, FlexPersonalizationId id) {
    return !find(tenantId, id).isNull;
  }

  FlexPersonalization findById(TenantId tenantId, FlexPersonalizationId id) {
    foreach (p; find(tenantId))
      if (p.id_ == id) return p;
    return FlexPersonalization.init;
  }

  bool removeById(TenantId tenantId, FlexPersonalizationId id) {
    return remove(tenantId, id);
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) find(tenantId).length;
  }

  FlexPersonalization[] findByTenantAll(TenantId tenantId) {
    return find(tenantId);
  }

  FlexPersonalization[] findByUser(TenantId tenantId, string appId, string userId) {
    FlexPersonalization[] result;
    foreach (p; find(tenantId))
      if (p.appId_ == appId && p.userId_ == userId) result ~= p;
    return result;
  }

  FlexPersonalization findByControl(TenantId tenantId, string appId, string userId, string controlId) {
    foreach (p; find(tenantId))
      if (p.appId_ == appId && p.userId_ == userId && p.controlId_ == controlId) return p;
    return FlexPersonalization.init;
  }

  bool removeByUser(TenantId tenantId, string appId, string userId) {
    auto toRemove = findByUser(tenantId, appId, userId);
    foreach (p; toRemove) remove(tenantId, p.id_);
    return true;
  }
}
