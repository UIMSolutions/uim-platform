/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Delegation of a user's tasks to a substitute during an absence.
module uim.platform.task_center.domain.entities.substitution_rule;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct SubstitutionRule {
  mixin TenantEntity!SubstitutionRuleId;

  string userId; /// the absent user
  string substituteId; /// who takes over
  TaskDefinitionId definitionId; /// only tasks of this definition ("" = all)
  SubstitutionStatus status = SubstitutionStatus.active; /// active | inactive (owner controlled)
  string startDate; /// ISO date, "" = immediately
  string endDate; /// ISO date (inclusive), "" = open ended
  bool isAutoForward; /// new tasks go straight to the substitute

  /// active | inactive | pending (before startDate) | expired (after endDate).
  SubstitutionStatus effectiveStatus(string today) const {
    if (status == SubstitutionStatus.inactive)
      return SubstitutionStatus.inactive;
    if (endDate.length > 0 && endDate < today)
      return SubstitutionStatus.expired;
    if (startDate.length > 0 && startDate > today)
      return SubstitutionStatus.pending;
    return SubstitutionStatus.active;
  }

  bool appliesTo(string assignee, TaskDefinitionId definition, string today) const {
    return userId == assignee && effectiveStatus(today) == SubstitutionStatus.active
      && (definitionId.isNull || definitionId == definition);
  }

  void validate() const {
    requireText(userId, "userId");
    requireText(substituteId, "substituteId");
    if (userId == substituteId)
      throw TaskCenterException.invalid("A user cannot substitute themselves");
    if (status != SubstitutionStatus.active && status != SubstitutionStatus.inactive)
      throw TaskCenterException.invalid("status must be 'active' or 'inactive' (pending and expired are derived from the dates)");
    requireOptionalDate(startDate, "startDate");
    requireOptionalDate(endDate, "endDate");
    if (startDate.length > 0 && endDate.length > 0 && endDate < startDate)
      throw TaskCenterException.invalid("endDate must not be before startDate");
  }
}

///
unittest {
  SubstitutionRule r;
  r.userId = "anna";
  r.substituteId = "ben";
  r.startDate = "2026-07-01";
  r.endDate = "2026-07-14";
  r.validate();
  assert(r.effectiveStatus("2026-06-30") == SubstitutionStatus.pending);
  assert(r.effectiveStatus("2026-07-14") == SubstitutionStatus.active);
  assert(r.effectiveStatus("2026-07-15") == SubstitutionStatus.expired);
  assert(r.appliesTo("anna", TaskDefinitionId("any"), "2026-07-02") && !r.appliesTo("ben", TaskDefinitionId.init, "2026-07-02"));
  r.endDate = "2026-06-01";
  assert(failsWith(TaskCenterErrorKind.invalid, () { r.validate(); }));
  r.endDate = "";
  r.substituteId = "anna";
  assert(failsWith(TaskCenterErrorKind.invalid, () { r.validate(); }));
}
