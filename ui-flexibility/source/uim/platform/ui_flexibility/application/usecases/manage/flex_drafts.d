/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.application.usecases.manage.flex_drafts;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

class ManageFlexDraftsUseCase {
  private FlexDraftRepository repo;

  this(FlexDraftRepository repo) {
    this.repo = repo;
  }

  CommandResult createDraft(CreateFlexDraftRequest r) {
    // Only one draft per app per tenant
    if (repo.hasDraft(r.tenantId, r.appId))
      return CommandResult(false, null, "An active draft already exists for this application");

    auto d = FlexDraft();
    d.id_            = r.draftId;
    d.tenant_        = r.tenantId;
    d.appId_         = r.appId;
    d.updatedBy_     = r.updatedBy_;
    d.updatedAt_     = "";
    d.baseVersionId_ = r.baseVersionId_;
    d.changeIds_     = [];
    d.changeCount_   = 0;

    auto err = FlexValidator.validateFlexDraft(d);
    if (err !is null) return CommandResult(false, null, err);

    repo.save(r.tenantId, d);
    return CommandResult(true, d.id_.value);
  }

  CommandResult updateDraft(UpdateFlexDraftRequest r) {
    auto d = repo.find(r.tenantId, r.draftId);
    if (d.isNull) return CommandResult(false, null, "FlexDraft not found");
    d.changeIds_   = r.changeIds_.dup;
    d.changeCount_ = cast(long) r.changeIds_.length;
    d.updatedBy_   = r.updatedBy_;
    d.updatedAt_   = "";
    repo.update(r.tenantId, d);
    return CommandResult(true, d.id_.value);
  }

  FlexDraft getDraft(TenantId tenantId, FlexDraftId id) {
    return repo.findById(tenantId, id);
  }

  FlexDraft getDraftByApp(TenantId tenantId, string appId) {
    return repo.findByApp(tenantId, appId);
  }

  FlexDraft[] listDrafts(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  CommandResult discardDraft(TenantId tenantId, FlexDraftId id) {
    auto draft = repo.findById(tenantId, id);
    if (draft.isNull)
      return CommandResult(false, null, "FlexDraft not found");

    repo.remove(draft);
    return CommandResult(true, draft.id.value);
  }
}
