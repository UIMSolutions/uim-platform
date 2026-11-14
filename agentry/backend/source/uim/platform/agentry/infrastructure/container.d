/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.container;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application and persistence.
/// Presentation adapters (HTTP, REST, OData, CLI, GUI) are created by the entry
/// points (app.d, cli.d, gui.d) on top of this container and only see the
/// driving ports (AgentryPorts).
class Container {
  AgentryConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  MobileApplicationRepository mobileApplicationRepo;
  AppDefinitionRepository appDefinitionRepo;
  AppVersionRepository appVersionRepo;
  DeviceRepository deviceRepo;
  SyncSessionRepository syncSessionRepo;
  BackendConnectionRepository backendConnectionRepo;
  DeploymentRepository deploymentRepo;
  IAgentryEventPublisher publisher;
  IBackendProbe backendProbe;

  // ── Driving ports ─────────────────────────────────────────────────────
  IManageMobileApplicationsUseCase manageMobileApplications;
  IManageAppDefinitionsUseCase manageAppDefinitions;
  IManageAppVersionsUseCase manageAppVersions;
  IManageDevicesUseCase manageDevices;
  IManageSyncSessionsUseCase manageSyncSessions;
  IManageBackendConnectionsUseCase manageBackendConnections;
  IManageDeploymentsUseCase manageDeployments;
  IAgentryStatisticsService statistics;

  this(AgentryConfig config) {
    this.config = config;
    wirePersistence();
    wireGateways();
    wireApplication();
  }

  /// The driving ports for presentation adapters.
  AgentryPorts ports() {
    AgentryPorts p;
    p.mobileApplications = manageMobileApplications;
    p.appDefinitions = manageAppDefinitions;
    p.appVersions = manageAppVersions;
    p.devices = manageDevices;
    p.syncSessions = manageSyncSessions;
    p.backendConnections = manageBackendConnections;
    p.deployments = manageDeployments;
    p.statistics = statistics;
    return p;
  }

  protected void wirePersistence() {
    if (!config.usesFileStorage) {
      mobileApplicationRepo = new MobileApplicationRepository();
      appDefinitionRepo = new AppDefinitionRepository();
      appVersionRepo = new AppVersionRepository();
      deviceRepo = new DeviceRepository();
      syncSessionRepo = new SyncSessionRepository();
      backendConnectionRepo = new BackendConnectionRepository();
      deploymentRepo = new DeploymentRepository();
      return;
    }

    storage = new JsonFileSnapshotStorage(config.dataDir);
    auto store(TEntity, TId, TMapper)(AgentryCollections collection) {
      return new SnapshotTenantStore!(TEntity, TId, TMapper)(storage, collection);
    }

    mobileApplicationRepo = new MobileApplicationRepository(
      store!(MobileApplication, MobileApplicationId, MobileApplicationMapper)(AgentryCollections.mobileApplications));
    appDefinitionRepo = new AppDefinitionRepository(
      store!(AppDefinition, AppDefinitionId, AppDefinitionMapper)(AgentryCollections.appDefinitions));
    appVersionRepo = new AppVersionRepository(
      store!(AppVersion, AppVersionId, AppVersionMapper)(AgentryCollections.appVersions));
    deviceRepo = new DeviceRepository(
      store!(MobileDevice, DeviceId, DeviceMapper)(AgentryCollections.devices));
    syncSessionRepo = new SyncSessionRepository(
      store!(SyncSession, SyncSessionId, SyncSessionMapper)(AgentryCollections.syncSessions));
    backendConnectionRepo = new BackendConnectionRepository(
      store!(BackendConnection, BackendConnectionId, BackendConnectionMapper)(AgentryCollections.backendConnections));
    deploymentRepo = new DeploymentRepository(
      store!(Deployment, DeploymentId, DeploymentMapper)(AgentryCollections.deployments));
  }

  protected void wireGateways() {
    publisher = new LogEventPublisher();
    backendProbe = config.probeTimeoutSeconds > 0
      ? cast(IBackendProbe) new HttpBackendProbe(config.probeTimeoutSeconds)
      : cast(IBackendProbe) new DisabledBackendProbe();
  }

  protected void wireApplication() {
    manageMobileApplications = new ManageMobileApplicationsUseCase(mobileApplicationRepo, publisher);
    manageAppDefinitions = new ManageAppDefinitionsUseCase(appDefinitionRepo, mobileApplicationRepo, publisher);
    manageAppVersions = new ManageAppVersionsUseCase(appVersionRepo, appDefinitionRepo, publisher);
    manageDevices = new ManageDevicesUseCase(deviceRepo, mobileApplicationRepo, publisher);
    manageSyncSessions = new ManageSyncSessionsUseCase(syncSessionRepo, deviceRepo, publisher);
    manageBackendConnections = new ManageBackendConnectionsUseCase(backendConnectionRepo, backendProbe, publisher);
    manageDeployments = new ManageDeploymentsUseCase(deploymentRepo, appVersionRepo, deviceRepo, publisher);
    statistics = new AgentryStatisticsService(mobileApplicationRepo, appDefinitionRepo, appVersionRepo,
      deviceRepo, syncSessionRepo, backendConnectionRepo, deploymentRepo);
  }
}

/// Build the full dependency graph.
Container buildContainer(AgentryConfig config) {
  return new Container(config);
}

///
unittest {
  mixin(ShowTest!("Container"));

  AgentryConfig cfg;
  cfg.storage = "memory";
  auto c = buildContainer(cfg);
  assert(c.storage is null);

  MobileApplicationDTO dto;
  dto.tenantId = TenantId("t1");
  dto.name = "Inventory";
  dto.packageName = "com.example.inventory";
  assert(c.ports.mobileApplications.createMobileApplication(dto).isSuccess);
  assert(c.ports.statistics.statistics(TenantId("t1")).mobileApplications == 1);
}
