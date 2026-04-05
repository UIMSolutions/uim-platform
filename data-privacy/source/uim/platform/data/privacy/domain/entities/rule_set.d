/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.rule_set;

import uim.platform.data.privacy.domain.types;

/// A rule condition evaluated against master data to identify relevant purposes.
struct RuleCondition {
  string fieldPath; // e.g. "employee.country"
  RuleOperator operator = RuleOperator.equals;
  string value; // comparison value
}

/// A rule set — evaluates master data to determine applicable business purposes.
struct RuleSet {
  RuleSetId id;
  TenantId tenantId;
  BusinessContextId businessContextId;
  string name;
  string description;
  RuleSetStatus status = RuleSetStatus.draft;
  RuleCondition[] conditions;
  ProcessingPurpose[] resultPurposes; // purposes assigned when rules match
  int priority; // evaluation order
  long createdAt;
  long updatedAt;
  long activatedAt;
}
