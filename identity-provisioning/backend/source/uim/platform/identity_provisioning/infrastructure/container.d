/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.infrastructure.container;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application, persistence and
/// the connector gateway. Presentation adapters (REST, OData, CLI, GUI) are
/// created by the entry points (app.d, cli.d, gui.d) and only see `ports`.
class Container {
  ProvisioningConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  ProvisioningRepositories repositories;
  IProvisioningEventPublisher publisher;
  IIdentityConnector connector;

  // ── Application services ──────────────────────────────────────────────
  EventRecorder events;
  ProvisioningRunner runner;

  // ── Driving ports ─────────────────────────────────────────────────────
  ProvisioningPorts ports;

  this(ProvisioningConfig config, IIdentityConnector connector = null) {
    this.config = config;
    this.connector = connector is null ? new SimulatedIdentityConnector() : connector;
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

    alias C = ProvisioningCollections;
    with (repositories) {
      sourceSystems = new SourceSystemRepository(store!(SourceSystem, SourceSystemId)(C.sourceSystems));
      targetSystems = new TargetSystemRepository(store!(TargetSystem, TargetSystemId)(C.targetSystems));
      proxySystems = new ProxySystemRepository(store!(ProxySystem, ProxySystemId)(C.proxySystems));
      transformations = new TransformationRepository(store!(Transformation, TransformationId)(C.transformations));
      jobs = new ProvisioningJobRepository(store!(ProvisioningJob, ProvisioningJobId)(C.jobs));
      logs = new ProvisioningLogRepository(store!(ProvisioningLog, ProvisioningLogId)(C.logs));
      entities = new ProvisionedEntityRepository(store!(ProvisionedEntity, ProvisionedEntityId)(C.entities));
    }
    publisher = new LogEventPublisher();
  }

  protected void wireApplication() {
    auto r = repositories;
    events = new EventRecorder(publisher);
    runner = new ProvisioningRunner(r, connector, events);

    ports.sourceSystems = new ManageSourceSystemsUseCase(r, r.sourceSystems, events, connector, SystemRole.source);
    ports.targetSystems = new ManageTargetSystemsUseCase(r, r.targetSystems, events, connector, SystemRole.target);
    ports.proxySystems = new ManageProxySystemsUseCase(r, r.proxySystems, events, connector, SystemRole.proxy);
    ports.transformations = new ManageTransformationsUseCase(r, events);
    ports.jobs = new ManageProvisioningJobsUseCase(r, events, runner);
    ports.logs = new ProvisioningLogsQuery(r);
    ports.entities = new ProvisionedEntitiesQuery(r);
    ports.catalog = new SystemCatalogService();
    ports.statistics = new ProvisioningStatisticsService(r);
  }

  /// Seed the demo landscape into the default tenant if configured and empty.
  bool seedDemoData() {
    if (!config.demoData)
      return false;
    return new DemoDataSeeder(ports).seed(TenantId(config.defaultTenant));
  }
}

/// Build the full dependency graph.
Container buildContainer(ProvisioningConfig config) {
  return new Container(config);
}

