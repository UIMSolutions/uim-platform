/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of policies, their dynamic rules and their schedules.
module uim.platform.application_autoscaler.ports.usecases.policies;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

interface IManagePolicies : IManageResource!(ScalingPolicy, ScalingPolicyId, PolicyInput) {
  ScalingPolicy activate(TenantId t, ScalingPolicyId id, UserId actor);
  ScalingPolicy deactivate(TenantId t, ScalingPolicyId id, UserId actor);
  /// Copy with all rules and schedules ("" = generated id); the copy is inactive.
  ScalingPolicy copy(TenantId t, ScalingPolicyId id, string newId, UserId actor);
}

interface IManageRules : IManageResource!(ScalingRule, ScalingRuleId, RuleInput) {
  ScalingRule[] listOf(TenantId t, ScalingPolicyId policy);
}

interface IManageSchedules : IManageResource!(ScalingSchedule, ScheduleId, ScheduleInput) {
  ScalingSchedule[] listOf(TenantId t, ScalingPolicyId policy);
  /// True if the schedule applies now (time zone of its policy).
  bool isActive(TenantId t, const ScalingSchedule s);
}
