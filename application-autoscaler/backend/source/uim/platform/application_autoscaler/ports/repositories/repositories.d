/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.application_autoscaler.ports.repositories.repositories;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface IAppBindingRepository : IAasRepository!(AppBinding, AppBindingId) {
}

interface IScalingPolicyRepository : IAasRepository!(ScalingPolicy, ScalingPolicyId) {
}

interface IScalingRuleRepository : IAasRepository!(ScalingRule, ScalingRuleId) {
}

interface IScheduleRepository : IAasRepository!(ScalingSchedule, ScheduleId) {
}

interface IMetricSampleRepository : IAasRepository!(MetricSample, MetricSampleId) {
  /// Remove the samples measured before the cut-off; returns the count.
  size_t removeOlderThan(TenantId t, long cutoff);
}

interface IScalingEventRepository : IAasRepository!(ScalingEvent, ScalingEventId) {
  /// Remove the events created before the cut-off; returns the count.
  size_t removeOlderThan(TenantId t, long cutoff);
}

interface IUserAccountRepository : IAasRepository!(UserAccount, UserAccountId) {
}

/// All repositories (passed to the interactors as one bundle).
struct AasRepositories {
  IAppBindingRepository bindings;
  IScalingPolicyRepository policies;
  IScalingRuleRepository rules;
  IScheduleRepository schedules;
  IMetricSampleRepository metrics;
  IScalingEventRepository events;
  IUserAccountRepository users;
}
