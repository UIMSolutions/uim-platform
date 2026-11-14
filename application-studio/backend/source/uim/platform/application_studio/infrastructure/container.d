/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.infrastructure.container;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application and persistence.
/// Presentation adapters (REST, OData, CLI, GUI) are created by the entry points
/// (app.d, cli.d, gui.d) on top of this container and only see `ports`.
class Container {
  StudioConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  StudioRepositories repositories;
  IStudioEventPublisher publisher;
  SimulatedWorkspaceGateway workspace;

  // ── Driving ports ─────────────────────────────────────────────────────
  StudioPorts ports;

  this(StudioConfig config) {
    this.config = config;
    wirePersistence();
    wireApplication();
  }

  protected void wirePersistence() {
    if (config.usesFileStorage)
      storage = new JsonFileSnapshotStorage(config.dataDir);

    auto store(TEntity, TId)(string collection) {
      ITenantStore!(TEntity, TId) s = storage is null
        ? new TenantStore!(TEntity, TId)()
        : new SnapshotTenantStore!(TEntity, TId, RecordMapper!TEntity)(storage, collection);
      return s;
    }

    with (repositories) {
      devSpaceTypes = new DevSpaceTypeRepository(store!(DevSpaceType, DevSpaceTypeId)(StudioCollections.devSpaceTypes));
      extensions = new ExtensionRepository(store!(Extension, ExtensionId)(StudioCollections.extensions));
      projectTemplates = new ProjectTemplateRepository(
        store!(ProjectTemplate, ProjectTemplateId)(StudioCollections.projectTemplates));
      devSpaces = new DevSpaceRepository(store!(DevSpace, DevSpaceId)(StudioCollections.devSpaces));
      projects = new ProjectRepository(store!(Project, ProjectId)(StudioCollections.projects));
      serviceBindings = new ServiceBindingRepository(
        store!(ServiceBinding, ServiceBindingId)(StudioCollections.serviceBindings));
      runConfigurations = new RunConfigurationRepository(
        store!(RunConfiguration, RunConfigurationId)(StudioCollections.runConfigurations));
      buildConfigurations = new BuildConfigurationRepository(
        store!(BuildConfiguration, BuildConfigurationId)(StudioCollections.buildConfigurations));
    }
    publisher = new LogEventPublisher();
    workspace = new SimulatedWorkspaceGateway();
  }

  protected void wireApplication() {
    auto r = repositories;
    auto cascade = new CascadeDeleter(r);
    auto projectStatus = new ProjectStatusSync(r);
    ports.devSpaceTypes = new ManageDevSpaceTypesUseCase(r, publisher);
    ports.extensions = new ManageExtensionsUseCase(r, publisher);
    ports.projectTemplates = new ManageProjectTemplatesUseCase(r, publisher);
    ports.devSpaces = new ManageDevSpacesUseCase(r, publisher);
    ports.projects = new ManageProjectsUseCase(r, cascade, publisher);
    ports.serviceBindings = new ManageServiceBindingsUseCase(r, publisher);
    ports.runConfigurations = new ManageRunConfigurationsUseCase(r, publisher);
    ports.buildConfigurations = new ManageBuildConfigurationsUseCase(r, projectStatus, publisher);
    ports.reconciler = new ReconcileUseCase(r, cascade, projectStatus, workspace, publisher);
    ports.statistics = new StudioStatisticsService(r);
    ports.catalog = new StudioCatalogService(r, publisher);
  }
}

/// Build the full dependency graph.
Container buildContainer(StudioConfig config) {
  return new Container(config);
}

