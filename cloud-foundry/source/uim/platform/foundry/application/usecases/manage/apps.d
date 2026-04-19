/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.apps;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.application;

// import uim.platform.foundry.domain.ports.repositories.app;
import uim.platform.foundry.domain.ports;
import uim.platform.foundry.domain.services.app_lifecycle_manager;
import uim.platform.foundry.application.dto;

class ManageAppsUseCase { // TODO: UIMUseCase {
  private AppRepository repo;
  private AppLifecycleManager lifecycle;

  this(AppRepository repo, AppLifecycleManager lifecycle) {
    this.repo = repo;
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
    auto existing = repo.findByName(req.spaceId, req.tenantId, req.name);
    if (existing !is null)
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

    repo.save(app);
    return CommandResult(app.id, "");
  }

  Application* getApp(AppId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Application[] listApps(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Application[] listBySpace(SpaceId spacetenantId, id tenantId) {
    return repo.findBySpace(spacetenantId, id);
  }

  CommandResult updateApp(UpdateAppRequest req) {
    if (req.id.isEmpty)
      return CommandResult(false, "", "Application ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult(false, "", "Application not found");

    auto updated = *existing;
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

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  /// Start an application (stage then start).
  CommandResult startApp(TenantId tenantId, AppId id) {
    auto app = repo.findById(tenantId, id);
    if (app is null)
      return CommandResult(false, "", "Application not found");
    if (app.state == AppState.started)
      return CommandResult(false, "", "Application is already started");

    lifecycle.stageApp(tenantId, id);
    if (!lifecycle.startApp(tenantId, id))
      return CommandResult(false, "", "Failed to start application");

    return CommandResult(true, id.toString, "");
  }

  CommandResult stopApp(TenantId tenantId, AppId id) {
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
    if (req.id.isEmpty)
      return CommandResult(false, "", "Application ID is required");

    if (!lifecycle.scaleApp(req.id, req.tenantId, req.instances, req.memoryMb, req.diskMb))
      return CommandResult(false, "", "Cannot scale application — check quota limits");
    return CommandResult(req.id, "");
  }

  /// Get environment variables for an application.
  string getEnvironment(TenantId tenantId, AppId id) {
    auto app = repo.findById(tenantId, id);
    if (app is null)
      return "{}";
    return app.environmentVariables.length > 0 ? app.environmentVariables : "{}";
  }

  /// Set environment variables for an application.
  CommandResult setEnvironment(TenantId tenantId, AppId id, string envJson) {
    if (!repo.existsById(tenantId, id))
      return CommandResult(false, "", "Application not found");

    auto app = repo.findById(tenantId, id);
    app.environmentVariables = envJson;
    app.updatedAt = Clock.currStdTime();
    repo.update(app);
    return CommandResult(true, app.id.toString, "");
  }

  CommandResult deleteApp(TenantId tenantId, AppId appId) {
    if (!repo.existsById(tenantId, appId))
      return CommandResult(false, "", "Application not found");

    repo.remove(tenantId, appId);
    return CommandResult(true, appId.toString, "");
  }
}
