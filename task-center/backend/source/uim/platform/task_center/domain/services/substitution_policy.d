/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Substitution: resolving the effective recipient of a new task and
/// keeping auto-forwarding rules free of cycles.
module uim.platform.task_center.domain.services.substitution_policy;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// Result of resolving the recipient of a task.
struct Recipient {
  string assignee; /// effective assignee
  string substitutedFor; /// original assignee if a rule forwarded the task ("" otherwise)
  SubstitutionRuleId ruleId; /// the rule that applied
}

/// Follow the auto-forward rule of the assignee (one hop; cycles are
/// prevented when rules are saved). A rule bound to a definition wins over a
/// rule for all definitions.
Recipient resolveRecipient(const SubstitutionRule[] rules, string assignee, TaskDefinitionId definitionId, string today) {
  Recipient r;
  r.assignee = assignee;
  if (assignee.length == 0)
    return r;
  ptrdiff_t best = -1;
  foreach (i, rule; rules) {
    if (!rule.isAutoForward || !rule.appliesTo(assignee, definitionId, today))
      continue;
    if (best < 0 || (rules[best].definitionId.isNull && !rule.definitionId.isNull))
      best = i;
  }
  if (best >= 0) {
    r.assignee = rules[best].substituteId;
    r.substitutedFor = assignee;
    r.ruleId = rules[best].id;
  }
  return r;
}

/// Throw if saving `candidate` would create an auto-forward cycle
/// (A → B while B → A, both active auto-forward rules that can overlap).
void checkForwardingCycle(const SubstitutionRule[] rules, const SubstitutionRule candidate, string today) {
  if (!candidate.isAutoForward || candidate.effectiveStatus(today) == SubstitutionStatus.inactive
      || candidate.effectiveStatus(today) == SubstitutionStatus.expired)
    return;
  foreach (rule; rules) {
    if (rule.id == candidate.id || !rule.isAutoForward || rule.userId != candidate.substituteId
        || rule.substituteId != candidate.userId)
      continue;
    auto s = rule.effectiveStatus(today);
    if (s == SubstitutionStatus.inactive || s == SubstitutionStatus.expired)
      continue;
    if (!rule.definitionId.isNull && !candidate.definitionId.isNull && rule.definitionId != candidate.definitionId)
      continue;
    if (!periodsOverlap(rule.startDate, rule.endDate, candidate.startDate, candidate.endDate))
      continue;
    throw TaskCenterException.ruleViolation("Auto-forwarding " ~ candidate.userId ~ " → " ~ candidate.substituteId
        ~ " would form a cycle with rule " ~ rule.id.value ~ " (" ~ rule.userId ~ " → " ~ rule.substituteId ~ ")");
  }
}

/// Inclusive ISO date ranges ("" = unbounded) overlap.
bool periodsOverlap(string start1, string end1, string start2, string end2) pure {
  auto startsBeforeOtherEnds = (string start, string otherEnd) => start.length == 0 || otherEnd.length == 0 || start <= otherEnd;
  return startsBeforeOtherEnds(start1, end2) && startsBeforeOtherEnds(start2, end1);
}

///
unittest {
  SubstitutionRule global, poOnly, back;
  global.id = SubstitutionRuleId("r1");
  global.userId = "anna";
  global.substituteId = "ben";
  global.isAutoForward = true;
  poOnly = global;
  poOnly.id = SubstitutionRuleId("r2");
  poOnly.substituteId = "carl";
  poOnly.definitionId = TaskDefinitionId("po");

  auto r = resolveRecipient([global, poOnly], "anna", TaskDefinitionId("po"), "2026-01-01");
  assert(r.assignee == "carl" && r.substitutedFor == "anna" && r.ruleId.value == "r2");
  r = resolveRecipient([global, poOnly], "anna", TaskDefinitionId("leave"), "2026-01-01");
  assert(r.assignee == "ben");
  r = resolveRecipient([global], "dora", TaskDefinitionId.init, "2026-01-01");
  assert(r.assignee == "dora" && r.substitutedFor == "");

  back.id = SubstitutionRuleId("r3");
  back.userId = "ben";
  back.substituteId = "anna";
  back.isAutoForward = true;
  assert(failsWith(TaskCenterErrorKind.ruleViolation, () { checkForwardingCycle([global], back, "2026-01-01"); }));
  back.startDate = "2026-03-01";
  global.endDate = "2026-02-01";
  checkForwardingCycle([global], back, "2026-01-01"); // periods do not overlap
  assert(periodsOverlap("", "", "2026-01-01", "") && !periodsOverlap("2026-01-01", "2026-01-31", "2026-02-01", ""));
}
