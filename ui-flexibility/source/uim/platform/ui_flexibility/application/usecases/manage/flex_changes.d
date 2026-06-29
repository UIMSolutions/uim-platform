/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.application.usecases.manage.flex_changes;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

class ManageFlexChangesUseCase {
  private FlexChangeRepository repo;

  this(FlexChangeRepository repo) {
    this.repo = repo;
  }

  CommandResult createChange(CreateFlexChangeRequest r) {
    auto c = FlexChange();
    c.id_ = r.changeId;
    c.tenant_ = r.tenantId;
    c.appId_ = r.appId;
    c.namespace_ = r.namespace_;
    c.layer_ = r.layer_;
    c.changeType_ = r.changeType_;
    c.selector_ = r.selector_;
    c.content_ = r.content_;
    c.reference_ = r.reference_;
    c.support_ = r.support_;
    c.dependentSelector_ = r.dependentSelector_;
    c.createdBy_ = r.createdBy_;
    c.updatedBy_ = r.createdBy_;
    c.isActive_ = true;
    c.createdAtTicks_ = MonoTime.currTime.ticks;
    c.updatedAtTicks_ = c.createdAtTicks_;

    auto err = FlexValidator.validateFlexChange(c);
    if (err !is null)
      return CommandResult(false, null, err);

    repo.save(r.tenantId, c);
    return CommandResult(true, c.id_.value, "FlexChange created successfully.");
  }

  CommandResult updateChange(UpdateFlexChangeRequest r) {
    auto existing = repo.findById(r.tenantId, r.changeId);
    if (existing.isNull)
      return CommandResult(false, null, "FlexChange not found");
    existing.selector_ = r.selector_;
    existing.content_ = r.content_;
    existing.reference_ = r.reference_;
    existing.updatedBy_ = r.updatedBy_;
    existing.isActive_ = r.isActive_;
    existing.updatedAtTicks_ = MonoTime.currTime.ticks;
    repo.update(r.tenantId, existing);
    return CommandResult(true, existing.id_.value, "FlexChange updated successfully.");
  }

  FlexChange getChange(TenantId tenantId, FlexChangeId id) {
    return repo.findById(tenantId, id);
  }

  FlexChange[] listChanges(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  FlexChange[] listChangesByApp(TenantId tenantId, string appId) {
    return repo.findByApp(tenantId, appId);
  }

  FlexChange[] listChangesByLayer(TenantId tenantId, string appId, ChangeLayer layer) {
    return repo.findByLayer(tenantId, appId, layer);
  }

  CommandResult deleteChange(TenantId tenantId, FlexChangeId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, null, "FlexChange not found");

    repo.remove(existing);
    return CommandResult(true, existing.id_.value, "FlexChange deleted successfully.");
  }

  long countChanges(TenantId tenantId) {
    return repo.count(tenantId);
  }
}
