/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.application.usecases.manage.policies;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

class ManageScalingPoliciesUseCase {
  private ScalingPolicyRepository repo;

  this(ScalingPolicyRepository repo) {
    this.repo = repo;
  }

  CommandResult createPolicy(CreateScalingPolicyRequest r) {
    
    auto id = generateId();
    auto now = currentTimestamp;

    ScalingPolicyEntity policy;
    policy.initEntity(r.tenantId, r.createdBy);

    policy.id               = id;
    policy.appId            = r.appId;
    policy.instanceMinCount = r.instanceMinCount > 0 ? r.instanceMinCount : 1;
    policy.instanceMaxCount = r.instanceMaxCount > policy.instanceMinCount
      ? r.instanceMaxCount : policy.instanceMinCount + 1;
    policy.status           = PolicyStatus.active;
    policy.timezone         = r.timezone.length > 0 ? r.timezone : "UTC";
    policy.customMetricAllowFrom = r.customMetricAllowFrom == "bound_app"
      ? MetricAllowFrom.boundApp : MetricAllowFrom.sameApp;

    foreach (rr; r.scalingRules) {
      ScalingRuleEntity rule;
      rule.id                = generateId();
      rule.metricType        = toMetricType(rr.metricType);
      rule.customMetricName  = rr.customMetricName;
      rule.threshold         = rr.threshold;
      rule.operator          = toScalingOperator(rr.operator);
      rule.breachDurationSecs= rr.breachDurationSecs > 0 ? rr.breachDurationSecs : 120;
      rule.coolDownSecs      = rr.coolDownSecs > 0 ? rr.coolDownSecs : 300;
      rule.adjustment        = rr.adjustment;
      policy.scalingRules   ~= rule;
    }

    foreach (rs; r.recurringSchedules) {
      RecurringScheduleEntity sched;
      sched.id                       = generateId();
      sched.startTime                = rs.startTime;
      sched.endTime                  = rs.endTime;
      sched.startDate                = rs.startDate;
      sched.endDate                  = rs.endDate;
      sched.daysOfWeek               = rs.daysOfWeek.dup;
      sched.daysOfMonth              = rs.daysOfMonth.dup;
      sched.instanceMinCount         = rs.instanceMinCount;
      sched.instanceMaxCount         = rs.instanceMaxCount;
      sched.initialMinInstanceCount  = rs.initialMinInstanceCount;
      policy.recurringSchedules     ~= sched;
    }

    foreach (sd; r.specificDateSchedules) {
      SpecificDateScheduleEntity sched;
      sched.id                       = generateId();
      sched.startDateTime            = sd.startDateTime;
      sched.endDateTime              = sd.endDateTime;
      sched.instanceMinCount         = sd.instanceMinCount;
      sched.instanceMaxCount         = sd.instanceMaxCount;
      sched.initialMinInstanceCount  = sd.initialMinInstanceCount;
      policy.specificDateSchedules  ~= sched;
    }

    repo.save(policy);
    return CommandResult(true, id, "");
  }

  CommandResult updatePolicy(UpdateScalingPolicyRequest r) {
    
    auto existing = repo.find(r.tenantId, r.policyId);
    if (existing.isNull)
      return CommandResult(false, "", "Policy not found");

    existing.instanceMinCount = r.instanceMinCount > 0 ? r.instanceMinCount : existing.instanceMinCount;
    existing.instanceMaxCount = r.instanceMaxCount > existing.instanceMinCount
      ? r.instanceMaxCount : existing.instanceMaxCount;
    existing.timezone = r.timezone.length > 0 ? r.timezone : existing.timezone;
    existing.customMetricAllowFrom = r.customMetricAllowFrom == "bound_app"
      ? MetricAllowFrom.boundApp : MetricAllowFrom.sameApp;
    existing.updatedAt = currentTimestamp;

    // Replace rules
    ScalingRuleEntity[] newRules;
    foreach (rr; r.scalingRules) {
      auto rule = ScalingRuleEntity();
      rule.id                = generateId();
      rule.metricType        = toMetricType(rr.metricType);
      rule.customMetricName  = rr.customMetricName;
      rule.threshold         = rr.threshold;
      rule.operator          = toScalingOperator(rr.operator);
      rule.breachDurationSecs= rr.breachDurationSecs > 0 ? rr.breachDurationSecs : 120;
      rule.coolDownSecs      = rr.coolDownSecs > 0 ? rr.coolDownSecs : 300;
      rule.adjustment        = rr.adjustment;
      newRules              ~= rule;
    }
    existing.scalingRules = newRules;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deletePolicy(TenantId tenantId, ScalingPolicyId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Policy not found");

    repo.remove(existing);
    return CommandResult(true, existing.id.value, "");
  }

  ScalingPolicyEntity getPolicy(TenantId tenantId, ScalingPolicyId id) {
    return repo.findById(tenantId, id);
  }

  ScalingPolicyEntity getPolicyByApp(TenantId tenantId, AppBindingId appId) {
    return repo.findByApp(tenantId, appId);
  }

  ScalingPolicyEntity[] listPolicies(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  private string generateId() @safe {
    
    
    import std.random : uniform;
    return "pol-" ~ currentTimestamp.to!string ~ "-" ~ uniform(1000, 9999).to!string;
  }
}
