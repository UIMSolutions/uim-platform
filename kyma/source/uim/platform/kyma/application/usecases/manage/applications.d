/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.applications;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.application;
// import uim.platform.kyma.domain.ports.repositories.applications;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for external application connectivity.
class ManageApplicationsUseCase { // TODO: UIMUseCase {
  private ApplicationRepository appRepository;

  this(ApplicationRepository appRepository) {
    this.appRepository = appRepository;
  }

  CommandResult register(RegisterApplicationRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Application name is required");
    if (req.environmentId.isEmpty)
      return CommandResult(false, "", "Environment ID is required");

    auto existing = appRepository.findByName(req.environmentId, req.name);
    if (existing.isNull)
      return CommandResult(false, "", "Application '" ~ req.name ~ "' is already registered");

    Application app;
    app.initEntity(req.tenantId, req.createdBy);
    with(app) {
      environmentId = req.environmentId;
      name = req.name;
      description = req.description;
      status = AppConnectivityStatus.pairing;
      registrationType = parseRegistrationType(req.registrationType);
      connectorUrl = req.connectorUrl;
      boundNamespaces = req.boundNamespaces;
      labels = req.labels;
    }

    // Convert API entries
    AppApiEntry[] apis;
    foreach (a; req.apis) {
      AppApiEntry entry;
      with(entry) {
        name = a.name;
        description = a.description;
        targetUrl = a.targetUrl;
        specUrl = a.specUrl;
        authType = a.authType;
      }
      apis ~= entry;
    }
    app.apis = apis;

    // Convert event entries
    AppEventEntry[] events;
    foreach (e; req.events) {
      AppEventEntry entry;
      with(entry) {
        name = e.name;
        description = e.description;
        version_ = e.version_;
      }
      events ~= entry;
    }
    app.events = events;

    appRepository.save(app);
    return CommandResult(true, app.id.value, "");
  }

  CommandResult updateApplication(string appId, UpdateApplicationRequest req) {
    return updateApplication(ApplicationId(appId), req);
  }

  CommandResult updateApplication(TenantId tenantId, ApplicationId appId, UpdateApplicationRequest req) {
    if (!appRepository.existsById(tenantId, appId))
      return CommandResult(false, "", "Application not found");

    auto app = appRepository.findById(tenantId, appId);
    if (req.description.length > 0)
      app.description = req.description;
    if (req.connectorUrl.length > 0)
      app.connectorUrl = req.connectorUrl;
    if (req.boundNamespaces.length > 0)
      app.boundNamespaces = req.boundNamespaces;
    if (req.labels !is null)
      app.labels = req.labels;

    if (req.apis.length > 0) {
      AppApiEntry[] apis;
      foreach (a; req.apis) {
        AppApiEntry entry;
        entry.name = a.name;
        entry.description = a.description;
        entry.targetUrl = a.targetUrl;
        entry.specUrl = a.specUrl;
        entry.authType = a.authType;
        apis ~= entry;
      }
      app.apis = apis;
    }

    if (req.events.length > 0) {
      AppEventEntry[] events;
      foreach (e; req.events) {
        AppEventEntry entry;
        entry.name = e.name;
        entry.description = e.description;
        entry.version_ = e.version_;
        events ~= entry;
      }
      app.events = events;
    }

    app.updatedAt = clockSeconds();
    appRepository.update(app);
    return CommandResult(true, app.id.value, "");
  }

  CommandResult connectApplication(TenantId tenantId, ApplicationId appId) {
    auto app = appRepository.findById(tenantId, appId);
    if (app.isNull)
      return CommandResult(false, "", "Application not found");

    app.status = AppConnectivityStatus.connected;
    app.updatedAt = clockSeconds();
    appRepository.update(app);
    return CommandResult(true, app.id.value, "");
  }

  CommandResult disconnectApplication(TenantId tenantId, ApplicationId appId) {
    if (!appRepository.existsById(tenantId, appId))
      return CommandResult(false, "", "Application not found");

    auto app = appRepository.findById(tenantId, appId);
    app.status = AppConnectivityStatus.disconnected;
    app.updatedAt = clockSeconds();
    
    appRepository.update(app);
    return CommandResult(true, app.id.value, "");
  }

  bool hasApplication(TenantId tenantId, ApplicationId appId) {
    return appRepository.existsById(tenantId, appId);
  }

  Application getApplication(TenantId tenantId, ApplicationId appId) {
    return appRepository.findById(tenantId, appId);
  }

  Application[] listByEnvironment(TenantId tenantId, KymaEnvironmentId envId) {
    return appRepository.findByEnvironment(tenantId, envId);
  }

  Application[] listByTenant(TenantId tenantId) {
    return appRepository.findByTenant(tenantId);
  }

  CommandResult deleteApplication(TenantId tenantId, string appId) {
    return deleteApplication(tenantId, ApplicationId(appId));
  }

  CommandResult deleteApplication(TenantId tenantId, ApplicationId appId) {
    auto app = appRepository.findById(tenantId, appId);
    if (app.isNull)
      return CommandResult(false, "", "Application not found");

    appRepository.remove(app);
    return CommandResult(true, app.id.value, "");
  }
}


