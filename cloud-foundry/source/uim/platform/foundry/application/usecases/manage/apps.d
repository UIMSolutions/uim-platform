/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.manage.apps;





// import uim.platform.foundry.domain.services.app_lifecycle_manager;
// import uim.platform.foundry.application.dto;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class ManageAppsUseCase {
  protected IAppRepository apps;
  private AppLifecycleManager lifecycle;

  this(IAppRepository apps, AppLifecycleManager lifecycle) {
    this.apps = apps;
    this.lifecycle = lifecycle;
  }

  UsecaseResult createApp(CreateAppRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.spaceId.isEmpty)
      return UsecaseResult(false, "", "Space ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Application name is required");

    // Unique name within space
    if (apps.existsByName(req.tenantId, req.spaceId, req.name))
      return UsecaseResult(false, "", "Application with this name already exists in space");

    auto now = currentTimestamp();
    auto app = Application(req.tenantId, req.appId.isNull ? AppId(createId()) : req.appId, req.createdBy);
    app.spaceId = req.spaceId;
    app.name = req.name;
    app.state = AppState.stopped;
    app.instances = req.instances > 0 ? req.instances : 1;
    app.memoryMb = req.memoryMb > 0 ? req.memoryMb : 256;
    app.diskMb = req.diskMb > 0 ? req.diskMb : 1024;
    app.buildpackId = req.buildpackId;
    app.stack = req.stack.length > 0 ? req.stack : "cflinuxfs4";
    app.command = req.command;
    app.healthCheckType = toHealthCheckType(req.healthCheckType);
    app.healthCheckEndpoint = req.healthCheckEndpoint.length > 0 ? req.healthCheckEndpoint : "/";
    app.healthCheckTimeoutSec = req.healthCheckTimeoutSec > 0 ? req.healthCheckTimeoutSec : 60;
    app.environmentVariables = req.environmentVariables;
    app.dockerImage = req.dockerImage;

    apps.save(app);
    return UsecaseResult(true, app.id.value, "");
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

  UsecaseResult updateApp(UpdateAppRequest req) {
    if (req.appId.isNull)
      return UsecaseResult(false, "", "Application ID is required");

    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    auto app = apps.findById(req.tenantId, req.appId);
    if (app.isNull)
      return UsecaseResult(false, "", "Application not found");

    if (req.name.length > 0)
      app.name = req.name;
    if (req.instances > 0)
      app.instances = req.instances;
    if (req.memoryMb > 0)
      app.memoryMb = req.memoryMb;
    if (req.diskMb > 0)
      app.diskMb = req.diskMb;
    if (req.buildpackId.length > 0)
      app.buildpackId = req.buildpackId;
    if (req.stack.length > 0)
      app.stack = req.stack;
    if (req.command.length > 0)
      app.command = req.command;
    app.healthCheckType = req.healthCheckType.toHealthCheckType;
    if (req.healthCheckEndpoint.length > 0)
      app.healthCheckEndpoint = req.healthCheckEndpoint;
    if (req.healthCheckTimeoutSec > 0)
      app.healthCheckTimeoutSec = req.healthCheckTimeoutSec;
    if (req.environmentVariables.length > 0)
      app.environmentVariables = req.environmentVariables;
    if (req.dockerImage.length > 0)
      app.dockerImage = req.dockerImage;
    app.updatedAt = currentTimestamp();

    apps.update(app);
    return UsecaseResult(true, app.id.value, "");
  }

  /// Start an application (stage then start).
  UsecaseResult startApp(TenantId tenantId, AppId id) {
    auto app = apps.findById(tenantId, id);
    if (app.isNull)
      return UsecaseResult(false, "", "Application not found");
      
    if (app.state == AppState.started)
      return UsecaseResult(false, "", "Application is already started");

    lifecycle.stageApp(tenantId, id);
    if (!lifecycle.startApp(tenantId, id))
      return UsecaseResult(false, "", "Failed to start application");

    return UsecaseResult(true, id.value, "");
  }

  UsecaseResult stopApp(TenantId tenantId, AppId id) {
    auto app = apps.findById(tenantId, id);
    if (app.isNull)
      return UsecaseResult(false, "", "Application not found");
    if (app.state == AppState.stopped)
      return UsecaseResult(false, "", "Application is already stopped");

    if (!lifecycle.stopApp(tenantId, id))
      return UsecaseResult(false, "", "Cannot stop application");

    return UsecaseResult(true, id.value, "");
  }

  UsecaseResult restartApp(TenantId tenantId, AppId id) {
    if (!lifecycle.restartApp(tenantId, id))
      return UsecaseResult(false, "", "Cannot restart application");

    return UsecaseResult(true, id.value, "");
  }

  UsecaseResult scaleApp(ScaleAppRequest req) {
    if (req.appId.isNull)
      return UsecaseResult(false, "", "Application ID is required");

    if (!lifecycle.scaleApp(req.tenantId, req.appId, req.instances, req.memoryMb, req.diskMb))
      return UsecaseResult(false, "", "Cannot scale application — check quota limits");

    return UsecaseResult(true, req.appId.value, "");
  }

  /// Get environment variables for an application.
  string getEnvironment(TenantId tenantId, AppId id) {
    auto app = apps.findById(tenantId, id);
    if (app.isNull)
      return "{}";
    return app.environmentVariables.length > 0 ? app.environmentVariables : "{}";
  }

  /// Set environment variables for an application.
  UsecaseResult setEnvironment(TenantId tenantId, AppId id, string envJson) {
    if (!apps.existsById(tenantId, id))
      return UsecaseResult(false, "", "Application not found");

    auto app = apps.findById(tenantId, id);
    app.environmentVariables = envJson;
    app.updatedAt = currentTimestamp();
    apps.update(app);
   
    return UsecaseResult(true, app.id.value, "");
  }

  UsecaseResult deleteApp(TenantId tenantId, AppId appId) {
    auto app = apps.findById(tenantId, appId);
    if (app.isNull)
      return UsecaseResult(false, "", "Application not found");

    apps.remove(app);
    return UsecaseResult(true, app.id.value, "");
  }
}

///
unittest {
    // auto appRepository = new AppRepository();
    // auto appLifecycleManager = new AppLifecycleManager(new AppRepository(), new RouteResolver(), new);
    // auto usecase = new ManageAppsUseCase(appRepository, appLifecycleManager);
    // auto tenantId = TenantId("test-tenant");

    // // Test list
    // auto items = usecase.listApps(tenantId);
    // assert(items !is null);

}
