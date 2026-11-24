/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST API, the CLI and the GUI.
module uim.platform.data_retention.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates DataRetentionException.
class PortProvider : IEntitySetProvider {
  protected DelegateEntitySetProvider inner;

  this(DelegateEntitySetProvider inner) {
    this.inner = inner;
  }

  Json[] list(const RequestContext ctx) {
    return translated!(Json[])(() => inner.list(ctx));
  }

  Json get(const RequestContext ctx, string key) {
    return translated!Json(() => inner.get(ctx, key));
  }

  Json create(const RequestContext ctx, Json payload) {
    return translated!Json(() => inner.create(ctx, payload));
  }

  Json update(const RequestContext ctx, string key, Json payload) {
    return translated!Json(() => inner.update(ctx, key, payload));
  }

  void remove(const RequestContext ctx, string key) {
    translated!void(() { inner.remove(ctx, key); });
  }
}

/// A provider over a maintained resource port; rows(t, entities) builds the
/// rows of many entities at once (derived facts are computed once per call).
PortProvider resourceProvider(TEntity, TId, TInput, R)(IManageResource!(TEntity, TId, TInput) port, R rows) {
  auto p = new DelegateEntitySetProvider;
  p.onList = (const RequestContext ctx) => rows(tenantOf(ctx), port.list(tenantOf(ctx)));
  p.onGet = (const RequestContext ctx, string key) => rows(tenantOf(ctx), [port.get(tenantOf(ctx), TId(key))])[0];
  p.onCreate = (const RequestContext ctx, Json payload) => rows(tenantOf(ctx), [
    port.create(createCommandOf!TInput(ctx, payload))
  ])[0];
  p.onUpdate = (const RequestContext ctx, string key, Json payload) => rows(tenantOf(ctx), [
    port.update(updateCommandOf!TInput(ctx, key, payload))
  ])[0];
  p.onRemove = (const RequestContext ctx, string key) { port.remove(tenantOf(ctx), TId(key), actorOf(ctx)); };
  return new PortProvider(p);
}

