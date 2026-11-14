/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.container;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application and persistence.
/// Presentation adapters (REST, OData, CLI, GUI) are created by the entry points
/// (app.d, cli.d, gui.d) on top of this container and only see `ports`.
class Container {
  AbapConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  AbapRepositories repositories;
  IAbapEventPublisher publisher;
  SimulatedLandscapeGateway landscape;

  // ── Driving ports ─────────────────────────────────────────────────────
  AbapPorts ports;

  this(AbapConfig config) {
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
      systems = new SystemInstanceRepository(
        store!(SystemInstance, SystemInstanceId)(AbapCollections.systems));
      softwareComponents = new SoftwareComponentRepository(
        store!(SoftwareComponent, SoftwareComponentId)(AbapCollections.softwareComponents));
      communicationArrangements = new CommunicationArrangementRepository(
        store!(CommunicationArrangement, CommunicationArrangementId)(AbapCollections.communicationArrangements));
      serviceBindings = new ServiceBindingRepository(
        store!(ServiceBinding, ServiceBindingId)(AbapCollections.serviceBindings));
      businessUsers = new BusinessUserRepository(
        store!(BusinessUser, BusinessUserId)(AbapCollections.businessUsers));
      businessRoles = new BusinessRoleRepository(
        store!(BusinessRole, BusinessRoleId)(AbapCollections.businessRoles));
      transportRequests = new TransportRequestRepository(
        store!(TransportRequest, TransportRequestId)(AbapCollections.transportRequests));
      applicationJobs = new ApplicationJobRepository(
        store!(ApplicationJob, ApplicationJobId)(AbapCollections.applicationJobs));
    }
    publisher = new LogEventPublisher();
    landscape = new SimulatedLandscapeGateway();
  }

  protected void wireApplication() {
    auto r = repositories;
    ports.systems = new ManageSystemsUseCase(r, publisher);
    ports.softwareComponents = new ManageSoftwareComponentsUseCase(r, publisher);
    ports.communicationArrangements = new ManageCommunicationArrangementsUseCase(r, publisher);
    ports.serviceBindings = new ManageServiceBindingsUseCase(r, publisher);
    ports.businessUsers = new ManageBusinessUsersUseCase(r, publisher);
    ports.businessRoles = new ManageBusinessRolesUseCase(r, publisher);
    ports.transportRequests = new ManageTransportRequestsUseCase(r, publisher);
    ports.applicationJobs = new ManageApplicationJobsUseCase(r, publisher);
    ports.reconciler = new ReconcileUseCase(r, new CascadeDeleter(r), landscape, publisher);
    ports.statistics = new AbapStatisticsService(r);
  }
}

/// Build the full dependency graph.
Container buildContainer(AbapConfig config) {
  return new Container(config);
}

