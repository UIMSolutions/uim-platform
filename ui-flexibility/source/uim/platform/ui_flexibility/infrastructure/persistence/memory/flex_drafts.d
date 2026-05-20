/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.infrastructure.persistence.memory.flex_drafts;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

class MemoryFlexDraftRepository : TenantRepository!(FlexDraft, FlexDraftId), FlexDraftRepository {

  bool existsById(string tenantId, FlexDraftId id) {
    return !findById(tenantId, id).isNull;
  }

  FlexDraft findById(string tenantId, FlexDraftId id) {
    foreach (d; findByTenant(tenantId))
      if (d.id_ == id) return d;
    return FlexDraft.init;
  }

  bool removeById(string tenantId, FlexDraftId id) {
    return remove(tenantId, id);
  }

  long countByTenant(string tenantId) {
    return cast(long) findByTenant(tenantId).length;
  }

  FlexDraft[] findByTenantAll(string tenantId) {
    return findByTenant(tenantId);
  }

  FlexDraft findByApp(string tenantId, string appId) {
    foreach (d; findByTenant(tenantId))
      if (d.appId_ == appId) return d;
    return FlexDraft.init;
  }

  bool hasDraft(string tenantId, string appId) {
    foreach (d; findByTenant(tenantId))
      if (d.appId_ == appId) return true;
    return false;
  }
}
