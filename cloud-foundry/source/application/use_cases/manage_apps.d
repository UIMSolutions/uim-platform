module application.use_cases.manage_apps;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.application;
import domain.ports.app_repository;
import domain.services.app_lifecycle_manager;
import application.dto;

class ManageAppsUseCase
{
  private AppRepository repo;
  private AppLifecycleManager lifecycle;

  this(AppRepository repo, AppLifecycleManager lifecycle)
  {
    this.repo = repo;
    this.lifecycle = lifecycle;
  }

  CommandResult createApp(CreateAppRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.spaceId.length == 0)
      return CommandResult("", "Space ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Application name is required");

    // Unique name within space
    auto existing = repo.findByName(req.spaceId, req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Application with this name already exists in space");

    auto now = Clock.currStdTime();
    auto app = Application();
    app.id = randomUUID().toString();
    app.spaceId = req.spaceId;
    app.tenantId = req.tenantId;
    app.name = req.name;
    app.state = AppState.stopped;
    app.instances = req.instances > 0 ? req.instances : 1;
    app.memoryMb = req.memoryMb > 0 ? req.memoryMb : 256;
    app.diskMb = req.diskMb > 0 ? req.diskMb : 1024;
    app.buildpackId = req.buildpackId;
    app.stack = req.stack.length > 0 ? req.stack : "cflinuxfs4";
    app.command = req.command;
    app.healthCheckType = req.healthCheckType;
    app.healthCheckEndpoint = req.healthCheckEndpoint.length > 0 ? req.healthCheckEndpoint : "/";
    app.healthCheckTimeoutSec = req.healthCheckTimeoutSec > 0 ? req.healthCheckTimeoutSec : 60;
    app.environmentVariables = req.environmentVariables;
    app.dockerImage = req.dockerImage;
    app.createdBy = req.createdBy;
    app.createdAt = now;
    app.updatedAt = now;

    repo.save(app);
    return CommandResult(app.id, "");
  }

  Application* getApp(AppId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  Application[] listApps(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  Application[] listBySpace(SpaceId spaceId, TenantId tenantId)
  {
    return repo.findBySpace(spaceId, tenantId);
  }

  CommandResult updateApp(UpdateAppRequest req)
  {
    if (req.id.length == 0)
      return CommandResult("", "Application ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Application not found");

    auto updated = *existing;
    if (req.name.length > 0) updated.name = req.name;
    if (req.instances > 0) updated.instances = req.instances;
    if (req.memoryMb > 0) updated.memoryMb = req.memoryMb;
    if (req.diskMb > 0) updated.diskMb = req.diskMb;
    if (req.buildpackId.length > 0) updated.buildpackId = req.buildpackId;
    if (req.stack.length > 0) updated.stack = req.stack;
    if (req.command.length > 0) updated.command = req.command;
    updated.healthCheckType = req.healthCheckType;
    if (req.healthCheckEndpoint.length > 0) updated.healthCheckEndpoint = req.healthCheckEndpoint;
    if (req.healthCheckTimeoutSec > 0) updated.healthCheckTimeoutSec = req.healthCheckTimeoutSec;
    if (req.environmentVariables.length > 0) updated.environmentVariables = req.environmentVariables;
    if (req.dockerImage.length > 0) updated.dockerImage = req.dockerImage;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  /// Start an application (stage then start).
  CommandResult startApp(AppId id, TenantId tenantId)
  {
    auto app = repo.findById(id, tenantId);
    if (app is null)
      return CommandResult("", "Application not found");
    if (app.state == AppState.started)
      return CommandResult("", "Application is already started");

    lifecycle.stageApp(id, tenantId);
    if (!lifecycle.startApp(id, tenantId))
      return CommandResult("", "Failed to start application");

    return CommandResult(id, "");
  }

  CommandResult stopApp(AppId id, TenantId tenantId)
  {
    if (!lifecycle.stopApp(id, tenantId))
      return CommandResult("", "Cannot stop application");
    return CommandResult(id, "");
  }

  CommandResult restartApp(AppId id, TenantId tenantId)
  {
    if (!lifecycle.restartApp(id, tenantId))
      return CommandResult("", "Cannot restart application");
    return CommandResult(id, "");
  }

  CommandResult scaleApp(ScaleAppRequest req)
  {
    if (req.id.length == 0)
      return CommandResult("", "Application ID is required");

    if (!lifecycle.scaleApp(req.id, req.tenantId, req.instances, req.memoryMb, req.diskMb))
      return CommandResult("", "Cannot scale application — check quota limits");
    return CommandResult(req.id, "");
  }

  /// Get environment variables for an application.
  string getEnvironment(AppId id, TenantId tenantId)
  {
    auto app = repo.findById(id, tenantId);
    if (app is null)
      return "{}";
    return app.environmentVariables.length > 0 ? app.environmentVariables : "{}";
  }

  /// Set environment variables for an application.
  CommandResult setEnvironment(AppId id, TenantId tenantId, string envJson)
  {
    auto app = repo.findById(id, tenantId);
    if (app is null)
      return CommandResult("", "Application not found");

    app.environmentVariables = envJson;
    app.updatedAt = Clock.currStdTime();
    repo.update(*app);
    return CommandResult(id, "");
  }

  CommandResult deleteApp(AppId id, TenantId tenantId)
  {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Application not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
