/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// KPIs of a tenant (Fiori header, CLI "stats").
module uim.platform.application_autoscaler.application.services.statistics;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class AasStatisticsService : IAasStatisticsService {
  protected AasRepositories repos;
  protected IClock clock;

  this(AasRepositories repos, IClock clock) {
    this.repos = repos;
    this.clock = clock;
  }

  AasStatistics compute(TenantId t) {
    AasStatistics s;
    s.tenantId = t;
    auto now = clock.now;
    auto dayAgo = plusDays(now, -1);
    foreach (b; repos.bindings.findAll(t)) {
      s.bindings++;
      s.instances += b.currentInstances;
      if (b.isAutoscaled)
        s.autoscaledBindings++;
      if (b.status == BindingStatus.suspended)
        s.suspendedBindings++;
    }
    string[string] zones;
    foreach (p; repos.policies.findAll(t)) {
      s.policies++;
      if (p.isActive)
        s.activePolicies++;
      zones[p.id.value] = p.timezone;
    }
    s.rules = repos.rules.countAll(t);
    foreach (sc; repos.schedules.findAll(t)) {
      s.schedules++;
      try {
        if (sc.isActiveAt(now, zones.get(sc.policyId.value, "UTC")))
          s.activeSchedules++;
      } catch (AutoscalerException) {
      }
    }
    foreach (m; repos.metrics.findAll(t)) {
      s.metricSamples++;
      if (m.measuredAt >= dayAgo)
        s.samplesLast24h++;
    }
    foreach (e; repos.events.findAll(t)) {
      s.scalingEvents++;
      if (e.createdAt < dayAgo)
        continue;
      if (e.status == ScalingStatus.failed)
        s.failedLast24h++;
      else if (e.status == ScalingStatus.succeeded && e.direction == ScalingDirection.scaleOut)
        s.scaleOutsLast24h++;
      else if (e.status == ScalingStatus.succeeded && e.direction == ScalingDirection.scaleIn)
        s.scaleInsLast24h++;
    }
    s.users = repos.users.countAll(t);
    return s;
  }
}
