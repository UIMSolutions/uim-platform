/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Residence and retention rules of a legal ground.
///
///   reference date ──residence──▶ end of purpose ──retention──▶ end of retention
///   (end of business)             (block)                       (destroy)
module uim.platform.data_retention.domain.entities.rules;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// How long personal data may be used for the purpose after the reference date.
struct ResidenceRule {
  mixin TenantEntity!ResidenceRuleId;

  BusinessPurposeId businessPurposeId;
  LegalGroundId legalGroundId;
  RetentionPeriod period;
  bool active = true;

  void validate() const {
    requireId(id.value, "Residence rule ID");
    if (businessPurposeId.isNull || legalGroundId.isNull)
      throw DataRetentionException.invalid("Business purpose and legal ground of a residence rule are required");
    period.validate("Residence period");
  }
}

/// How long blocked data must be kept after the end of purpose, and what
/// happens when that time is over.
struct RetentionRule {
  mixin TenantEntity!RetentionRuleId;

  BusinessPurposeId businessPurposeId;
  LegalGroundId legalGroundId;
  RetentionPeriod period;
  DeletionAction actionOnExpiry = DeletionAction.delete_;
  bool active = true;

  void validate() const {
    requireId(id.value, "Retention rule ID");
    if (businessPurposeId.isNull || legalGroundId.isNull)
      throw DataRetentionException.invalid("Business purpose and legal ground of a retention rule are required");
    period.validate("Retention period");
    if (actionOnExpiry == DeletionAction.block)
      throw DataRetentionException.invalid("The action on expiry must be 'delete' or 'anonymize'");
  }
}

///
unittest {
  RetentionRule r;
  r.id = RetentionRuleId("r1");
  r.businessPurposeId = BusinessPurposeId("p");
  r.legalGroundId = LegalGroundId("g");
  r.period = RetentionPeriod(10, PeriodUnit.years);
  r.validate();
  r.actionOnExpiry = DeletionAction.block;
  assert(failsWith(DrErrorKind.invalid, () { r.validate(); }));
}
