/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.persistence.memory.flex_drafts;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

class MemoryFlexDraftRepository : TentRepository!(FlexDraft, FlexDraftId), FlexDraftRepository {

  bool existsById(TenantId tenantId, FlexDraftId id) {
    return !findById(tenantId, id).isNull;
  }

  FlexDraft findById(TenantId tenantId, FlexDraftId id) {
    foreach (d; findByTenant(tenantId))
      if (d.id_ == id) return d;
    return FlexDraft.init;
  }

  bool removeById(TenantId tenantId, FlexDraftId id) {
    return remove(tenantId, id);
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) findByTenant(tenantId).length;
  }

  FlexDraft[] findByTenantAll(TenantId tenantId) {
    return findByTenant(tenantId);
  }

  FlexDraft findByApp(TenantId tenantId, string appId) {
    foreach (d; findByTenant(tenantId))
      if (d.appId_ == appId) return d;
    return FlexDraft.init;
  }

  bool hasDraft(TenantId tenantId, string appId) {
    foreach (d; findByTenant(tenantId))
      if (d.appId_ == appId) return true;
    return false;
  }
}
