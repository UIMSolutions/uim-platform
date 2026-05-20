/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.application.usecases.manage.flex_applications;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

class ManageFlexApplicationsUseCase {
  private FlexApplicationRepository repo;

  this(FlexApplicationRepository repo) {
    this.repo = repo;
  }

  CommandResult createApplication(CreateFlexApplicationRequest r) {
    auto a = FlexApplication();
    a.id_          = r.applicationId;
    a.tenant_      = r.tenantId;
    a.namespace_   = r.namespace_;
    a.appId_       = r.appId;
    a.description_ = r.description_;
    a.isActive_    = r.isActive_;
    a.validFrom_   = r.validFrom_;
    a.validTo_     = r.validTo_;
    a.owner_       = r.owner_;
    a.version_     = r.version_;

    auto err = FlexValidator.validateFlexApplication(a);
    if (err !is null) return CommandResult(false, null, err);

    repo.save(r.tenantId, a);
    return CommandResult(true, a.id_.value);
  }

  CommandResult updateApplication(UpdateFlexApplicationRequest r) {
    auto a = repo.findById(r.tenantId, r.applicationId);
    if (a.isNull) return CommandResult(false, null, "FlexApplication not found");
    a.description_ = r.description_;
    a.isActive_    = r.isActive_;
    a.validFrom_   = r.validFrom_;
    a.validTo_     = r.validTo_;
    a.owner_       = r.owner_;
    a.version_     = r.version_;
    repo.update(r.tenantId, a);
    return CommandResult(true, a.id_.value);
  }

  FlexApplication getApplication(string tenantId, FlexApplicationId id) {
    return repo.findById(tenantId, id);
  }

  FlexApplication getApplicationByAppId(string tenantId, string appId) {
    return repo.findByAppId(tenantId, appId);
  }

  FlexApplication[] listApplications(string tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  FlexApplication[] listActiveApplications(string tenantId) {
    return repo.findActiveByTenant(tenantId);
  }

  CommandResult deleteApplication(string tenantId, FlexApplicationId id) {
    if (!repo.existsById(tenantId, id)) return CommandResult(false, null, "FlexApplication not found");
    repo.removeById(tenantId, id);
    return CommandResult(true, id.value);
  }
}
