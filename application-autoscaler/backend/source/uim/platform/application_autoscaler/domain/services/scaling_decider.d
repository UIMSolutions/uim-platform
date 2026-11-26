/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Pure scaling decision for one application binding:
///
///  1. Instance limits: those of an active schedule (specific date before
///     recurring), else those of the policy.
///  2. Instances outside the limits are brought inside (trigger limits or
///     schedule); a schedule that just started raises the instances to its
///     initialMinInstanceCount.
///  3. Otherwise the enabled rules are checked. Rules still in their
///     cool-down (since the last scaling of the binding) are skipped.
///     Breached scale-out rules win over scale-in rules (availability
///     first); among scale-out rules the largest, among scale-in rules the
///     smallest reduction wins.
///  4. The target is limited to the instance limits; equal → nothing to do.
module uim.platform.application_autoscaler.domain.services.scaling_decider;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

struct InstanceLimits {
  int min = 1;
  int max = 1;
  ScheduleId scheduleId; /// set if a schedule applies
  long scheduleSince; /// start of the schedule's current occurrence
  int initialMin; /// of the schedule
  string source = "policy"; /// policy | schedule name
}

struct ScalingDecision {
  ScalingTrigger trigger = ScalingTrigger.dynamic;
  ScalingDirection direction = ScalingDirection.none;
  int current;
  int target;
  ScalingRuleId ruleId;
  ScheduleId scheduleId;
  string metricName;
  double metricValue = 0;
  double threshold = 0;
  string reason;
  InstanceLimits limits;

  bool changes() const {
    return target != current;
  }
}

/// The limits that apply at now.
InstanceLimits effectiveLimits(const ScalingPolicy policy, const ScalingSchedule[] schedules, long now) {
  InstanceLimits l;
  l.min = policy.instanceMinCount;
  l.max = policy.instanceMaxCount;
  ptrdiff_t chosen = -1;
  long since;
  foreach (kind; [ScheduleKind.specificDate, ScheduleKind.recurring]) {
    foreach (i, ref s; schedules) {
      if (s.kind != kind || s.policyId != policy.id)
        continue;
      long at;
      try
        at = s.activeSince(now, policy.timezone);
      catch (AutoscalerException)
        continue; // an invalid stored schedule never blocks scaling
      if (at > 0) {
        chosen = i;
        since = at;
        break;
      }
    }
    if (chosen >= 0)
      break;
  }
  if (chosen >= 0) {
    l.min = schedules[chosen].instanceMinCount;
    l.max = schedules[chosen].instanceMaxCount;
    l.scheduleId = schedules[chosen].id;
    l.scheduleSince = since;
    l.initialMin = schedules[chosen].initialMinInstanceCount;
    l.source = schedules[chosen].name.length ? schedules[chosen].name : schedules[chosen].id.value;
  }
  return l;
}

ScalingDecision decideScaling(const AppBinding binding, const ScalingPolicy policy, const ScalingRule[] rules,
  const ScalingSchedule[] schedules, const MetricSample[] samples, long now, long staleSeconds) {
  ScalingDecision d;
  d.limits = effectiveLimits(policy, schedules, now);
  d.current = binding.currentInstances;
  d.target = d.current;
  d.scheduleId = d.limits.scheduleId;
  auto limits = format("[%d..%d of %s]", d.limits.min, d.limits.max, d.limits.source);

  // 2. limits and schedule start
  auto viaSchedule = !d.limits.scheduleId.isNull;
  if (d.current < d.limits.min || d.current > d.limits.max) {
    d.target = clamp(d.current, d.limits.min, d.limits.max);
    d.trigger = viaSchedule ? ScalingTrigger.schedule : ScalingTrigger.limits;
    d.direction = d.target > d.current ? ScalingDirection.scaleOut : ScalingDirection.scaleIn;
    d.reason = format("%d instances are outside the limits %s", d.current, limits);
    return d;
  }
  if (viaSchedule && d.limits.initialMin > d.current && binding.lastScaledAt < d.limits.scheduleSince) {
    d.target = d.limits.initialMin;
    d.trigger = ScalingTrigger.schedule;
    d.direction = ScalingDirection.scaleOut;
    d.reason = format("schedule '%s' started: initial minimum of %d instances", d.limits.source, d.limits.initialMin);
    return d;
  }

  // 3. dynamic rules
  struct Candidate {
    size_t rule; /// index into rules
    RuleCheck check;
    int target;
  }

  Candidate[] outs, ins;
  string[] notes;
  foreach (i, ref r; rules) {
    if (!r.enabled || r.policyId != policy.id)
      continue;
    Adjustment adj;
    try
      adj = r.parsedAdjustment;
    catch (AutoscalerException)
      continue;
    auto c = checkRule(r, samples, now, staleSeconds);
    if (!c.breached) {
      notes ~= c.reason;
      continue;
    }
    if (binding.lastScaledAt > 0 && now < plusSeconds(binding.lastScaledAt, r.coolDownSeconds)) {
      notes ~= format("%s, but cooling down for %ds", c.reason, secondsBetween(now, plusSeconds(binding.lastScaledAt,
          r.coolDownSeconds)));
      continue;
    }
    auto target = clamp(adj.applyTo(d.current), d.limits.min, d.limits.max);
    auto candidate = Candidate(i, c, target);
    if (adj.scalesOut)
      outs ~= candidate;
    else
      ins ~= candidate;
  }

  // scale-out first (largest target), else scale-in (largest target = smallest reduction)
  auto pool = outs.length ? outs : ins;
  ptrdiff_t bestIndex = -1;
  foreach (i, c; pool)
    if (bestIndex < 0 || c.target > pool[bestIndex].target)
      bestIndex = i;

  d.trigger = ScalingTrigger.dynamic;
  if (bestIndex < 0) {
    d.reason = notes.length ? notes.join("; ") : "no enabled rules";
    return d;
  }
  auto best = pool[bestIndex];
  auto rule = rules[best.rule];
  d.ruleId = rule.id;
  d.metricName = rule.metricName;
  d.metricValue = best.check.value;
  d.threshold = rule.threshold;
  d.target = best.target;
  if (d.target == d.current) {
    d.reason = best.check.reason ~ format(" → %s, but the limit %s is reached", rule.adjustment, limits);
    return d;
  }
  d.direction = d.target > d.current ? ScalingDirection.scaleOut : ScalingDirection.scaleIn;
  d.reason = best.check.reason ~ " → " ~ rule.adjustment;
  return d;
}

