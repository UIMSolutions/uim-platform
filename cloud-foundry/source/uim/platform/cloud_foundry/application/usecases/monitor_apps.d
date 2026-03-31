module uim.platform.cloud_foundry.application.usecases.monitor_apps;

import uim.platform.cloud_foundry.domain.types;
import uim.platform.cloud_foundry.domain.entities.application;
import uim.platform.cloud_foundry.domain.entities.service_instance;
import uim.platform.cloud_foundry.domain.entities.route;
import uim.platform.cloud_foundry.domain.ports.app;
import uim.platform.cloud_foundry.domain.ports.service_instance;
import uim.platform.cloud_foundry.domain.ports.route;

/// Read-only summaries for application health and space resource usage.
struct AppHealthSummary
{
  AppId appId;
  string appName;
  AppState state;
  int requestedInstances;
  int runningInstances;
  int crashedInstances;
  int totalMemoryMb;
  int totalDiskMb;
}

struct SpaceUsageSummary
{
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

class MonitorAppsUseCase
{
  private AppRepository appRepo;
  private ServiceInstanceRepository siRepo;
  private RouteRepository routeRepo;

  this(AppRepository appRepo, ServiceInstanceRepository siRepo, RouteRepository routeRepo)
  {
    this.appRepo = appRepo;
    this.siRepo = siRepo;
    this.routeRepo = routeRepo;
  }

  /// Get health summary for all apps belonging to the tenant.
  AppHealthSummary[] listAppHealth(TenantId tenantId)
  {
    auto apps = appRepo.findByTenant(tenantId);
    AppHealthSummary[] result;
    foreach (app; apps)
      result ~= buildHealthSummary(app);
    return result;
  }

  /// Get health summary for a single application.
  AppHealthSummary getAppHealth(AppId id, TenantId tenantId)
  {
    auto app = appRepo.findById(id, tenantId);
    if (app is null)
      return AppHealthSummary.init;
    return buildHealthSummary(*app);
  }

  /// Get resource usage summary for a space.
  SpaceUsageSummary getSpaceUsage(SpaceId spaceId, TenantId tenantId)
  {
    auto apps = appRepo.findBySpace(spaceId, tenantId);
    auto instances = siRepo.findBySpace(spaceId, tenantId);
    auto routes = routeRepo.findBySpace(spaceId, tenantId);

    SpaceUsageSummary s;
    s.spaceId = spaceId;
    s.totalApps = cast(int) apps.length;
    s.totalServiceInstances = cast(int) instances.length;
    s.totalRoutes = cast(int) routes.length;

    foreach (app; apps)
    {
      final switch (app.state)
      {
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

  private AppHealthSummary buildHealthSummary(Application app)
  {
    AppHealthSummary h;
    h.appId = app.id;
    h.appName = app.name;
    h.state = app.state;
    h.requestedInstances = app.instances;
    h.totalMemoryMb = app.instances * app.memoryMb;
    h.totalDiskMb = app.instances * app.diskMb;

    if (app.state == AppState.started)
    {
      h.runningInstances = app.runningInstances > 0 ? app.runningInstances : app.instances;
      h.crashedInstances = app.instances - h.runningInstances;
    }
    else if (app.state == AppState.crashed)
    {
      h.crashedInstances = app.instances;
    }
    return h;
  }
}
