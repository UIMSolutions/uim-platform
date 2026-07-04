/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.ports.repositories.flex_drafts;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

interface FlexDraftRepository : ITenantRepository!(FlexDraft, FlexDraftId) {
  bool existsById(TenantId tenantId, FlexDraftId id);
  FlexDraft findById(TenantId tenantId, FlexDraftId id);
  bool removeById(TenantId tenantId, FlexDraftId id);
  long countByTenant(TenantId tenantId);
  FlexDraft[] findByTenantAll(TenantId tenantId);

  /// Find the active draft for an application (at most one per tenant+app)
  FlexDraft findByApp(TenantId tenantId, string appId);

  /// Check if an active draft exists for an app
  bool hasDraft(TenantId tenantId, string appId);
}
