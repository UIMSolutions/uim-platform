/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.services.statistics;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Application service computing the tenant figures from all repositories.
class AgentryStatisticsService : IAgentryStatisticsService {
  protected IMobileApplicationRepository applications;
  protected IAppDefinitionRepository definitions;
  protected IAppVersionRepository versions;
  protected IDeviceRepository devices;
  protected ISyncSessionRepository syncSessions;
  protected IBackendConnectionRepository connections;
  protected IDeploymentRepository deployments;

  this(IMobileApplicationRepository applications, IAppDefinitionRepository definitions,
      IAppVersionRepository versions, IDeviceRepository devices, ISyncSessionRepository syncSessions,
      IBackendConnectionRepository connections, IDeploymentRepository deployments) {
    this.applications = applications;
    this.definitions = definitions;
    this.versions = versions;
    this.devices = devices;
    this.syncSessions = syncSessions;
    this.connections = connections;
    this.deployments = deployments;
  }

  AgentryStatistics statistics(TenantId tenantId) {
    AgentryStatistics s;
    s.tenantId = tenantId;

    // one pass per collection instead of one query per figure
    foreach (a; applications.findByTenant(tenantId)) {
      s.mobileApplications++;
      if (a.status == AppStatus.active)
        s.activeApplications++;
    }
    foreach (d; definitions.findByTenant(tenantId)) {
      s.appDefinitions++;
      if (d.status == DefinitionStatus.published)
        s.publishedDefinitions++;
    }
    foreach (v; versions.findByTenant(tenantId)) {
      s.appVersions++;
      if (v.status == AppVersionStatus.published)
        s.publishedVersions++;
    }
    foreach (p; [EnumMembers!AppPlatform])
      s.devicesByPlatform[enumValue(p)] = 0;
    foreach (d; devices.findByTenant(tenantId)) {
      s.devices++;
      if (d.status == DeviceStatus.active)
        s.activeDevices++;
      else if (d.status == DeviceStatus.suspended)
        s.suspendedDevices++;
      s.devicesByPlatform[enumValue(d.platform)]++;
    }
    foreach (x; syncSessions.findByTenant(tenantId)) {
      s.syncSessions++;
      if (x.status == SyncStatus.inProgress)
        s.runningSyncs++;
      else if (x.status == SyncStatus.failed)
        s.failedSyncs++;
      else if (x.status == SyncStatus.completed) {
        s.bytesTransferred += x.bytesSent + x.bytesReceived;
        s.recordsTransferred += x.recordsSent + x.recordsReceived;
        s.lastSyncAt = max(s.lastSyncAt, x.completedAt);
      }
    }
    foreach (c; connections.findByTenant(tenantId)) {
      s.backendConnections++;
      if (c.status == ConnectionStatus.error)
        s.connectionErrors++;
    }
    foreach (d; deployments.findByTenant(tenantId)) {
      s.deployments++;
      if (d.status == DeploymentStatus.deploying)
        s.runningDeployments++;
      else if (d.status == DeploymentStatus.failed)
        s.failedDeployments++;
    }
    return s;
  }
}

///
unittest {
  mixin(ShowTest!("AgentryStatisticsService"));

  auto t = TenantId("t1");
  auto devices = new DeviceRepository();
  auto d = MobileDevice(t);
  d.platform = AppPlatform.ios;
  d.status = DeviceStatus.active;
  devices.save(d);
  auto sessions = new SyncSessionRepository();
  auto s = SyncSession(t);
  s.status = SyncStatus.completed;
  s.bytesSent = 5;
  s.bytesReceived = 7;
  s.completedAt = 42;
  sessions.save(s);

  auto svc = new AgentryStatisticsService(new MobileApplicationRepository(), new AppDefinitionRepository(),
    new AppVersionRepository(), devices, sessions, new BackendConnectionRepository(), new DeploymentRepository());
  auto stats = svc.statistics(t);
  assert(stats.devices == 1 && stats.activeDevices == 1);
  assert(stats.devicesByPlatform["ios"] == 1 && stats.devicesByPlatform["android"] == 0);
  assert(stats.bytesTransferred == 12 && stats.lastSyncAt == 42);
}
