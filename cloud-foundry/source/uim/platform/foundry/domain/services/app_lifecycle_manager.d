/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.services.app_lifecycle_manager;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.application;
import uim.platform.foundry.domain.entities.organization;

// import uim.platform.foundry.domain.ports.repositories.app;
// import uim.platform.foundry.domain.ports.repositories.org;
// import uim.platform.foundry.domain.ports.repositories.space;
import uim.platform.foundry.domain.ports;

// import std.datetime.systime : Clock;

/// Domain service that manages application lifecycle transitions —
/// staging, starting, stopping, scaling, and quota enforcement.
class AppLifecycleManager {
  private AppRepository appRepo;
  private OrgRepository orgRepo;
  private SpaceRepository spaceRepo;

  this(AppRepository appRepo, OrgRepository orgRepo, SpaceRepository spaceRepo) {
    this.appRepo = appRepo;
    this.orgRepo = orgRepo;
    this.spaceRepo = spaceRepo;
  }

  /// Stage an application (simulate buildpack detection and compilation).
  bool stageApp(AppId apptenantId, id tenantId) {
    auto app = appRepo.findById(apptenantId, id);
    if (app is null)
      return false;
    if (app.state != AppState.stopped && app.state != AppState.crashed)
      return false;

    app.state = AppState.staging;
    app.stagedAt = Clock.currStdTime();
    app.updatedAt = app.stagedAt;
    appRepo.update(*app);
    return true;
  }

  /// Start an application (transition from staging/stopped to started).
  bool startApp(AppId apptenantId, id tenantId) {
    auto app = appRepo.findById(apptenantId, id);
    if (app is null)
      return false;

    app.state = AppState.started;
    app.runningInstances = app.instances;
    app.updatedAt = Clock.currStdTime();
    appRepo.update(*app);
    return true;
  }

  /// Stop a running application.
  bool stopApp(AppId apptenantId, id tenantId) {
    auto app = appRepo.findById(apptenantId, id);
    if (app is null)
      return false;
    if (app.state == AppState.stopped)
      return false;

    app.state = AppState.stopped;
    app.runningInstances = 0;
    app.updatedAt = Clock.currStdTime();
    appRepo.update(*app);
    return true;
  }

  /// Restart an application (stop then start).
  bool restartApp(AppId apptenantId, id tenantId) {
    auto app = appRepo.findById(apptenantId, id);
    if (app is null)
      return false;
    if (app.state != AppState.started && app.state != AppState.crashed)
      return false;

    app.state = AppState.started;
    app.runningInstances = app.instances;
    app.updatedAt = Clock.currStdTime();
    appRepo.update(*app);
    return true;
  }

  /// Scale an application — validate against org quota before applying.
  bool scaleApp(AppId apptenantId, id tenantId, int instances, int memoryMb, int diskMb) {
    auto app = appRepo.findById(apptenantId, id);
    if (app is null)
      return false;

    // Validate instance memory against org quota
    auto space = spaceRepo.findById(app.spacetenantId, id);
    if (space !is null) {
      auto org = orgRepo.findById(space.orgtenantId, id);
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
    appRepo.update(*app);
    return true;
  }

  /// Check if org memory quota would be exceeded by adding the given memory.
  bool isQuotaExceeded(OrgId orgtenantId, id tenantId, int additionalMemoryMb) {
    auto org = orgRepo.findById(orgtenantId, id);
    if (org is null)
      return true;

    auto spaces = spaceRepo.findByOrg(orgtenantId, id);
    long totalUsed = 0;
    foreach (s; spaces) {
      auto apps = appRepo.findBySpace(s.tenantId, id);
      foreach (a; apps)
        totalUsed += a.instances * a.memoryMb;
    }

    return (totalUsed + additionalMemoryMb) > org.memoryQuotaMb;
  }
}
