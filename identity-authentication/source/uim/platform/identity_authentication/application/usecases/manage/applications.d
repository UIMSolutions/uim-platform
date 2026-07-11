/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.usecases.manage.applications;
// import uim.platform.identity_authentication.domain.entities.application;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.application;
// import uim.platform.identity_authentication.application.dto;
// 
// 
// 

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// Application use case: service provider / application registration.
class ManageApplicationsUseCase { // TODO: UIMUseCase {
  private ApplicationRepository appRepo;

  this(ApplicationRepository appRepo) {
    this.appRepo = appRepo;
  }

  AppResponse createApplication(CreateAppRequest req) {
    auto app = Application(req.tenantId);
    app.name = req.name;
    app.description = req.description;
    app.protocol = req.protocol;
    app.clientId = randomUUID().toString();
    app.clientSecret = randomUUID().toString();
    app.redirectUris = req.redirectUris;
    app.allowedScopes = req.allowedScopes;
    app.samlEntityId = req.samlEntityId;
    app.samlAcsUrl = req.samlAcsUrl;
    app.active = true;

    appRepo.save(app);
    return AppResponse(app.id, app.clientId, app.clientSecret, "");
  }

  Application getApplication(TenantId tenantId, ApplicationId id) {
    return appRepo.findById(tenantId, id);
  }

  Application[] listApplications(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return appRepo.findByTenant(tenantId, offset, limit);
  }

  CommandResult updateApplication(UpdateAppRequest req) {
    auto app = appRepo.findById(req.tenantId, req.applicationId);
    if (app.isNull)
      return CommandResult(false, "", "Application not found");

    if (req.name.length > 0)
      app.name = req.name;
    if (req.redirectUris.length > 0)
      app.redirectUris = req.redirectUris;
    if (req.allowedScopes.length > 0)
      app.allowedScopes = req.allowedScopes;

    app.updatedAt = currentTimestamp();

    appRepo.update(app);
    return CommandResult(true, app.id.value, "");
  }

  CommandResult deleteApplication(TenantId tenantId, ApplicationId id) {
    auto app = appRepo.findById(tenantId, id);
    if (app.isNull)      
      return CommandResult(false, "", "Application not found.");

    appRepo.remove(app);
    return CommandResult(true, app.id.value, "Application deleted successfully.");
  }
}
