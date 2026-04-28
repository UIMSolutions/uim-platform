/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.services.app_lifecycle_manager;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.application;
// import uim.platform.foundry.domain.entities.organization;

// // import uim.platform.foundry.domain.ports.repositories.app;
// // import uim.platform.foundry.domain.ports.repositories.org;
// // import uim.platform.foundry.domain.ports.repositories.space;
// import uim.platform.foundry.domain.ports;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
// import std.datetime.systime : Clock;

/// Domain service that manages application lifecycle transitions —
/// staging, starting, stopping, scaling, and quota enforcement.
class AppLifecycleManager {
  private IAppRepository apps;
  private IOrgRepository orgs;
  private ISpaceRepository spaces;

  this(IAppRepository apps, IOrgRepository orgs, ISpaceRepository spaces) {
    this.apps = apps;
    this.orgs = orgs;
    this.spaces = spaces;
  }

  /// Stage an application (simulate buildpack detection and compilation).
  bool stageApp(TenantId tenantId, AppId appId) {
    auto app = apps.findById(tenantId, appId);
    if (app.isNull)
      return false;
    if (app.state != AppState.stopped && app.state != AppState.crashed)
      return false;

    app.state = AppState.staging;
    app.stagedAt = Clock.currStdTime();
    app.updatedAt = app.stagedAt;
    apps.update(*app);
    return true;
  }

  /// Start an application (transition from staging/stopped to started).
  bool startApp(TenantId tenantId, AppId appId) {
    auto app = apps.findById(tenantId, appId);
    if (app.isNull)
      return false;

    app.state = AppState.started;
    app.runningInstances = app.instances;
    app.updatedAt = Clock.currStdTime();
    apps.update(*app);
    return true;
  }

  /// Stop a running application.
  bool stopApp(TenantId tenantId, AppId appId) {
    auto app = apps.findById(tenantId, appId);
    if (app.isNull)
      return false;
    if (app.state == AppState.stopped)
      return false;

    app.state = AppState.stopped;
    app.runningInstances = 0;
    app.updatedAt = Clock.currStdTime();
    apps.update(*app);
    return true;
  }

  /// Restart an application (stop then start).
  bool restartApp(TenantId tenantId, AppId appId) {
    auto app = apps.findById(tenantId, appId);
    if (app.isNull)
      return false;
    if (app.state != AppState.started && app.state != AppState.crashed)
      return false;

    app.state = AppState.started;
    app.runningInstances = app.instances;
    app.updatedAt = Clock.currStdTime();
    apps.update(*app);
    return true;
  }

  /// Scale an application — validate against org quota before applying.
  bool scaleApp(TenantId tenantId, AppId appId, int instances, int memoryMb, int diskMb) {
    auto app = apps.findById(tenantId, appId);
    if (app.isNull)
      return false;

    // Validate instance memory against org quota
    auto space = spaces.findById(tenantId, app.spaceId);
    if (space !is null) {
      auto org = orgs.findById(tenantId, space.orgId);
      if (org !is null) {
        int effMemory = memoryMb > 0 ? memoryMb : app.memoryMb;
        if (org.instanceMemoryLimitMb > 0 && effMemory > org.instanceMemoryLimitMb)
          return false;
      }
    }

    if (instances > 0)
      app.instances = instances;
    if (memoryMb > 0)
      app.memoryMb = memoryMb;
    if (diskMb > 0)
      app.diskMb = diskMb;

    // If app is running, adjust running instances
    if (app.state == AppState.started)
      app.runningInstances = app.instances;

    app.updatedAt = Clock.currStdTime();
    apps.update(*app);
    return true;
  }

  /// Check if org memory quota would be exceeded by adding the given memory.
  bool isQuotaExceeded(OrgId orgId, TenantId tenantId, int additionalMemoryMb) {
    auto org = orgs.findById(tenantId, orgId);
    if (org.isNull)
      return true;

    auto spaces = spaces.findByOrg(tenantId, orgId);
    long totalUsed = 0;
    foreach (s; spaces) {
      auto apps = apps.findBySpace(s.tenantId, s.id);
      foreach (a; apps)
        totalUsed += a.instances * a.memoryMb;
    }

    return (totalUsed + additionalMemoryMb) > org.memoryQuotaMb;
  }
}
