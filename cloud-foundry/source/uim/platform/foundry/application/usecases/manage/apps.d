/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.apps;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.application;

// // import uim.platform.foundry.domain.ports.repositories.app;
// import uim.platform.foundry.domain.ports;
// import uim.platform.foundry.domain.services.app_lifecycle_manager;
// import uim.platform.foundry.application.dto;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class ManageAppsUseCase { // TODO: UIMUseCase {
  private IAppRepository apps;
  private AppLifecycleManager lifecycle;

  this(IAppRepository apps, AppLifecycleManager lifecycle) {
    this.apps = apps;
    this.lifecycle = lifecycle;
  }

  CommandResult createApp(CreateAppRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Application name is required");

    // Unique name within space
    if (apps.existsByName(req.tenantId, req.spaceId, req.name))
      return CommandResult(false, "", "Application with this name already exists in space");

    auto now = Clock.currStdTime();
    auto app = Application();
    app.id = randomUUID();
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

    apps.save(app);
    return CommandResult(true, app.id.toString, "");
  }

  Application getApp(TenantId tenantId, AppId id) {
    return apps.findById(tenantId, id);
  }

  Application[] listApps(TenantId tenantId) {
    return apps.findByTenant(tenantId);
  }

  Application[] listBySpace(TenantId tenantId, SpaceId spaceId) {
    return apps.findBySpace(tenantId, spaceId);
  }

  CommandResult updateApp(UpdateAppRequest req) {
    if (req.isNull)
      return CommandResult(false, "", "Application ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = apps.findById(req.tenantId, req.id);
    if (existing.isNull)
      return CommandResult(false, "", "Application not found");

    auto updated = existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.instances > 0)
      updated.instances = req.instances;
    if (req.memoryMb > 0)
      updated.memoryMb = req.memoryMb;
    if (req.diskMb > 0)
      updated.diskMb = req.diskMb;
    if (req.buildpackId.length > 0)
      updated.buildpackId = req.buildpackId;
    if (req.stack.length > 0)
      updated.stack = req.stack;
    if (req.command.length > 0)
      updated.command = req.command;
    updated.healthCheckType = req.healthCheckType;
    if (req.healthCheckEndpoint.length > 0)
      updated.healthCheckEndpoint = req.healthCheckEndpoint;
    if (req.healthCheckTimeoutSec > 0)
      updated.healthCheckTimeoutSec = req.healthCheckTimeoutSec;
    if (req.environmentVariables.length > 0)
      updated.environmentVariables = req.environmentVariables;
    if (req.dockerImage.length > 0)
      updated.dockerImage = req.dockerImage;
    updated.updatedAt = Clock.currStdTime();

    apps.update(updated);
    return CommandResult(true, updated.id.toString, "");
  }

  /// Start an application (stage then start).
  CommandResult startApp(TenantId tenantId, AppId id) {
    auto app = apps.findById(tenantId, id);
    if (app.isNull)
      return CommandResult(false, "", "Application not found");
    if (app.state == AppState.started)
      return CommandResult(false, "", "Application is already started");

    lifecycle.stageApp(tenantId, id);
    if (!lifecycle.startApp(tenantId, id))
      return CommandResult(false, "", "Failed to start application");

    return CommandResult(true, id.toString, "");
  }

  CommandResult stopApp(TenantId tenantId, AppId id) {
    auto app = apps.findById(tenantId, id);
    if (app.isNull)
      return CommandResult(false, "", "Application not found");
    if (app.state == AppState.stopped)
      return CommandResult(false, "", "Application is already stopped");

    if (!lifecycle.stopApp(tenantId, id))
      return CommandResult(false, "", "Cannot stop application");
    return CommandResult(true, id.toString, "");
  }

  CommandResult restartApp(TenantId tenantId, AppId id) {
    if (!lifecycle.restartApp(tenantId, id))
      return CommandResult(false, "", "Cannot restart application");
    return CommandResult(true, id.toString, "");
  }

  CommandResult scaleApp(ScaleAppRequest req) {
    if (req.isNull)
      return CommandResult(false, "", "Application ID is required");

    if (!lifecycle.scaleApp(req.tenantId, req.id, req.instances, req.memoryMb, req.diskMb))
      return CommandResult(false, "", "Cannot scale application — check quota limits");
    return CommandResult(true, req.id.toString, "");
  }

  /// Get environment variables for an application.
  string getEnvironment(TenantId tenantId, AppId id) {
    auto app = apps.findById(tenantId, id);
    if (app.isNull)
      return "{}";
    return app.environmentVariables.length > 0 ? app.environmentVariables : "{}";
  }

  /// Set environment variables for an application.
  CommandResult setEnvironment(TenantId tenantId, AppId id, string envJson) {
    if (!apps.existsById(tenantId, id))
      return CommandResult(false, "", "Application not found");

    auto app = apps.findById(tenantId, id);
    app.environmentVariables = envJson;
    app.updatedAt = Clock.currStdTime();
    apps.update(app);
   
    return CommandResult(true, app.id.toString, "");
  }

  CommandResult deleteApp(TenantId tenantId, AppId appId) {
    auto app = apps.findById(tenantId, appId);
    if (app.isNull)
      return CommandResult(false, "", "Application not found");

    apps.remove(app);
    return CommandResult(true, app.id.toString, "");
  }
}