ODataEngine dataRetentionEngine(DrPorts ports, IClock clock, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(dataRetentionModel());

  // ── row builders with derived facts ─────────────────────────────────────
  Json[] groupRows(TenantId t, ApplicationGroup[] groups) {
    auto purposes = ports.lookups.businessPurposeCounts(t, "applicationGroupId");
    auto subjects = ports.lookups.dataSubjectCounts(t, "applicationGroupId");
    return groups.map!(g => applicationGroupRow(g, purposes.get(g.id.value, 0), subjects.get(g.id.value, 0))).array;
  }

  Json[] purposeRows(TenantId t, BusinessPurpose[] purposes) {
    auto grounds = ports.legalGrounds.list(t);
    auto residence = ports.residenceRules.list(t);
    auto retention = ports.retentionRules.list(t);
    auto subjects = ports.lookups.dataSubjectCounts(t, "businessPurposeId");
    Json[] rows;
    foreach (p; purposes) {
      PurposeFacts f;
      f.dataSubjects = subjects.get(p.id.value, 0);
      string[] rules;
      foreach (g; grounds.filter!(g => g.businessPurposeId == p.id)) {
        f.legalGrounds++;
        auto res = residence.find!(r => r.legalGroundId == g.id);
        auto ret = retention.find!(r => r.legalGroundId == g.id);
        if (g.active && !res.empty && res.front.active)
          f.completeLegalGrounds++;
        if (g.active)
          rules ~= g.name ~ ": " ~ (res.empty ? "–" : res.front.period.text) ~ " + " ~ (ret.empty ? "0 days" : ret.front.period.text);
      }
      f.rulesText = rules.join("; ");
      rows ~= businessPurposeRow(p, f);
    }
    return rows;
  }

  Json[] groundRows(TenantId t, LegalGround[] grounds) {
    auto residence = ports.residenceRules.list(t);
    auto retention = ports.retentionRules.list(t);
    Json[] rows;
    foreach (g; grounds) {
      auto res = residence.find!(r => r.legalGroundId == g.id);
      auto ret = retention.find!(r => r.legalGroundId == g.id);
      rows ~= legalGroundRow(g, res.empty ? ResidenceRule.init : res.front, ret.empty ? RetentionRule.init : ret.front);
    }
    return rows;
  }

  Json purposeRow(TenantId t, BusinessPurpose p) {
    return purposeRows(t, [p])[0];
  }

  // ── entity sets ─────────────────────────────────────────────────────────
  engine.provide("ApplicationGroups", resourceProvider(ports.applicationGroups, &groupRows));
  engine.provide("LegalEntities", resourceProvider(ports.legalEntities,
      (TenantId t, LegalEntity[] es) => es.map!(e => legalEntityRow(e)).array));
  engine.provide("DataSubjectRoles", resourceProvider(ports.dataSubjectRoles,
      (TenantId t, DataSubjectRole[] rs) => rs.map!(r => dataSubjectRoleRow(r)).array));
  engine.provide("BusinessPurposes", resourceProvider(
      cast(IManageResource!(BusinessPurpose, BusinessPurposeId, BusinessPurposeInput)) ports.businessPurposes, &purposeRows));
  engine.provide("LegalGrounds", resourceProvider(ports.legalGrounds, &groundRows));
  engine.provide("ResidenceRules", resourceProvider(ports.residenceRules,
      (TenantId t, ResidenceRule[] rs) => rs.map!(r => residenceRuleRow(r)).array));
  engine.provide("RetentionRules", resourceProvider(ports.retentionRules,
      (TenantId t, RetentionRule[] rs) => rs.map!(r => retentionRuleRow(r)).array));
  engine.provide("DataSubjects", resourceProvider(
      cast(IManageResource!(DataSubject, DataSubjectId, DataSubjectInput)) ports.dataSubjects,
      (TenantId t, DataSubject[] ss) => ss.map!(s => dataSubjectRow(s)).array));

  auto requests = new DelegateEntitySetProvider;
  requests.onList = (const RequestContext ctx) => ports.deletionRequests.list(tenantOf(ctx)).map!(r => deletionRequestRow(r)).array;
  requests.onGet = (const RequestContext ctx, string key) => deletionRequestRow(
    ports.deletionRequests.get(tenantOf(ctx), DeletionRequestId(key)));
  requests.onCreate = (const RequestContext ctx, Json p) => deletionRequestRow(
    ports.deletionRequests.create(deletionRequestCommand(ctx, p)));
  requests.onRemove = (const RequestContext ctx, string key) {
    ports.deletionRequests.remove(tenantOf(ctx), DeletionRequestId(key), actorOf(ctx));
  };
  engine.provide("DeletionRequests", new PortProvider(requests));

  auto jobs = new DelegateEntitySetProvider;
  jobs.onList = (const RequestContext ctx) => ports.archivingJobs.list(tenantOf(ctx)).map!(j => archivingJobRow(j)).array;
  jobs.onGet = (const RequestContext ctx, string key) => archivingJobRow(ports.archivingJobs.get(tenantOf(ctx), ArchivingJobId(key)));
  jobs.onCreate = (const RequestContext ctx, Json p) => archivingJobRow(ports.archivingJobs.create(archivingJobCommand(ctx, p)));
  jobs.onRemove = (const RequestContext ctx, string key) {
    ports.archivingJobs.remove(tenantOf(ctx), ArchivingJobId(key), actorOf(ctx));
  };
  engine.provide("ArchivingJobs", new PortProvider(jobs));

  auto users = new DelegateEntitySetProvider;
  users.onList = (const RequestContext ctx) {
    auto now = clock.now;
    return ports.users.listUsers(tenantOf(ctx)).map!(u => userRow(u, now)).array;
  };
  users.onGet = (const RequestContext ctx, string key) => userRow(ports.users.getUser(tenantOf(ctx), UserAccountId(key)), clock.now);
  users.onCreate = (const RequestContext ctx, Json p) => userRow(ports.users.createUser(createUserRequest(ctx, p)), clock.now);
  users.onUpdate = (const RequestContext ctx, string key, Json p) => userRow(
    ports.users.updateUser(updateUserRequest(ctx, key, p)), clock.now);
  users.onRemove = (const RequestContext ctx, string key) {
    ports.users.deleteUser(tenantOf(ctx), UserAccountId(key), actorOf(ctx));
  };
  engine.provide("Users", new PortProvider(users));

  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx)));
  engine.provide("Statistics", new PortProvider(statistics));

  // ── actions ─────────────────────────────────────────────────────────────
  void action(string name, Json delegate(const RequestContext, Json) @safe handler) {
    engine.handle(name, (const RequestContext ctx, Json p) => translated!Json(() => handler(ctx, p)));
  }

  action("ActivateBusinessPurpose", (ctx, p) => purposeRow(tenantOf(ctx),
      ports.businessPurposes.activate(tenantOf(ctx), BusinessPurposeId(idParam(p)), actorOf(ctx))));
  action("DeactivateBusinessPurpose", (ctx, p) => purposeRow(tenantOf(ctx),
      ports.businessPurposes.deactivate(tenantOf(ctx), BusinessPurposeId(idParam(p)), actorOf(ctx))));
  action("DeprecateBusinessPurpose", (ctx, p) => purposeRow(tenantOf(ctx),
      ports.businessPurposes.deprecate(tenantOf(ctx), BusinessPurposeId(idParam(p)), actorOf(ctx))));
  action("BlockDataSubject", (ctx, p) => dataSubjectRow(
      ports.dataSubjects.block(tenantOf(ctx), DataSubjectId(idParam(p)), actorOf(ctx))));
  action("SetLegalHold", (ctx, p) => dataSubjectRow(ports.dataSubjects.setLegalHold(tenantOf(ctx),
      DataSubjectId(idParam(p)), boolOf(p, "legalHold"), textOf(p, "reason"), actorOf(ctx))));
  action("CheckEndOfPurpose", (ctx, p) {
    EndOfPurposeCheckRequest r;
    r.tenantId = tenantOf(ctx);
    r.actor = actorOf(ctx);
    r.applicationGroupId = ApplicationGroupId(textOf(p, "applicationGroupId").strip);
    r.simulate = boolOf(p, "simulate");
    return checkResultRow(ports.checks.checkEndOfPurpose(r));
  });
  action("SimulateRetention", (ctx, p) {
    SimulationRequest r;
    r.tenantId = tenantOf(ctx);
    r.businessPurposeId = BusinessPurposeId(idParam(p, "businessPurposeId"));
    r.legalGroundId = LegalGroundId(textOf(p, "legalGroundId").strip);
    r.referenceDate = parseIsoTime(textOf(p, "referenceDate"), "referenceDate");
    return simulationRow(ports.checks.simulate(r), r.businessPurposeId.value, r.referenceDate);
  });
  action("ProcessDeletionRequest", (ctx, p) => deletionRequestRow(
      ports.deletionRequests.process(tenantOf(ctx), DeletionRequestId(idParam(p)), actorOf(ctx))));
  action("CancelDeletionRequest", (ctx, p) => deletionRequestRow(
      ports.deletionRequests.cancel(tenantOf(ctx), DeletionRequestId(idParam(p)), actorOf(ctx))));
  action("ProcessPendingRequests", (ctx, p) => runSummaryRow(ports.deletionRequests.processPending(tenantOf(ctx), actorOf(ctx))));
  action("RunArchivingJob", (ctx, p) => archivingJobRow(
      ports.archivingJobs.run(tenantOf(ctx), ArchivingJobId(idParam(p)), actorOf(ctx))));
  action("CancelArchivingJob", (ctx, p) => archivingJobRow(
      ports.archivingJobs.cancel(tenantOf(ctx), ArchivingJobId(idParam(p)), actorOf(ctx))));
  action("RunDueJobs", (ctx, p) => runSummaryRow(ports.archivingJobs.runDue(tenantOf(ctx), actorOf(ctx))));
  action("SeedDemoData", (ctx, p) => seedRow(seedDemoData(ports, clock, tenantOf(ctx), actorOf(ctx))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
