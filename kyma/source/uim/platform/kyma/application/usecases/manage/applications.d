/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.applications;

// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.application;
// import uim.platform.kyma.domain.ports.repositories.applications;
// import uim.platform.kyma.domain.types;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for external application connectivity.
class ManageApplicationsUseCase : UIMUseCase {
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
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Application '" ~ req.name ~ "' is already registered");

    Application app;
    app.id = randomUUID();
    app.environmentId = req.environmentId;
    app.tenantId = req.tenantId;
    app.name = req.name;
    app.description = req.description;
    app.status = AppConnectivityStatus.pairing;
    app.registrationType = parseRegistrationType(req.registrationType);
    app.connectorUrl = req.connectorUrl;
    app.boundNamespaces = req.boundNamespaces;
    app.labels = req.labels;
    app.createdBy = req.createdBy;
    app.createdAt = clockSeconds();
    app.modifiedAt = app.createdAt;

    // Convert API entries
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

    // Convert event entries
    AppEventEntry[] events;
    foreach (e; req.events) {
      AppEventEntry entry;
      entry.name = e.name;
      entry.description = e.description;
      entry.version_ = e.version_;
      events ~= entry;
    }
    app.events = events;

    appRepository.save(app);
    return CommandResult(true, id.toString, "");
  }

  CommandResult updateApplication(string appId, UpdateApplicationRequest req) {
    return updateApplication(ApplicationId(appId), req);
  }

  CommandResult updateApplication(ApplicationId appId, UpdateApplicationRequest req) {
    if (!appRepository.existsById(appId))
      return CommandResult(false, "", "Application not found");

    auto app = appRepository.findById(appId);
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

    app.modifiedAt = clockSeconds();
    appRepository.update(app);
    return CommandResult(true, appId.toString(), "");
  }

  CommandResult connectApplication(string appId) {
    return connectApplication(ApplicationId(appId));
  }

  CommandResult connectApplication(ApplicationId appId) {
    if (!appRepository.existsById(appId))
      return CommandResult(false, "", "Application not found");

    auto app = appRepository.findById(appId);
    app.status = AppConnectivityStatus.connected;
    app.modifiedAt = clockSeconds();
    appRepository.update(app);
    return CommandResult(true, appId.toString(), "");
  }

  CommandResult disconnectApplication(string appId) {
    return disconnectApplication(ApplicationId(appId));
  }

  CommandResult disconnectApplication(ApplicationId appId) {
    if (!appRepository.existsById(appId))
      return CommandResult(false, "", "Application not found");

    auto app = appRepository.findById(appId);
    app.status = AppConnectivityStatus.disconnected;
    app.modifiedAt = clockSeconds();
    appRepository.update(app);
    return CommandResult(true, appId.toString(), "");
  }

  Application getApplication(string appId) {
    return getApplication(ApplicationId(appId));
  }

  Application getApplication(ApplicationId appId) {
    return appRepository.findById(appId);
  }

  Application[] listByEnvironment(KymaEnvironmentId envId) {
    return appRepository.findByEnvironment(envId);
  }

  Application[] listByTenant(TenantId tenantId) {
    return appRepository.findByTenant(tenantId);
  }

  CommandResult deleteApplication(string appId) {
    return deleteApplication(ApplicationId(appId));
  }

  CommandResult deleteApplication(ApplicationId appId) {
    if (!appRepository.existsById(appId))
      return CommandResult(false, "", "Application not found");

    auto app = appRepository.findById(appId);
    appRepository.remove(appId);
    return CommandResult(true, appId.toString(), "");
  }

  private AppRegistrationType parseRegistrationType(string type) {
    switch (type) {
    case "api":
      return AppRegistrationType.api;
    case "events":
      return AppRegistrationType.events;
    case "apiAndEvents":
      return AppRegistrationType.apiAndEvents;
    default:
      return AppRegistrationType.apiAndEvents;
    }
  }
}


