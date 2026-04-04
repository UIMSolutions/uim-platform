/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.manage.applications;

import uim.platform.kyma.application.dto;
import uim.platform.kyma.domain.entities.application;
import uim.platform.kyma.domain.ports.application_repository;
import uim.platform.kyma.domain.types;

/// Application service for external application connectivity.
class ManageApplicationsUseCase
{
  private ApplicationRepository repo;

  this(ApplicationRepository repo)
  {
    this.repo = repo;
  }

  CommandResult register(RegisterApplicationRequest req)
  {
    if (req.name.length == 0)
      return CommandResult(false, "", "Application name is required");
    if (req.environmentId.length == 0)
      return CommandResult(false, "", "Environment ID is required");

    auto existing = repo.findByName(req.environmentId, req.name);
    if (existing.id.length > 0)
      return CommandResult(false, "", "Application '" ~ req.name ~ "' is already registered");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    Application app;
    app.id = id;
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
    foreach (ref a; req.apis)
    {
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
    foreach (ref e; req.events)
    {
      AppEventEntry entry;
      entry.name = e.name;
      entry.description = e.description;
      entry.version_ = e.version_;
      events ~= entry;
    }
    app.events = events;

    repo.save(app);
    return CommandResult(true, id, "");
  }

  CommandResult updateApplication(ApplicationId id, UpdateApplicationRequest req)
  {
    auto app = repo.findById(id);
    if (app.id.length == 0)
      return CommandResult(false, "", "Application not found");

    if (req.description.length > 0)
      app.description = req.description;
    if (req.connectorUrl.length > 0)
      app.connectorUrl = req.connectorUrl;
    if (req.boundNamespaces.length > 0)
      app.boundNamespaces = req.boundNamespaces;
    if (req.labels !is null)
      app.labels = req.labels;

    if (req.apis.length > 0)
    {
      AppApiEntry[] apis;
      foreach (ref a; req.apis)
      {
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

    if (req.events.length > 0)
    {
      AppEventEntry[] events;
      foreach (ref e; req.events)
      {
        AppEventEntry entry;
        entry.name = e.name;
        entry.description = e.description;
        entry.version_ = e.version_;
        events ~= entry;
      }
      app.events = events;
    }

    app.modifiedAt = clockSeconds();
    repo.update(app);
    return CommandResult(true, id, "");
  }

  CommandResult connectApplication(ApplicationId id)
  {
    auto app = repo.findById(id);
    if (app.id.length == 0)
      return CommandResult(false, "", "Application not found");
    app.status = AppConnectivityStatus.connected;
    app.modifiedAt = clockSeconds();
    repo.update(app);
    return CommandResult(true, id, "");
  }

  CommandResult disconnectApplication(ApplicationId id)
  {
    auto app = repo.findById(id);
    if (app.id.length == 0)
      return CommandResult(false, "", "Application not found");
    app.status = AppConnectivityStatus.disconnected;
    app.modifiedAt = clockSeconds();
    repo.update(app);
    return CommandResult(true, id, "");
  }

  Application getApplication(ApplicationId id)
  {
    return repo.findById(id);
  }

  Application[] listByEnvironment(KymaEnvironmentId envId)
  {
    return repo.findByEnvironment(envId);
  }

  Application[] listByTenant(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  CommandResult deleteApplication(ApplicationId id)
  {
    auto app = repo.findById(id);
    if (app.id.length == 0)
      return CommandResult(false, "", "Application not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private AppRegistrationType parseRegistrationType(string s)
  {
    switch (s)
    {
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

private long clockSeconds()
{
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 10_000_000;
}
