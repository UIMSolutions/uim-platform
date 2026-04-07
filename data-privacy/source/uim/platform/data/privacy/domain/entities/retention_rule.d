/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.retention_rule;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Defines how long personal data may be retained for a given purpose.
struct RetentionRule {
  RetentionRuleId id;
  TenantId tenantId;
  string name;
  string description;
  ProcessingPurpose purpose;
  PersonalDataCategory[] categories;
  int retentionDays; // maximum retention period
  string legalReference; // e.g. "HGB §257 (10 years)"
  RetentionRuleStatus status = RetentionRuleStatus.active;
  bool isDefault;
  long createdAt;
  long updatedAt;
}
