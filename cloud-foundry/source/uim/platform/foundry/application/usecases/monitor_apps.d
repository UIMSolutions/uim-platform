/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.application.usecases.monitor_apps;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.application;
import uim.platform.foundry.domain.entities.service_instance;
import uim.platform.foundry.domain.entities.route;

// import uim.platform.foundry.domain.ports.repositories.app;
// import uim.platform.foundry.domain.ports.repositories.service_instance;
// import uim.platform.foundry.domain.ports.repositories.route;
import uim.platform.foundry.domain.ports;

/// Read-only summaries for application health and space resource usage.
struct AppHealthSummary {
  AppId appId;
  string appName;
  AppState state;
  int requestedInstances;
  int runningInstances;
  int crashedInstances;
  int totalMemoryMb;
  int totalDiskMb;
}

struct SpaceUsageSummary {
  SpaceId spaceId;
  int totalApps;
  int runningApps;
  int stoppedApps;
  int crashedApps;
  long totalMemoryUsedMb;
  long totalDiskUsedMb;
  int totalServiceInstances;
  int totalRoutes;
}

class MonitorAppsUseCase : UIMUseCase {
  private AppRepository appRepo;
  private ServiceInstanceRepository siRepo;
  private RouteRepository routeRepo;

  this(AppRepository appRepo, ServiceInstanceRepository siRepo, RouteRepository routeRepo) {
    this.appRepo = appRepo;
    this.siRepo = siRepo;
    this.routeRepo = routeRepo;
  }

  /// Get health summary for all apps belonging to the tenant.
  AppHealthSummary[] listAppHealth(TenantId tenantId) {
    auto apps = appRepo.findByTenant(tenantId);
    AppHealthSummary[] result;
    foreach (app; apps)
      result ~= buildHealthSummary(app);
    return result;
  }

  /// Get health summary for a single application.
  AppHealthSummary getAppHealth(AppId tenantId, id tenantId) {
    auto app = appRepo.findById(tenantId, id);
    if (app is null)
      return AppHealthSummary.init;
    return buildHealthSummary(*app);
  }

  /// Get resource usage summary for a space.
  SpaceUsageSummary getSpaceUsage(SpaceId spacetenantId, id tenantId) {
    auto apps = appRepo.findBySpace(spacetenantId, id);
    auto instances = siRepo.findBySpace(spacetenantId, id);
    auto routes = routeRepo.findBySpace(spacetenantId, id);

    SpaceUsageSummary s;
    s.spaceId = spaceId;
    s.totalApps = cast(int) apps.length;
    s.totalServiceInstances = cast(int) instances.length;
    s.totalRoutes = cast(int) routes.length;

    foreach (app; apps) {
      final switch (app.state) {
      case AppState.started:
        s.runningApps++;
        s.totalMemoryUsedMb += app.instances * app.memoryMb;
        s.totalDiskUsedMb += app.instances * app.diskMb;
        break;
      case AppState.stopped:
        s.stoppedApps++;
        break;
      case AppState.crashed:
        s.crashedApps++;
        break;
      case AppState.staging:
        break;
      }
    }
    return s;
  }

  private AppHealthSummary buildHealthSummary(Application app) {
    AppHealthSummary h;
    h.appId = app.id;
    h.appName = app.name;
    h.state = app.state;
    h.requestedInstances = app.instances;
    h.totalMemoryMb = app.instances * app.memoryMb;
    h.totalDiskMb = app.instances * app.diskMb;

    if (app.state == AppState.started) {
      h.runningInstances = app.runningInstances > 0 ? app.runningInstances : app.instances;
      h.crashedInstances = app.instances - h.runningInstances;
    }
    else if (app.state == AppState.crashed) {
      h.crashedInstances = app.instances;
    }
    return h;
  }
}
