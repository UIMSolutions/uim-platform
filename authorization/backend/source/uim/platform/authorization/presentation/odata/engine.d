/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves the
/// OData controller, the JSON API, the vibe.d REST interface, the dashboard,
/// the CLI and the GUI.
module uim.platform.authorization.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates AuthorizationException.
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

ODataEngine authorizationEngine(AuthorizationPorts ports, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(authorizationModel());

  string[string] applicationNames(TenantId t) {
    string[string] names;
    foreach (a; ports.applications.listApplications(t))
      names[a.id.value] = a.name;
    return names;
  }

  // ── Applications ──────────────────────────────────────────────────────────
  auto applications = new DelegateEntitySetProvider;
  Json applicationOf(TenantId t, ManagedApplication e) {
    return applicationRow(e, ports.apis.listApis(t, e.id).length, ports.policies.listPolicies(t, e.id).length);
  }

  applications.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    size_t[string] apis, policies;
    foreach (a; ports.apis.listApis(t))
      apis[a.applicationId.value]++;
    foreach (p; ports.policies.listPolicies(t))
      policies[p.applicationId.value]++;
    Json[] rows;
    foreach (e; ports.applications.listApplications(t))
      rows ~= applicationRow(e, apis.get(e.id.value, 0), policies.get(e.id.value, 0));
    return rows;
  };
  applications.onGet = (const RequestContext ctx, string key) =>
    applicationOf(tenantOf(ctx), ports.applications.getApplication(tenantOf(ctx), ManagedApplicationId(key)));
  applications.onCreate = (const RequestContext ctx, Json p) =>
    applicationOf(tenantOf(ctx), ports.applications.createApplication(createApplicationRequest(ctx, p)));
  applications.onUpdate = (const RequestContext ctx, string key, Json p) =>
    applicationOf(tenantOf(ctx), ports.applications.updateApplication(updateApplicationRequest(ctx, key, p)));
  applications.onRemove = (const RequestContext ctx, string key) {
    ports.applications.deleteApplication(tenantOf(ctx), ManagedApplicationId(key));
  };

  // ── Application APIs ──────────────────────────────────────────────────────
  auto apis = new DelegateEntitySetProvider;
  Json apiOf(TenantId t, ApplicationApi e) {
    return apiRow(e, ports.applications.getApplication(t, e.applicationId).name);
  }

  apis.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto names = applicationNames(t);
    Json[] rows;
    foreach (e; ports.apis.listApis(t))
      rows ~= apiRow(e, names.get(e.applicationId.value, ""));
    return rows;
  };
  apis.onGet = (const RequestContext ctx, string key) => apiOf(tenantOf(ctx), ports.apis.getApi(tenantOf(ctx),
      ApplicationApiId(key)));
  apis.onCreate = (const RequestContext ctx, Json p) => apiOf(tenantOf(ctx), ports.apis.createApi(createApiRequest(ctx, p)));
  apis.onUpdate = (const RequestContext ctx, string key, Json p) => apiOf(tenantOf(ctx),
    ports.apis.updateApi(updateApiRequest(ctx, key, p)));
  apis.onRemove = (const RequestContext ctx, string key) {
    ports.apis.deleteApi(tenantOf(ctx), ApplicationApiId(key));
  };

  // ── Policies ──────────────────────────────────────────────────────────────
  auto policies = new DelegateEntitySetProvider;
  Json policyOf(TenantId t, AuthorizationPolicy e) {
    return policyRow(e, ports.applications.getApplication(t, e.applicationId).name,
      ports.assignments.listAssignments(t, e.id).length);
  }

  policies.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto names = applicationNames(t);
    size_t[string] assigned;
    foreach (a; ports.assignments.listAssignments(t))
      assigned[a.policyId.value]++;
    Json[] rows;
    foreach (e; ports.policies.listPolicies(t))
      rows ~= policyRow(e, names.get(e.applicationId.value, ""), assigned.get(e.id.value, 0));
    return rows;
  };
  policies.onGet = (const RequestContext ctx, string key) => policyOf(tenantOf(ctx),
    ports.policies.getPolicy(tenantOf(ctx), PolicyId(key)));
  policies.onCreate = (const RequestContext ctx, Json p) => policyOf(tenantOf(ctx),
    ports.policies.createPolicy(createPolicyRequest(ctx, p)));
  policies.onUpdate = (const RequestContext ctx, string key, Json p) => policyOf(tenantOf(ctx),
    ports.policies.updatePolicy(updatePolicyRequest(ctx, key, p)));
  policies.onRemove = (const RequestContext ctx, string key) {
    ports.policies.deletePolicy(tenantOf(ctx), PolicyId(key));
  };

  // ── Assignments ───────────────────────────────────────────────────────────
  auto assignments = new DelegateEntitySetProvider;
  Json assignmentOf(TenantId t, PolicyAssignment e) {
    auto p = ports.policies.getPolicy(t, e.policyId);
    return assignmentRow(e, p, ports.applications.getApplication(t, p.applicationId).name);
  }

  assignments.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto names = applicationNames(t);
    AuthorizationPolicy[string] byId;
    foreach (p; ports.policies.listPolicies(t))
      byId[p.id.value] = p;
    Json[] rows;
    foreach (e; ports.assignments.listAssignments(t)) {
      auto p = byId.get(e.policyId.value, AuthorizationPolicy.init);
      rows ~= assignmentRow(e, p, names.get(p.applicationId.value, ""));
    }
    return rows;
  };
  assignments.onGet = (const RequestContext ctx, string key) => assignmentOf(tenantOf(ctx),
    ports.assignments.getAssignment(tenantOf(ctx), PolicyAssignmentId(key)));
  assignments.onCreate = (const RequestContext ctx, Json p) => assignmentOf(tenantOf(ctx),
    ports.assignments.assignPolicy(createAssignmentRequest(ctx, p)));
  assignments.onUpdate = (const RequestContext ctx, string key, Json p) => assignmentOf(tenantOf(ctx),
    ports.assignments.updateAssignment(updateAssignmentRequest(ctx, key, p)));
  assignments.onRemove = (const RequestContext ctx, string key) {
    ports.assignments.revokeAssignment(tenantOf(ctx), PolicyAssignmentId(key));
  };

  // ── Decisions (read-only log, newest first) ───────────────────────────────
  auto decisions = new DelegateEntitySetProvider;
  decisions.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto names = applicationNames(t);
    Json[] rows;
    foreach_reverse (e; ports.decisions.listDecisions(t))
      rows ~= decisionRow(e, names.get(e.applicationId.value, ""));
    return rows;
  };
  decisions.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    auto e = ports.decisions.getDecision(t, DecisionRecordId(key));
    return decisionRow(e, applicationNames(t).get(e.applicationId.value, ""));
  };

  // ── Statistics (singleton) ────────────────────────────────────────────────
  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx)));

  engine.provide("Applications", new PortProvider(applications))
    .provide("ApplicationApis", new PortProvider(apis))
    .provide("Policies", new PortProvider(policies))
    .provide("Assignments", new PortProvider(assignments))
    .provide("Decisions", new PortProvider(decisions))
    .provide("Statistics", new PortProvider(statistics));

  // ── Actions ───────────────────────────────────────────────────────────────
  engine.handle("EvaluateAuthorization", (const RequestContext ctx, Json p) => translated!Json(
      () => authorizationResultRow(ports.evaluation.evaluate(evaluateRequest(ctx, p)))));
  engine.handle("SeedBasePolicies", (const RequestContext ctx, Json p) => translated!Json(() {
      auto app = ports.applications.resolveApplication(tenantOf(ctx), textOf(p, "application"));
      auto seeded = ports.policies.seedBasePolicies(tenantOf(ctx), app.id, actorOf(ctx));
      return actionResultRow(app.id.value, countOf(seeded.length, "base policy") ~ " in '" ~ app.name ~ "'",
        seeded.length);
    }));
  engine.handle("EnablePolicy", (const RequestContext ctx, Json p) => translated!Json(() {
      auto policy = ports.policies.enablePolicy(tenantOf(ctx), PolicyId(textOf(p, "id")), actorOf(ctx));
      return actionResultRow(policy.id.value, "Policy '" ~ policy.name ~ "' enabled", 1);
    }));
  engine.handle("DisablePolicy", (const RequestContext ctx, Json p) => translated!Json(() {
      auto policy = ports.policies.disablePolicy(tenantOf(ctx), PolicyId(textOf(p, "id")), actorOf(ctx));
      return actionResultRow(policy.id.value, "Policy '" ~ policy.name ~ "' disabled", 1);
    }));
  engine.handle("PruneDecisions", (const RequestContext ctx, Json p) => translated!Json(() {
      auto removed = ports.decisions.pruneDecisions(tenantOf(ctx), cast(int) longOf(p, "olderThanDays", 90));
      return actionResultRow("", countOf(removed, "decision") ~ " removed", removed);
    }));
  engine.handle("SeedDemoData", (const RequestContext ctx, Json p) => translated!Json(() {
      auto r = ports.demoData.seed(tenantOf(ctx), actorOf(ctx));
      return actionResultRow(ctx.tenantId, format("Seeded %s, %s, %s and %s", countOf(r.applications, "application"),
        countOf(r.apis, "API"), countOf(r.policies, "policy").replace("policys", "policies"),
        countOf(r.assignments, "assignment")), r.applications + r.apis + r.policies + r.assignments);
    }));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