///
unittest {
  auto now = parseIsoTime("2026-11-25T10:00:00Z"); // Wednesday
  ScalingPolicy p;
  p.id = ScalingPolicyId("p");
  p.instanceMinCount = 1;
  p.instanceMaxCount = 4;
  AppBinding b;
  b.id = AppBindingId("b");
  b.policyId = p.id;
  b.currentInstances = 2;

  ScalingRule rule(string id, string metric, ComparisonOperator op, double threshold, string adjustment) {
    ScalingRule r;
    r.id = ScalingRuleId(id);
    r.policyId = p.id;
    r.metricType = parseDomainEnum!MetricType(metric);
    r.operator = op;
    r.threshold = threshold;
    r.adjustment = adjustment;
    return r;
  }

  MetricSample sample(string name, double value, long secondsAgo) {
    MetricSample s;
    s.metricName = name;
    s.value = value;
    s.measuredAt = plusSeconds(now, -secondsAgo);
    return s;
  }

  auto up = rule("up", "cpu", ComparisonOperator.gte, 80, "+2");
  auto down = rule("down", "cpu", ComparisonOperator.lt, 20, "-1");
  auto memUp = rule("mem", "memoryutil", ComparisonOperator.gt, 70, "+1");
  auto hot = [sample("cpu", 90, 200), sample("cpu", 95, 10)];

  auto d = decideScaling(b, p, [up, down], [], hot, now, 600);
  assert(d.direction == ScalingDirection.scaleOut && d.target == 4 && d.ruleId.value == "up", d.reason);
  // limited by the policy maximum
  b.currentInstances = 4;
  d = decideScaling(b, p, [up], [], hot, now, 600);
  assert(!d.changes && d.reason.canFind("limit"), d.reason);
  // scale in
  b.currentInstances = 3;
  d = decideScaling(b, p, [up, down], [], [sample("cpu", 5, 300), sample("cpu", 10, 1)], now, 600);
  assert(d.direction == ScalingDirection.scaleIn && d.target == 2, d.reason);
  // scale out wins over scale in
  d = decideScaling(b, p, [down, memUp], [], [sample("cpu", 5, 300), sample("memoryutil", 90, 300)], now, 600);
  assert(d.direction == ScalingDirection.scaleOut && d.ruleId.value == "mem", d.reason);
  // cool-down after the last scaling
  b.lastScaledAt = plusSeconds(now, -100);
  d = decideScaling(b, p, [up], [], hot, now, 600);
  assert(!d.changes && d.reason.canFind("cooling down"), d.reason);
  b.lastScaledAt = 0;
  // outside the limits
  b.currentInstances = 9;
  d = decideScaling(b, p, [], [], [], now, 600);
  assert(d.trigger == ScalingTrigger.limits && d.target == 4);

  // schedule: business hours 3..10 with initial minimum 5
  ScalingSchedule s;
  s.id = ScheduleId("office");
  s.policyId = p.id;
  s.startTime = "08:00";
  s.endTime = "18:00";
  s.daysOfWeek = ["3"];
  s.instanceMinCount = 3;
  s.instanceMaxCount = 10;
  s.initialMinInstanceCount = 5;
  b.currentInstances = 2;
  d = decideScaling(b, p, [up], [s], hot, now, 600);
  assert(d.trigger == ScalingTrigger.schedule && d.target == 3, d.reason);
  b.currentInstances = 3;
  d = decideScaling(b, p, [up], [s], hot, now, 600);
  assert(d.trigger == ScalingTrigger.schedule && d.target == 5 && d.reason.canFind("initial"), d.reason);
  // once scaled inside the occurrence, the initial minimum is not applied again
  b.lastScaledAt = plusSeconds(now, -3600);
  d = decideScaling(b, p, [up], [s], hot, now, 600);
  assert(d.trigger == ScalingTrigger.dynamic && d.target == 5 && d.limits.max == 10, d.reason);
  // a specific date wins over the recurring schedule
  ScalingSchedule x;
  x.id = ScheduleId("sale");
  x.policyId = p.id;
  x.kind = ScheduleKind.specificDate;
  x.startDateTime = "2026-11-25T00:00";
  x.endDateTime = "2026-11-26T00:00";
  x.instanceMinCount = 8;
  x.instanceMaxCount = 20;
  assert(effectiveLimits(p, [s, x], now).scheduleId.value == "sale");
}
