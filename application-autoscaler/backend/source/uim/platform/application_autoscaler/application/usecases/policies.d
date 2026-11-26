/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Scaling policies, their dynamic rules and schedules.
///
/// Rules: policy names are unique per tenant (case insensitive); rules and
/// schedules belong to one policy for good; a policy cannot be deleted
/// while bindings use it (its rules and schedules go with it); enabled
/// specific-date schedules of a policy must not overlap.
module uim.platform.application_autoscaler.application.usecases.policies;

import std.uni : icmp;
import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

class ManagePoliciesUseCase : ResourceInteractor!(ScalingPolicy, ScalingPolicyId, PolicyInput), IManagePolicies {
  this(AasRepositories repos, IClock clock, IAasEventPublisher events, IAasUnitOfWork unitOfWork, AasPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IAasRepository!(ScalingPolicy, ScalingPolicyId) store() {
    return repos.policies;
  }

  protected override string what() {
    return "Policy";
  }

  protected override string eventPrefix() {
    return "policy";
  }

  protected override PolicyInput toInput(const ScalingPolicy e) {
    PolicyInput i;
    i.name = e.name;
    i.description = e.description;
    i.instanceMinCount = e.instanceMinCount;
    i.instanceMaxCount = e.instanceMaxCount;
    i.timezone = e.timezone;
    i.customMetricAllowFrom = cast(string) e.customMetricAllowFrom;
    return i;
  }

  protected override void fromInput(TenantId t, ref ScalingPolicy e, PolicyInput i, bool creating) {
    e.name = i.name.strip;
    requireUniqueName(t, e.id, e.name);
    e.description = i.description.strip;
    e.instanceMinCount = i.instanceMinCount;
    e.instanceMaxCount = i.instanceMaxCount;
    e.timezone = i.timezone.strip.length ? i.timezone.strip : "UTC";
    e.customMetricAllowFrom = parseDomainEnumOr!MetricAllowFrom(i.customMetricAllowFrom, MetricAllowFrom.sameApp,
      "custom metric source");
  }

  protected void requireUniqueName(TenantId t, ScalingPolicyId self, string name) {
    foreach (other; repos.policies.findAll(t))
      if (other.id != self && icmp(other.name, name) == 0)
        throw AasException.conflict("A policy named '" ~ name ~ "' already exists ('" ~ other.id.value ~ "')");
  }

  protected override void beforeRemove(TenantId t, const ScalingPolicy e, UserId actor) {
    requireUnused("Policy '" ~ e.name ~ "'", repos.bindings.countByReference(t, "policyId", e.id.value), "bindings");
    repos.rules.removeByReference(t, "policyId", e.id.value);
    repos.schedules.removeByReference(t, "policyId", e.id.value);
  }

  ScalingPolicy activate(TenantId t, ScalingPolicyId id, UserId actor) {
    return setStatus(t, id, PolicyStatus.active, actor);
  }

  ScalingPolicy deactivate(TenantId t, ScalingPolicyId id, UserId actor) {
    return setStatus(t, id, PolicyStatus.inactive, actor);
  }

  protected ScalingPolicy setStatus(TenantId t, ScalingPolicyId id, PolicyStatus status, UserId actor) {
    auto p = get(t, id);
    if (p.status == status)
      throw AasException.ruleViolation("Policy '" ~ p.name ~ "' is already " ~ cast(string) status);
    p.status = status;
    stampUpdated(p, actor, now);
    repos.policies.save(p);
    emit(status == PolicyStatus.active ? "policy.activated" : "policy.deactivated", t, id.value);
    return p;
  }

  ScalingPolicy copy(TenantId t, ScalingPolicyId id, string newId, UserId actor) {
    auto source = get(t, id);
    auto target = idOrNew(newId, "Policy ID");
    if (repos.policies.existsById(t, ScalingPolicyId(target)))
      throw AasException.conflict("Policy '" ~ target ~ "' already exists");
    auto p = source;
    stampCreated!(ScalingPolicy, ScalingPolicyId)(p, t, actor, target, nextTime);
    p.status = PolicyStatus.inactive;
    auto base = source.name ~ " (copy)";
    p.name = base;
    for (int n = 2; repos.policies.findAll(t).canFind!(o => icmp(o.name, p.name) == 0); n++)
      p.name = base ~ " " ~ n.to!string;
    p.validate();
    batch(() {
      repos.policies.save(p);
      foreach (r; repos.rules.findByReference(t, "policyId", source.id.value)) {
        auto c = r;
        stampCreated!(ScalingRule, ScalingRuleId)(c, t, actor, newResourceId(), nextTime);
        c.policyId = p.id;
        repos.rules.save(c);
      }
      foreach (s; repos.schedules.findByReference(t, "policyId", source.id.value)) {
        auto c = s;
        stampCreated!(ScalingSchedule, ScheduleId)(c, t, actor, newResourceId(), nextTime);
        c.policyId = p.id;
        repos.schedules.save(c);
      }
    });
    emit("policy.copied", t, p.id.value, Json(["from": Json(source.id.value)]));
    return p;
  }
}

class ManageRulesUseCase : ResourceInteractor!(ScalingRule, ScalingRuleId, RuleInput), IManageRules {
  this(AasRepositories repos, IClock clock, IAasEventPublisher events, IAasUnitOfWork unitOfWork, AasPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IAasRepository!(ScalingRule, ScalingRuleId) store() {
    return repos.rules;
  }

  protected override string what() {
    return "Rule";
  }

  protected override string eventPrefix() {
    return "rule";
  }

  protected override string[] immutableAttributes() {
    return ["policyId"];
  }

  protected override RuleInput toInput(const ScalingRule e) {
    RuleInput i;
    i.policyId = e.policyId.value;
    i.metricType = cast(string) e.metricType;
    i.customMetricName = e.customMetricName;
    i.operator = cast(string) e.operator;
    i.threshold = e.threshold;
    i.breachDurationSeconds = e.breachDurationSeconds;
    i.coolDownSeconds = e.coolDownSeconds;
    i.adjustment = e.adjustment;
    i.enabled = e.enabled;
    return i;
  }

  protected override void fromInput(TenantId t, ref ScalingRule e, RuleInput i, bool creating) {
    e.policyId = policyOf(t, ScalingPolicyId(i.policyId.strip)).id;
    e.metricType = parseDomainEnumOr!MetricType(i.metricType, MetricType.cpu, "metric type");
    e.customMetricName = e.metricType == MetricType.custom ? i.customMetricName.strip : "";
    e.operator = parseOperator(i.operator.length ? i.operator : ">=");
    e.threshold = i.threshold;
    e.breachDurationSeconds = i.breachDurationSeconds;
    e.coolDownSeconds = i.coolDownSeconds;
    e.adjustment = parseAdjustment(i.adjustment).toString;
    e.enabled = i.enabled;
  }

  ScalingRule[] listOf(TenantId t, ScalingPolicyId policyId) {
    policyOf(t, policyId);
    return repos.rules.findByReference(t, "policyId", policyId.value);
  }
}

class ManageSchedulesUseCase : ResourceInteractor!(ScalingSchedule, ScheduleId, ScheduleInput), IManageSchedules {
  this(AasRepositories repos, IClock clock, IAasEventPublisher events, IAasUnitOfWork unitOfWork, AasPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IAasRepository!(ScalingSchedule, ScheduleId) store() {
    return repos.schedules;
  }

  protected override string what() {
    return "Schedule";
  }

  protected override string eventPrefix() {
    return "schedule";
  }

  protected override string[] immutableAttributes() {
    return ["policyId", "kind"];
  }

  protected override ScheduleInput toInput(const ScalingSchedule e) {
    ScheduleInput i;
    i.policyId = e.policyId.value;
    i.name = e.name;
    i.kind = cast(string) e.kind;
    i.startTime = e.startTime;
    i.endTime = e.endTime;
    i.daysOfWeek = e.daysOfWeek.dup;
    i.daysOfMonth = e.daysOfMonth.dup;
    i.startDate = e.startDate;
    i.endDate = e.endDate;
    i.startDateTime = e.startDateTime;
    i.endDateTime = e.endDateTime;
    i.instanceMinCount = e.instanceMinCount;
    i.instanceMaxCount = e.instanceMaxCount;
    i.initialMinInstanceCount = e.initialMinInstanceCount;
    i.enabled = e.enabled;
    return i;
  }

  protected override void fromInput(TenantId t, ref ScalingSchedule e, ScheduleInput i, bool creating) {
    e.policyId = policyOf(t, ScalingPolicyId(i.policyId.strip)).id;
    e.name = i.name.strip;
    e.kind = parseDomainEnumOr!ScheduleKind(i.kind, ScheduleKind.recurring, "schedule kind");
    auto recurring = e.kind == ScheduleKind.recurring;
    // members of the other kind are dropped, so a form may send everything
    e.startTime = recurring ? i.startTime.strip : "";
    e.endTime = recurring ? i.endTime.strip : "";
    e.daysOfWeek = recurring ? normalizeDays(i.daysOfWeek, true) : null;
    e.daysOfMonth = recurring ? normalizeDays(i.daysOfMonth, false) : null;
    e.startDate = recurring ? i.startDate.strip : "";
    e.endDate = recurring ? i.endDate.strip : "";
    e.startDateTime = recurring ? "" : i.startDateTime.strip;
    e.endDateTime = recurring ? "" : i.endDateTime.strip;
    e.instanceMinCount = i.instanceMinCount;
    e.instanceMaxCount = i.instanceMaxCount;
    e.initialMinInstanceCount = i.initialMinInstanceCount;
    e.enabled = i.enabled;
  }

  protected override void beforeSave(TenantId t, const ScalingSchedule e, bool creating) {
    if (e.kind != ScheduleKind.specificDate || !e.enabled)
      return;
    auto from = parseLocalDateTime(e.startDateTime, "UTC");
    auto to = parseLocalDateTime(e.endDateTime, "UTC");
    foreach (o; repos.schedules.findByReference(t, "policyId", e.policyId.value)) {
      if (o.id == e.id || o.kind != ScheduleKind.specificDate || !o.enabled)
        continue;
      if (from < parseLocalDateTime(o.endDateTime, "UTC") && parseLocalDateTime(o.startDateTime, "UTC") < to)
        throw AasException.ruleViolation("The schedule overlaps the specific-date schedule '"
            ~ (o.name.length ? o.name : o.id.value) ~ "' (" ~ o.startDateTime ~ " – " ~ o.endDateTime ~ ")");
    }
  }

  ScalingSchedule[] listOf(TenantId t, ScalingPolicyId policyId) {
    policyOf(t, policyId);
    return repos.schedules.findByReference(t, "policyId", policyId.value);
  }

  bool isActive(TenantId t, const ScalingSchedule s) {
    auto p = repos.policies.findById(t, s.policyId);
    try
      return s.isActiveAt(now, p.isNull ? "UTC" : p.timezone);
    catch (AutoscalerException)
      return false;
  }
}
