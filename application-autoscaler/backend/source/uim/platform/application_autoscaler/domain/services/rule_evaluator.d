/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Pure evaluation of one dynamic rule against the metric samples of an
/// application. A rule is breached when the newest sample is fresh and the
/// comparison has held without interruption for at least the breach
/// duration (from the oldest sample of the uninterrupted run up to now).
module uim.platform.application_autoscaler.domain.services.rule_evaluator;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

struct RuleCheck {
  bool breached;
  bool stale; /// newest sample older than the stale limit (or none)
  double value = 0; /// newest value
  long breachingSince; /// std time of the oldest sample of the current breaching run (0 = not breaching)
  size_t samples; /// samples of the metric considered
  string reason;
}

/// Check one rule. samples may contain any metric, in any order.
RuleCheck checkRule(const ScalingRule rule, const MetricSample[] samples, long now, long staleSeconds) {
  RuleCheck c;
  auto name = rule.metricName;
  const(MetricSample)[] own;
  foreach (s; samples)
    if (s.metricName == name && s.measuredAt <= now)
      own ~= s;
  c.samples = own.length;
  if (own.length == 0) {
    c.stale = true;
    c.reason = "no samples of " ~ name;
    return c;
  }
  auto ordered = own.dup;
  ordered.sort!((a, b) => a.measuredAt > b.measuredAt);
  c.value = ordered[0].value;
  if (secondsBetween(ordered[0].measuredAt, now) > staleSeconds) {
    c.stale = true;
    c.reason = format("newest %s sample is older than %ds", name, staleSeconds);
    return c;
  }
  foreach (s; ordered) {
    if (!compare(rule.operator, s.value, rule.threshold))
      break;
    c.breachingSince = s.measuredAt;
  }
  if (c.breachingSince == 0) {
    c.reason = format("%s = %s (threshold %s %s)", name, fmtValue(c.value), cast(string) rule.operator, fmtValue(rule.threshold));
    return c;
  }
  auto lasted = secondsBetween(c.breachingSince, now);
  c.breached = lasted >= rule.breachDurationSeconds;
  c.reason = format("%s = %s %s %s for %ds%s", name, fmtValue(c.value), cast(string) rule.operator,
    fmtValue(rule.threshold), lasted, c.breached ? "" : format(" (needs %ds)", rule.breachDurationSeconds));
  return c;
}

/// 80 → "80", 0.5 → "0.5"
string fmtValue(double v) {
  import std.math : round;

  if (v == round(v) && v < 1e15 && v > -1e15)
    return (cast(long) v).to!string;
  return format("%.2f", v).stripRight("0").stripRight(".");
}

///
unittest {
  auto t0 = parseIsoTime("2026-11-25T10:00:00Z");
  ScalingRule r;
  r.policyId = ScalingPolicyId("p");
  r.threshold = 80;
  r.breachDurationSeconds = 120;
  MetricSample at(long secondsAgo, double v, string name = "cpu") {
    MetricSample s;
    s.metricName = name;
    s.value = v;
    s.measuredAt = plusSeconds(t0, -secondsAgo);
    return s;
  }

  assert(checkRule(r, [], t0, 600).stale);
  // breaching for 150s → breached
  auto c = checkRule(r, [at(150, 85), at(90, 90), at(30, 95), at(10, 50, "memoryutil")], t0, 600);
  assert(c.breached && c.value == 95 && c.samples == 3 && c.breachingSince == plusSeconds(t0, -150), c.reason);
  // interrupted run: only the last 60s breach
  c = checkRule(r, [at(150, 85), at(90, 40), at(60, 90), at(5, 99)], t0, 600);
  assert(!c.breached && c.breachingSince == plusSeconds(t0, -60) && c.reason.canFind("needs 120s"), c.reason);
  // newest below the threshold
  assert(!checkRule(r, [at(300, 99), at(5, 10)], t0, 600).breached);
  // stale
  assert(checkRule(r, [at(900, 99)], t0, 600).stale);
  assert(fmtValue(80) == "80" && fmtValue(0.5) == "0.5" && fmtValue(12.345) == "12.35");
}