///
unittest {
  mixin(ShowTest!("Container — end-to-end scenario"));

  StudioConfig cfg;
  cfg.storage = "memory";
  auto c = buildContainer(cfg);
  auto p = c.ports;
  auto t = TenantId("t1");
  auto who = UserId("jane");

  // ── catalogue ──────────────────────────────────────────────────────────
  auto seeded = p.catalog.seed(t, who);
  assert(seeded.created == 29 && seeded.skipped == 0, seeded.items.join(", "));
  assert(p.catalog.seed(t, who).created == 0); // idempotent
  DevSpaceTypeId typeId(string name) {
    return p.devSpaceTypes.list(t).filter!(x => x.name == name).front.id;
  }

  ProjectTemplateId templateId(string name) {
    return p.projectTemplates.list(t).filter!(x => x.name == name).front.id;
  }

  ExtensionId extensionId(string name) {
    return p.extensions.list(t).filter!(x => x.name == name).front.id;
  }

  assert(p.devSpaceTypes.remove(t, typeId("SAP Fiori"), who).code == 409); // predefined
  assert(p.extensions.remove(t, extensionId("sap.fiori-tools"), who).code == 409);

  // ── dev space: create → starting → running ─────────────────────────────
  CreateDevSpaceRequest ds;
  ds.tenantId = t;
  ds.actor = who;
  ds.spec.name = "FioriDev";
  ds.spec.owner = "jane@example.com";
  ds.spec.plan = DevSpacePlan.free_;
  ds.spec.devSpaceTypeId = typeId("SAP Fiori");
  ds.spec.extensions = ["sap.abap-deployment", "sap.fiori-tools"];
  auto dsResult = p.devSpaces.create(ds);
  assert(dsResult.isSuccess, dsResult.message);
  auto dsId = DevSpaceId(dsResult.id);
  assert(p.devSpaces.get(t, dsId).extensions == ["sap.abap-deployment"]); // predefined ones dropped
  assert(p.devSpaces.create(ds).code == 409); // duplicate name
  auto second = ds;
  second.spec.name = "FioriDev2";
  assert(p.devSpaces.create(second).code == 409); // free plan: one running dev space
  second.spec.name = "my-dev";
  assert(p.devSpaces.create(second).code == 422);
  second.spec.name = "Big";
  second.spec.memoryLimitMb = 8192;
  assert(p.devSpaces.create(second).code == 422); // free plan sizes

  CreateProjectRequest pr;
  pr.tenantId = t;
  pr.actor = who;
  pr.parentId = dsId;
  pr.spec.name = "travel-ui";
  pr.spec.templateId = templateId("fiori-list-report");
  assert(p.projects.create(pr).code == 409); // dev space not running yet

  auto first = p.reconciler.reconcile(t);
  assert(first.advanced == 1, first.changes.join("; "));
  assert(p.devSpaces.get(t, dsId).status == DevSpaceStatus.running);
  assert(p.devSpaces.get(t, dsId).url.startsWith("https://"));

  // ── projects from templates ────────────────────────────────────────────
  auto prResult = p.projects.create(pr);
  assert(prResult.isSuccess, prResult.message);
  auto projectId = ProjectId(prResult.id);
  auto project = p.projects.get(t, projectId);
  assert(project.projectType == ProjectType.sapFioriElements && project.files.canFind("webapp/manifest.json"));
  assert(project.rootPath == "/home/user/projects/travel-ui");
  auto cap = pr;
  cap.spec.name = "travel-srv";
  cap.spec.templateId = templateId("cap-project");
  assert(p.projects.create(cap).code == 409); // sap.cap-tools missing in a Fiori dev space
  cap.spec.templateId = ProjectTemplateId.init;
  cap.spec.projectType = ProjectType.capJava;
  assert(p.projects.create(cap).code == 409); // type not supported by "SAP Fiori"
  assert(p.projectTemplates.remove(t, templateId("fiori-list-report"), who).code == 409); // in use

  // ── service binding: disconnected → connecting → connected ─────────────
  CreateServiceBindingRequest sb;
  sb.tenantId = t;
  sb.actor = who;
  sb.parentId = dsId;
  sb.spec.name = "S4 Travel";
  sb.spec.providerType = ServiceProviderType.sapS4Hana;
  sb.spec.serviceUrl = "https://s4.example.com";
  sb.spec.authType = BindingAuthType.basicAuthentication;
  sb.spec.user = "TRAVEL_USER";
  sb.spec.credentials = "secret";
  assert(p.serviceBindings.create(sb).code == 422); // OData without service path
  sb.spec.servicePath = "/sap/opu/odata4/sap/travel/0001/";
  auto sbResult = p.serviceBindings.create(sb);
  assert(sbResult.isSuccess, sbResult.message);
  auto sbId = ServiceBindingId(sbResult.id);
  assert(p.serviceBindings.connect(t, sbId, who).isSuccess);

  // ── run configuration ──────────────────────────────────────────────────
  CreateRunConfigurationRequest rc;
  rc.tenantId = t;
  rc.actor = who;
  rc.parentId = projectId;
  rc.spec.name = "Run travel";
  rc.spec.entryPoint = "npm start";
  rc.spec.serviceBindings = ["S4 Travel"];
  rc.spec.environment = [KeyValue("NODE_ENV", "development")];
  auto rcResult = p.runConfigurations.create(rc);
  assert(rcResult.isSuccess, rcResult.message);
  auto rcId = RunConfigurationId(rcResult.id);
  assert(p.runConfigurations.start(t, rcId, who).code == 409); // binding still connecting
  p.reconciler.reconcile(t);
  assert(p.serviceBindings.get(t, sbId).status == BindingStatus.connected);
  assert(p.runConfigurations.start(t, rcId, who).isSuccess);
  auto clash = rc;
  clash.spec.name = "Debug travel";
  clash.spec.mode = RunMode.debug_;
  assert(p.runConfigurations.create(clash).code == 422); // debug without debug port
  clash.spec.debugPort = 9229;
  auto clashId = RunConfigurationId(p.runConfigurations.create(clash).id);
  assert(p.runConfigurations.start(t, clashId, who).code == 409); // port 4004 taken
  p.reconciler.reconcile(t);
  assert(p.runConfigurations.get(t, rcId).status == RunStatus.running);
  assert(p.runConfigurations.get(t, rcId).url.startsWith("https://port4004-"));
  assert(p.runConfigurations.remove(t, rcId, who).code == 409); // running
  assert(p.serviceBindings.remove(t, sbId, who).code == 409); // used by a run configuration
  rc.spec.name = "Bad";
  rc.spec.serviceBindings = ["Unknown"];
  assert(p.runConfigurations.create(rc).code == 404);

  // ── build & deploy ─────────────────────────────────────────────────────
  CreateBuildConfigurationRequest bc;
  bc.tenantId = t;
  bc.actor = who;
  bc.parentId = projectId;
  bc.spec.name = "mta";
  auto bcResult = p.buildConfigurations.create(bc);
  assert(bcResult.isSuccess, bcResult.message);
  auto bcId = BuildConfigurationId(bcResult.id);
  auto mta = p.buildConfigurations.get(t, bcId);
  assert(mta.mtaDescriptor == "mta.yaml" && mta.artifactPath == "mta_archives/travel-ui_1.0.0.mtar");
  assert(mta.deployCommand == "cf deploy mta_archives/travel-ui_1.0.0.mtar");
  assert(p.buildConfigurations.deploy(t, bcId, who).code == 409); // nothing built yet
  assert(p.buildConfigurations.build(t, bcId, who).isSuccess);
  assert(p.projects.get(t, projectId).status == ProjectStatus.building);
  assert(p.projects.remove(t, projectId, who).code == 409); // busy
  p.reconciler.reconcile(t);
  assert(p.buildConfigurations.get(t, bcId).status == BuildStatus.succeeded);
  assert(p.projects.get(t, projectId).status == ProjectStatus.active);
  assert(p.buildConfigurations.deploy(t, bcId, who).isSuccess);
  assert(p.projects.get(t, projectId).status == ProjectStatus.deploying);
  p.reconciler.reconcile(t);
  auto deployed = p.buildConfigurations.get(t, bcId);
  assert(deployed.status == BuildStatus.deployed && deployed.history.length == 2);
  assert(deployed.history[1].phase == BuildPhase.deploy && deployed.history[1].status == BuildStatus.deployed);

  auto broken = bc;
  broken.spec.name = "ui5 broken";
  broken.spec.deployTarget = DeployTarget.html5Repository;
  broken.spec.buildCommand = "npm run build [fail]";
  auto brokenId = BuildConfigurationId(p.buildConfigurations.create(broken).id);
  assert(p.buildConfigurations.build(t, brokenId, who).isSuccess);
  p.reconciler.reconcile(t);
  assert(p.buildConfigurations.get(t, brokenId).status == BuildStatus.failed);
  assert(p.projects.get(t, projectId).status == ProjectStatus.error);

  // ── statistics ─────────────────────────────────────────────────────────
  auto stats = p.statistics.statistics(t);
  assert(stats.devSpaces == 1 && stats.devSpacesRunning == 1 && stats.projects == 1);
  assert(stats.bindingsConnected == 1 && stats.runsActive == 1 && stats.deployments == 1 && stats.buildsFailed == 1);
  assert(stats.extensions == 15 && stats.devSpaceTypes == 6 && stats.projectTemplates == 8);

  // ── stop: runs end; extensions change only while stopped ───────────────
  assert(p.devSpaces.addExtension(t, dsId, "sap.kyma-tools", who).code == 409); // running
  assert(p.devSpaces.remove(t, dsId, who).code == 409); // running
  assert(p.devSpaces.stop(t, dsId, who).isSuccess);
  p.reconciler.reconcile(t);
  assert(p.devSpaces.get(t, dsId).status == DevSpaceStatus.stopped);
  assert(p.runConfigurations.get(t, rcId).status == RunStatus.stopped);
  assert(p.devSpaces.addExtension(t, dsId, "sap.kyma-tools", who).isSuccess);
  assert(p.devSpaces.removeExtension(t, dsId, "sap.fiori-tools", who).code == 409); // predefined
  assert(p.extensions.remove(t, extensionId("sap.kyma-tools"), who).code == 409); // installed
  assert(p.devSpaces.removeExtension(t, dsId, "sap.kyma-tools", who).isSuccess);
  assert(p.extensions.deprecate(t, extensionId("sap.kyma-tools"), who).isSuccess);
  assert(p.devSpaces.addExtension(t, dsId, "sap.kyma-tools", who).code == 409); // deprecated

  // ── hibernation after inactivity, resume on access ─────────────────────
  assert(p.devSpaces.start(t, dsId, who).isSuccess);
  p.reconciler.reconcile(t);
  auto idle = c.repositories.devSpaces.findById(t, dsId);
  idle.lastAccessedAt = nowStdTime() - 8 * stdTimeDay;
  c.repositories.devSpaces.update(idle);
  p.reconciler.reconcile(t);
  assert(p.devSpaces.get(t, dsId).status == DevSpaceStatus.hibernating);
  p.reconciler.reconcile(t);
  assert(p.devSpaces.get(t, dsId).status == DevSpaceStatus.hibernated);
  assert(p.devSpaces.touch(t, dsId, who).isSuccess);
  assert(p.devSpaces.get(t, dsId).status == DevSpaceStatus.resuming);
  p.reconciler.reconcile(t);
  assert(p.devSpaces.get(t, dsId).status == DevSpaceStatus.running);

  // ── deleting a dev space is asynchronous and cascades ──────────────────
  assert(p.devSpaces.stop(t, dsId, who).isSuccess);
  p.reconciler.reconcile(t);
  assert(p.devSpaces.remove(t, dsId, who).isSuccess);
  assert(p.devSpaces.get(t, dsId).status == DevSpaceStatus.deleting);
  assert(p.serviceBindings.create(sb).code == 409); // dev space being deleted
  p.reconciler.reconcile(t);
  assert(p.devSpaces.get(t, dsId).isNull);
  assert(p.projects.list(t).length == 0 && p.serviceBindings.list(t).length == 0);
  assert(p.runConfigurations.list(t).length == 0 && p.buildConfigurations.list(t).length == 0);
  assert(c.workspace.operations.any!(o => o.verb == "delete"));
  second.spec.name = "FioriDev2";
  second.spec.memoryLimitMb = 4096;
  assert(p.devSpaces.create(second).isSuccess); // free slot again
}
