/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization.domain.entities.decision;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// An authorization check that was answered — the decision log (audit trail)
/// of the runtime evaluation. Immutable once written.
struct DecisionRecord {
  mixin TenantEntity!DecisionRecordId;

  string principalId;
  string[] groups;
  ManagedApplicationId applicationId;
  string resource;
  string action;
  string attributes; /// "k=v, k2=v2"
  bool allowed;
  string reason;
  string[] matchedPolicyIds;
  string channel; /// "rest", "odata", "cli", "gui", ...
}
