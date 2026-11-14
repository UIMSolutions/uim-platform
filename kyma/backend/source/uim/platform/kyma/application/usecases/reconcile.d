/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.usecases.reconcile;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Interactor: one reconciliation pass over a tenant (simulated Kyma control
/// plane). Expired trial/free runtimes are deleted; workloads only progress
/// on operational runtimes; bindings wait for their instance.
class ReconcileUseCase : IReconcileUseCase {
  protected KymaRepositories repos;
  protected CascadeDeleter cascade;
  protected IKymaEventPublisher publisher;

  this(KymaRepositories repos, CascadeDeleter cascade, IKymaEventPublisher publisher) {
    this.repos = repos;
    this.cascade = cascade;
    this.publisher = publisher;
  }

  ReconcileReport reconcile(TenantId tenantId) {
    ReconcileReport report;
    report.tenantId = tenantId;
    auto now = nowStdTime();

    foreach (env; repos.environments.findByTenant(tenantId)) {
      report.examined++;
      if (env.isExpired(now)) {
        cascade.clearEnvironment(tenantId, env.id);
        repos.environments.remove(env);
        note(report, "Environment " ~ env.name ~ ": expired and deleted");
        continue;
      }
      step(report, repos.environments, env, "Environment " ~ env.name, (ref KymaEnvironment e) => advance(e));
      env = repos.environments.findById(tenantId, env.id); // the state after this pass
      if (!env.isOperational)
        continue;

      auto e = env.id;
      foreach (m; repos.modules.findByEnvironment(tenantId, e))
        step(report, repos.modules, m, "Module " ~ m.name, (ref KymaModule x) => advance(x));
      foreach (f; repos.functions.findByEnvironment(tenantId, e))
        step(report, repos.functions, f, "Function " ~ f.namespaceName ~ "/" ~ f.name, (ref ServerlessFunction x) => advance(x));
      foreach (r; repos.apiRules.findByEnvironment(tenantId, e))
        step(report, repos.apiRules, r, "API rule " ~ r.namespaceName ~ "/" ~ r.name, (ref ApiRule x) => advance(x));
      foreach (s; repos.serviceInstances.findByEnvironment(tenantId, e))
        step(report, repos.serviceInstances, s, "Service instance " ~ s.namespaceName ~ "/" ~ s.name,
          (ref ServiceInstance x) => advance(x));
      foreach (b; repos.serviceBindings.findByEnvironment(tenantId, e)) {
        auto instanceStatus = repos.serviceInstances.findById(tenantId, b.serviceInstanceId).status;
        step(report, repos.serviceBindings, b, "Service binding " ~ b.namespaceName ~ "/" ~ b.name,
          (ref ServiceBinding x) => advance(x, instanceStatus));
      }
      foreach (s; repos.subscriptions.findByEnvironment(tenantId, e))
        step(report, repos.subscriptions, s, "Subscription " ~ s.namespaceName ~ "/" ~ s.name,
          (ref EventSubscription x) => advance(x));
      foreach (a; repos.applications.findByEnvironment(tenantId, e))
        step(report, repos.applications, a, "Application " ~ a.name, (ref KymaApplication x) => advance(x));
    }

    if (report.advanced > 0) {
      auto payload = Json.emptyObject;
      payload["tenantId"] = tenantId.value;
      payload["advanced"] = report.advanced;
      publisher.publish("kyma.reconciled", payload);
    }
    return report;
  }

  private void step(TRepo, TEntity)(ref ReconcileReport report, TRepo repo, TEntity entity, string label,
      scope bool delegate(ref TEntity) @safe advanceFn) {
    static if (!is(TEntity == KymaEnvironment))
      report.examined++;
    auto before = enumText(entity.status);
    if (!advanceFn(entity))
      return;
    entity.updatedAt = nowStdTime();
    repo.update(entity);
    note(report, label ~ ": " ~ before ~ " → " ~ enumText(entity.status));
  }

  private static void note(ref ReconcileReport report, string change) {
    report.advanced++;
    report.changes ~= change;
  }
}
