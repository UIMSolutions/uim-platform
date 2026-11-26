/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.application_autoscaler.persistence.repositories.repositories;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class AppBindingRepository : DocumentRepository!(AppBinding, AppBindingId), IAppBindingRepository {
  this(IDocumentStore store) {
    super(store, Collections.bindings);
  }
}

class ScalingPolicyRepository : DocumentRepository!(ScalingPolicy, ScalingPolicyId), IScalingPolicyRepository {
  this(IDocumentStore store) {
    super(store, Collections.policies);
  }
}

class ScalingRuleRepository : DocumentRepository!(ScalingRule, ScalingRuleId), IScalingRuleRepository {
  this(IDocumentStore store) {
    super(store, Collections.rules);
  }
}

class ScheduleRepository : DocumentRepository!(ScalingSchedule, ScheduleId), IScheduleRepository {
  this(IDocumentStore store) {
    super(store, Collections.schedules);
  }
}

class MetricSampleRepository : DocumentRepository!(MetricSample, MetricSampleId), IMetricSampleRepository {
  this(IDocumentStore store) {
    super(store, Collections.metrics);
  }

  size_t removeOlderThan(TenantId t, long cutoff) {
    return removeBefore(t, "measuredAt", cutoff);
  }
}

class ScalingEventRepository : DocumentRepository!(ScalingEvent, ScalingEventId), IScalingEventRepository {
  this(IDocumentStore store) {
    super(store, Collections.events);
  }

  size_t removeOlderThan(TenantId t, long cutoff) {
    return removeBefore(t, "createdAt", cutoff);
  }
}

class UserAccountRepository : DocumentRepository!(UserAccount, UserAccountId), IUserAccountRepository {
  this(IDocumentStore store) {
    super(store, Collections.users);
  }
}

/// All repositories over one document store.
AasRepositories createRepositories(IDocumentStore store) {
  AasRepositories r;
  r.bindings = new AppBindingRepository(store);
  r.policies = new ScalingPolicyRepository(store);
  r.rules = new ScalingRuleRepository(store);
  r.schedules = new ScheduleRepository(store);
  r.metrics = new MetricSampleRepository(store);
  r.events = new ScalingEventRepository(store);
  r.users = new UserAccountRepository(store);
  return r;
}