///
unittest {
  mixin(ShowTest!("Container — end-to-end scenario"));

  AbapConfig cfg;
  cfg.storage = "memory";
  auto c = buildContainer(cfg);
  auto p = c.ports;
  auto t = TenantId("t1");
  auto who = UserId("jane");

  // ── provision two systems ──────────────────────────────────────────────
  CreateSystemRequest dev;
  dev.tenantId = t;
  dev.actor = who;
  dev.spec.name = "dev";
  dev.spec.adminEmail = "admin@example.com";
  auto devResult = p.systems.create(dev);
  assert(devResult.isSuccess, devResult.message);
  auto devId = SystemInstanceId(devResult.id);
  assert(p.systems.get(t, devId).sapSystemId == "DEV");
  assert(p.systems.create(dev).code == 409); // duplicate name

  auto prd = dev;
  prd.spec.name = "prd";
  prd.spec.sapSystemId = "SAP"; // reserved
  assert(p.systems.create(prd).code == 422);
  prd.spec.sapSystemId = "";
  auto prdId = SystemInstanceId(p.systems.create(prd).id);

  // development needs an active system
  CreateSoftwareComponentRequest sc;
  sc.tenantId = t;
  sc.actor = who;
  sc.parentId = devId;
  sc.spec.name = "ztravel";
  sc.spec.repositoryUrl = "https://github.com/acme/ztravel.git";
  assert(p.softwareComponents.create(sc).code == 409);

  auto first = p.reconciler.reconcile(t);
  assert(first.advanced == 2, first.changes.join("; "));
  assert(p.systems.get(t, devId).status == SystemStatus.active);
  assert(p.systems.get(t, devId).serviceUrl.startsWith("https://"));

  // ── software component: clone → cloned, pull ───────────────────────────
  auto scResult = p.softwareComponents.create(sc);
  assert(scResult.isSuccess, scResult.message);
  auto scId = SoftwareComponentId(scResult.id);
  assert(p.softwareComponents.get(t, scId).name == "ZTRAVEL");
  assert(p.softwareComponents.pull(t, scId, who).code == 409); // not cloned
  assert(p.softwareComponents.clone(t, scId, who).isSuccess);
  p.reconciler.reconcile(t);
  auto cloned = p.softwareComponents.get(t, scId);
  assert(cloned.status == ComponentStatus.cloned && cloned.currentCommitId.length == 10 && cloned.commitHistory.length == 1);
  assert(p.softwareComponents.checkout(t, scId, "release-1", who).isSuccess);
  p.reconciler.reconcile(t);
  assert(p.softwareComponents.get(t, scId).branch == "release-1");

  // ── roles and users ────────────────────────────────────────────────────
  CreateBusinessRoleRequest role;
  role.tenantId = t;
  role.actor = who;
  role.parentId = devId;
  role.spec.name = "z_br_developer";
  role.spec.businessCatalogs = ["sap_core_bc_dev", "SAP_CORE_BC_DEV"];
  auto roleResult = p.businessRoles.create(role);
  assert(roleResult.isSuccess, roleResult.message);
  auto roleId = BusinessRoleId(roleResult.id);
  assert(p.businessRoles.get(t, roleId).businessCatalogs == ["SAP_CORE_BC_DEV"]);
  role.spec.name = "Z_BR_RESTRICTED";
  role.spec.roleType = RoleType.restricted;
  assert(p.businessRoles.create(role).code == 422); // restricted without restriction types

  CreateBusinessUserRequest user;
  user.tenantId = t;
  user.actor = who;
  user.parentId = devId;
  user.spec.name = "jane.doe";
  user.spec.email = "Jane.Doe@example.com";
  user.spec.roles = ["z_br_developer"];
  auto userResult = p.businessUsers.create(user);
  assert(userResult.isSuccess, userResult.message);
  auto userId = BusinessUserId(userResult.id);
  assert(p.businessUsers.get(t, userId).roles == ["Z_BR_DEVELOPER"]);
  assert(p.businessUsers.get(t, userId).email == "jane.doe@example.com");
  user.spec.name = "john";
  assert(p.businessUsers.create(user).code == 409); // e-mail in use
  user.spec.email = "john@example.com";
  user.spec.roles = ["Z_UNKNOWN"];
  assert(p.businessUsers.create(user).code == 404);

  assert(p.businessRoles.remove(t, roleId, who).code == 409); // in use
  assert(p.businessRoles.userCount(t, roleId) == 1);
  assert(p.businessUsers.lock(t, userId, who).isSuccess);
  assert(p.businessUsers.lock(t, userId, who).code == 409);
  assert(p.businessUsers.unlock(t, userId, who).isSuccess);
  assert(p.businessUsers.unassignRole(t, userId, roleResult.id, who).isSuccess);
  assert(p.businessRoles.remove(t, roleId, who).isSuccess);

  // ── communication arrangement ──────────────────────────────────────────
  CreateCommunicationArrangementRequest ca;
  ca.tenantId = t;
  ca.actor = who;
  ca.parentId = devId;
  ca.spec.name = "S/4HANA Travel";
  ca.spec.scenarioId = CommunicationScenarioId("sap_com_0510");
  ca.spec.communicationSystem = "s4.example.com";
  assert(p.communicationArrangements.create(ca).code == 422); // no user
  ca.spec.communicationUser = "COMM_TRAVEL";
  ca.spec.communicationPassword = "secret";
  auto caResult = p.communicationArrangements.create(ca);
  assert(caResult.isSuccess, caResult.message);
  ca.spec.name = "Duplicate scenario";
  assert(p.communicationArrangements.create(ca).code == 409);

  // ── service binding: unpublished → published, delete needs unpublish ──
  CreateServiceBindingRequest sb;
  sb.tenantId = t;
  sb.actor = who;
  sb.parentId = devId;
  sb.spec.name = "zui_travel_o4";
  sb.spec.serviceDefinition = "zui_travel";
  auto sbResult = p.serviceBindings.create(sb);
  assert(sbResult.isSuccess, sbResult.message);
  auto sbId = ServiceBindingId(sbResult.id);
  assert(p.serviceBindings.get(t, sbId).metadataUrl.endsWith("/srvd_a2x/sap/zui_travel/0001/$metadata"));
  assert(p.serviceBindings.publish(t, sbId, who).isSuccess);
  assert(p.serviceBindings.remove(t, sbId, who).code == 409);

  // ── transport: tasks → release → import into prd ───────────────────────
  CreateTransportRequestRequest tr;
  tr.tenantId = t;
  tr.actor = who;
  tr.parentId = devId;
  tr.spec.description = "Travel app";
  tr.spec.owner = "JANE";
  tr.spec.targetSystemId = prdId;
  auto trResult = p.transportRequests.create(tr);
  assert(trResult.isSuccess, trResult.message);
  auto trId = TransportRequestId(trResult.id);
  auto number = p.transportRequests.get(t, trId).name;
  assert(number == "DEVK900001", number);
  assert(p.transportRequests.release(t, trId, who).code == 409); // no tasks
  assert(p.transportRequests.addTask(t, trId, "", "", ["CLAS ZCL_TRAVEL"], who).code == 422);
  assert(p.transportRequests.addTask(t, trId, "", "", ["R3TR CLAS ZCL_TRAVEL"], who).isSuccess);
  assert(p.transportRequests.release(t, trId, who).code == 409); // task modifiable
  assert(p.transportRequests.releaseTask(t, trId, number ~ "-01", who).isSuccess);
  assert(p.transportRequests.get(t, trId).tasks[0].status == TransportStatus.released); // regression: was lost
  assert(p.transportRequests.release(t, trId, who).isSuccess);
  assert(p.transportRequests.remove(t, trId, who).code == 409);
  assert(p.transportRequests.import_(t, trId, who).isSuccess);
  p.reconciler.reconcile(t);
  assert(p.transportRequests.get(t, trId).status == TransportStatus.imported);

  // ── application job: due → running → completed; recurring reschedules ──
  CreateApplicationJobRequest job;
  job.tenantId = t;
  job.actor = who;
  job.parentId = devId;
  job.spec.name = "Delete logs";
  job.spec.jobTemplateName = "sap_core_delete_logs";
  job.spec.frequency = JobFrequency.daily;
  job.spec.cronExpression = "0 2 * *";
  assert(p.applicationJobs.create(job).code == 422);
  job.spec.cronExpression = "0 2 * * *";
  auto jobResult = p.applicationJobs.create(job);
  assert(jobResult.isSuccess, jobResult.message);
  auto jobId = ApplicationJobId(jobResult.id);
  p.reconciler.reconcile(t);
  assert(p.applicationJobs.get(t, jobId).status == JobStatus.running);
  p.reconciler.reconcile(t);
  auto ran = p.applicationJobs.get(t, jobId);
  assert(ran.status == JobStatus.scheduled && ran.runCount == 1 && ran.scheduledAt > nowStdTime());
  assert(ran.executionHistory[0].status == JobStatus.completed);
  assert(p.applicationJobs.cancel(t, jobId, who).isSuccess);
  assert(p.applicationJobs.reactivate(t, jobId, who).isSuccess);

  // ── statistics ─────────────────────────────────────────────────────────
  auto stats = p.statistics.statistics(t);
  assert(stats.systems == 2 && stats.systemsActive == 2 && stats.componentsCloned == 1);
  assert(stats.transportsImported == 1 && stats.serviceBindingsPublished == 1 && stats.jobsScheduled == 1);

  // ── suspend / resume / upgrade ─────────────────────────────────────────
  assert(p.systems.suspend(t, prdId, who).isSuccess);
  assert(p.systems.upgrade(t, prdId, "2602", who).code == 409);
  assert(p.systems.resume(t, prdId, who).isSuccess);
  assert(p.systems.upgrade(t, prdId, "2402", who).code == 422); // older
  assert(p.systems.upgrade(t, prdId, "2602", who).isSuccess);
  p.reconciler.reconcile(t);
  assert(p.systems.get(t, prdId).status == SystemStatus.active && p.systems.get(t, prdId).softwareVersion == "2602");

  // ── deleting a system is asynchronous and cascades ─────────────────────
  assert(p.systems.remove(t, devId, who).isSuccess);
  assert(p.systems.get(t, devId).status == SystemStatus.deleting);
  assert(p.softwareComponents.create(sc).code == 409); // system being deleted
  p.reconciler.reconcile(t);
  assert(p.systems.get(t, devId).isNull);
  assert(p.softwareComponents.list(t).length == 0 && p.businessUsers.list(t).length == 0);
  assert(p.transportRequests.list(t).length == 0 && p.applicationJobs.list(t).length == 0);
  assert(c.landscape.operations.any!(o => o.verb == "deprovision"));
}
