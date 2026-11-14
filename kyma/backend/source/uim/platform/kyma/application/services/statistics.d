/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.services.statistics;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Application service: aggregated figures of a tenant.
class KymaStatisticsService : IKymaStatisticsService {
  protected KymaRepositories repos;

  this(KymaRepositories repos) {
    this.repos = repos;
  }

  KymaStatistics statistics(TenantId tenantId) {
    KymaStatistics s;
    s.tenantId = tenantId;
    int pending;

    foreach (e; repos.environments.findByTenant(tenantId)) {
      s.environments++;
      if (e.status == EnvironmentStatus.running)
        s.environmentsRunning++;
      if (e.status.isTransitional)
        pending++;
      if (e.expiresAt > 0 && (s.nextExpiryAt == 0 || e.expiresAt < s.nextExpiryAt))
        s.nextExpiryAt = e.expiresAt;
    }
    s.namespaces = cast(int) repos.namespaces.countByTenant(tenantId);
    foreach (f; repos.functions.findByTenant(tenantId)) {
      s.functions++;
      if (f.status == FunctionStatus.running)
        s.functionsRunning++;
      else if (f.status == FunctionStatus.error)
        s.functionsFailed++;
      else
        pending++;
    }
    foreach (r; repos.apiRules.findByTenant(tenantId)) {
      s.apiRules++;
      if (r.status == ApiRuleStatus.notReady)
        pending++;
    }
    foreach (i; repos.serviceInstances.findByTenant(tenantId)) {
      s.serviceInstances++;
      if (i.status == ServiceInstanceStatus.creating || i.status == ServiceInstanceStatus.updating)
        pending++;
    }
    foreach (b; repos.serviceBindings.findByTenant(tenantId)) {
      s.serviceBindings++;
      if (b.status == ServiceBindingStatus.creating)
        pending++;
    }
    foreach (sub; repos.subscriptions.findByTenant(tenantId)) {
      s.subscriptions++;
      if (sub.status == SubscriptionStatus.paused)
        s.subscriptionsPaused++;
      if (sub.status == SubscriptionStatus.pending)
        pending++;
    }
    foreach (m; repos.modules.findByTenant(tenantId)) {
      if (m.status == ModuleStatus.enabled)
        s.modulesEnabled++;
      if (m.status == ModuleStatus.installing || m.status == ModuleStatus.uninstalling)
        pending++;
    }
    foreach (a; repos.applications.findByTenant(tenantId)) {
      s.applications++;
      if (a.status == AppConnectivityStatus.connected)
        s.applicationsConnected++;
      if (a.status == AppConnectivityStatus.pairing)
        pending++;
    }
    s.pendingReconciliation = pending;
    return s;
  }
}