///
unittest {
  mixin(ShowTest!("Container — end-to-end provisioning scenario"));

  ProvisioningConfig cfg;
  cfg.storage = "memory";
  auto c = buildContainer(cfg);
  auto p = c.ports;
  auto t = TenantId("t1");
  auto who = UserId("admin");

  // ── systems ───────────────────────────────────────────────────────────
  SystemSpec hr;
  hr.name = "HR";
  hr.systemType = SystemType.successFactors;
  hr.url = "https://api.sf.com/";
  hr.user = "sfadmin";
  hr.password = "secret";
  hr.properties = [Attribute("sim.users", "8"), Attribute("sim.groups", "2")];
  auto hrResult = p.sourceSystems.create(CreateSystemRequest(t, who, hr));
  assert(hrResult.isSuccess, hrResult.message);
  auto hrId = SourceSystemId(hrResult.id);
  assert(p.sourceSystems.get(t, hrId).url == "https://api.sf.com"); // normalized
  assert(p.sourceSystems.get(t, hrId).status == SystemStatus.configuring);
  assert(p.sourceSystems.create(CreateSystemRequest(t, who, hr)).code == 409); // duplicate name

  SystemSpec csv = hr;
  csv.name = "CSV";
  csv.systemType = SystemType.csv;
  csv.url = "file:///hr.csv";
  assert(p.targetSystems.create(CreateSystemRequest(t, who, csv)).code == 422); // csv cannot be a target

  SystemSpec ias;
  ias.name = "IAS";
  ias.systemType = SystemType.ias;
  ias.url = "https://acme.accounts.ondemand.com";
  ias.authenticationType = AuthenticationType.oauth2ClientCredentials;
  ias.user = "client";
  auto iasResult = p.targetSystems.create(CreateSystemRequest(t, who, ias));
  assert(iasResult.isSuccess, iasResult.message);
  auto iasId = TargetSystemId(iasResult.id);

  // activation tests the connection: IAS has no client secret yet
  assert(p.sourceSystems.activate(t, hrId, who).isSuccess);
  auto failed = p.targetSystems.activate(t, iasId, who);
  assert(failed.code == 409 && failed.message.canFind("401"), failed.message);
  assert(p.targetSystems.get(t, iasId).status == SystemStatus.error);

  // ── job ───────────────────────────────────────────────────────────────
  JobSpec js;
  js.sourceSystemId = hrId;
  js.targetSystemId = iasId;
  js.intervalMinutes = 15;
  auto jobResult = p.jobs.create(CreateJobRequest(t, who, js));
  assert(jobResult.isSuccess, jobResult.message);
  auto jobId = ProvisioningJobId(jobResult.id);
  auto job = p.jobs.get(t, jobId);
  assert(job.name == "HR → IAS (delta)" && job.nextRunAt > 0);
  assert(p.jobs.run(t, jobId, who).code == 409); // target system not active

  UpdateTargetSystemRequest fix;
  fix.tenantId = t;
  fix.actor = who;
  fix.id = iasId;
  fix.spec = decode!SystemSpec(encode(p.targetSystems.get(t, iasId)));
  fix.spec.password = "client-secret";
  assert(p.targetSystems.update(fix).isSuccess);
  assert(p.targetSystems.testConnection(t, iasId, who).isSuccess);
  assert(p.targetSystems.get(t, iasId).status == SystemStatus.active); // recovered from error

  // ── transformations ───────────────────────────────────────────────────
  TransformationSpec ts;
  ts.name = "IAS users";
  ts.systemRole = SystemRole.target;
  ts.systemId = iasId.value;
  ts.scope_ = EntityScope.user;
  ts.mappings = [AttributeMapping("userName", "userName", MappingFunction.none, "", true),
    AttributeMapping("email", "emails[0].value", MappingFunction.lowerCase, "", true),
    AttributeMapping("department", "department"), AttributeMapping("active", "active")];
  ts.conditions = [EntityCondition("department", ConditionOperator.notEquals, "HR")];
  auto tsResult = p.transformations.create(CreateTransformationRequest(t, who, ts));
  assert(tsResult.isSuccess, tsResult.message);
  assert(p.transformations.get(t, TransformationId(tsResult.id)).systemName == "IAS");
  ts.name = "bad";
  ts.systemId = "nope";
  assert(p.transformations.create(CreateTransformationRequest(t, who, ts)).code == 404);

  auto preview = p.transformations.preview(t, TransformationId(tsResult.id), EntityType.user,
    [Attribute("userName", "x"), Attribute("email", "X@Y.COM"), Attribute("department", "IT")]);
  assert(preview.accepted && attributeValue(preview.attributes, "emails[0].value") == "x@y.com");

  // ── first run: 8 users (1 in HR filtered, 1 without e-mail failed) + 2 groups
  auto run = p.jobs.run(t, jobId, who);
  assert(run.isSuccess, run.message);
  job = p.jobs.get(t, jobId);
  assert(job.readCount == 10 && job.createdCount == 8 && job.skippedCount == 1 && job.failedCount == 1, job.statusMessage);
  assert(job.status == JobStatus.failed && job.runCount == 1);
  assert(p.entities.byTarget(t, iasId).length == 8);
  assert(p.logs.byJob(t, jobId).length == 10);
  assert(p.targetSystems.get(t, iasId).entityCount == 8);
  assert(p.sourceSystems.get(t, hrId).lastSyncAt > 0);

  // ── second run (delta): nothing changed → skips, failures stay failures
  p.jobs.run(t, jobId, who);
  job = p.jobs.get(t, jobId);
  assert(job.createdCount == 0 && job.updatedCount == 0 && job.skippedCount == 9 && job.failedCount == 1, job.statusMessage);

  // ── the source changes: fewer users, shifted departments (u3 is now filtered → deleted)
  UpdateSourceSystemRequest change;
  change.tenantId = t;
  change.actor = who;
  change.id = hrId;
  change.spec = decode!SystemSpec(encode(p.sourceSystems.get(t, hrId)));
  change.spec.properties = [Attribute("sim.users", "5"), Attribute("sim.groups", "2"), Attribute("sim.revision", "1")];
  assert(p.sourceSystems.update(change).isSuccess);
  assert(p.sourceSystems.get(t, hrId).status == SystemStatus.active); // properties only: stays active
  p.jobs.run(t, jobId, who);
  job = p.jobs.get(t, jobId);
  assert(job.status == JobStatus.completed && job.createdCount == 1 && job.deletedCount == 3 && job.updatedCount > 0, job.statusMessage);

  // ── simulate changes nothing
  UpdateJobRequest sim;
  sim.tenantId = t;
  sim.actor = who;
  sim.id = jobId;
  sim.spec = decode!JobSpec(encode(job));
  sim.spec.jobType = JobType.simulate;
  assert(p.jobs.update(sim).isSuccess);
  assert(p.jobs.get(t, jobId).name == "HR → IAS (simulate)");
  auto before = p.entities.list(t);
  p.jobs.run(t, jobId, who);
  assert(p.entities.list(t) == before);
  assert(p.logs.byJob(t, jobId)[0].status == LogStatus.skipped || p.logs.byJob(t, jobId)[0].status == LogStatus.simulated);

  // ── schedule, cancel, resume, reset
  auto due = p.jobs.runDue(t, nowStdTime() + 16 * 600_000_000L);
  assert(due.processed == 1, due.messages.join("; "));
  assert(p.jobs.cancel(t, jobId, who).isSuccess);
  assert(p.jobs.run(t, jobId, who).code == 409);
  assert(p.jobs.runDue(t, nowStdTime() + 100 * 600_000_000L).processed == 0);
  assert(p.jobs.resume(t, jobId, who).isSuccess);
  assert(p.jobs.reset(t, jobId, who).isSuccess);
  assert(p.entities.byTarget(t, iasId).length == 0);

  // ── dependencies and statistics
  assert(p.sourceSystems.remove(t, hrId, who).code == 409); // used by the job
  assert(p.targetSystems.remove(t, iasId, who).code == 409); // used by job and transformation
  auto stats = p.statistics.statistics(t);
  assert(stats.sourceSystemsActive == 1 && stats.targetSystemsActive == 1 && stats.jobs == 1 && stats.runs == 5);
  assert(stats.transformations == 1 && stats.logs > 20 && stats.logsFailed >= 2);
  assert(p.logs.purge(t, 0) == stats.logs);
  assert(p.jobs.remove(t, jobId, who).isSuccess);
  assert(p.catalog.systemTypes.length == 8);

  // ── demo data
  auto demo = new DemoDataSeeder(p);
  assert(demo.seed(TenantId("demo")));
  assert(!demo.seed(TenantId("demo")));
  auto demoStats = p.statistics.statistics(TenantId("demo"));
  assert(demoStats.sourceSystemsActive == 2 && demoStats.jobs == 2 && demoStats.jobsCompleted == 1, demoStats.to!string);
  assert(demoStats.provisionedUsers == 6 && demoStats.provisionedGroups == 3, demoStats.to!string);
}
