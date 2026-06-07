/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.application.usecases.manage.flex_versions;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

class ManageFlexVersionsUseCase {
  private FlexVersionRepository repo;

  this(FlexVersionRepository repo) {
    this.repo = repo;
  }

  CommandResult createVersion(CreateFlexVersionRequest r) {
    auto v = FlexVersion();
    v.id_ = r.versionId;
    v.tenant_ = r.tenantId;
    v.appId_ = r.appId;
    v.displayName_ = r.displayName_;
    v.description_ = r.description_;
    v.activatedBy_ = r.activatedBy_;
    v.activatedAt_ = "";
    v.status_ = VersionStatus.draft_;
    v.changeIds_ = r.changeIds_.dup;
    v.changeCount_ = cast(long)r.changeIds_.length;

    auto err = FlexValidator.validateFlexVersion(v);
    if (err !is null)
      return CommandResult(false, null, err);

    repo.save(r.tenantId, v);
    return CommandResult(true, v.id_.value);
  }

  CommandResult activateVersion(ActivateVersionRequest r) {
    auto v = repo.findById(r.tenantId, r.versionId);
    if (v.isNull)
      return CommandResult(false, null, "FlexVersion not found");

    // Archive currently active version for this app
    auto current = repo.findActiveByApp(r.tenantId, r.appId);
    if (!current.isNull) {
      current.status_ = VersionStatus.archived_;
      repo.update(r.tenantId, current);
    }

    v.status_ = VersionStatus.active_;
    v.activatedBy_ = r.activatedBy_;
    v.activatedAt_ = ""; // Caller fills with ISO timestamp

    repo.update(r.tenantId, v);
    return CommandResult(true, v.id_.value, "FlexVersion activated successfully.");
  }

  CommandResult updateVersion(UpdateFlexVersionRequest r) {
    auto v = repo.findById(r.tenantId, r.versionId);
    if (v.isNull)
      return CommandResult(false, null, "FlexVersion not found");

    v.displayName_ = r.displayName_;
    v.description_ = r.description_;
    v.status_ = r.status_;
    repo.update(r.tenantId, v);
    return CommandResult(true, v.id_.value, "FlexVersion updated successfully.");
  }

  FlexVersion getVersion(TenantId tenantId, FlexVersionId id) {
    return repo.findById(tenantId, id);
  }

  FlexVersion[] listVersions(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  FlexVersion[] listVersionsByApp(TenantId tenantId, string appId) {
    return repo.findByApp(tenantId, appId);
  }

  FlexVersion getActiveVersion(TenantId tenantId, string appId) {
    return repo.findActiveByApp(tenantId, appId);
  }

  CommandResult deleteVersion(TenantId tenantId, FlexVersionId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, null, "FlexVersion not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, existing.id_.value, "FlexVersion deleted successfully.");
  }
}
