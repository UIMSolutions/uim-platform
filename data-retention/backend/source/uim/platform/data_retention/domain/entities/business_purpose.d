/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A business purpose (e.g. "Sales Order Processing") for which personal
/// data of an application group is processed. Its legal grounds carry the
/// residence and retention rules. Rules are applied only while the purpose
/// is active (or deprecated).
module uim.platform.data_retention.domain.entities.business_purpose;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct BusinessPurpose {
  mixin TenantEntity!BusinessPurposeId;

  string name;
  string description;
  ApplicationGroupId applicationGroupId;
  DataSubjectRoleId dataSubjectRoleId;
  LegalEntityId legalEntityId; /// optional: the rules apply to this legal entity
  BusinessPurposeStatus status = BusinessPurposeStatus.inactive;
  long activatedAt;

  bool isActive() const {
    return status == BusinessPurposeStatus.active;
  }

  /// Active and deprecated purposes govern their data subjects.
  bool appliesRules() const {
    return status != BusinessPurposeStatus.inactive;
  }

  /// Requires the completeness check of the caller (legal ground with rules).
  void activate(long now) {
    if (status == BusinessPurposeStatus.active)
      throw DataRetentionException.ruleViolation("Business purpose '" ~ id.value ~ "' is already active");
    status = BusinessPurposeStatus.active;
    activatedAt = now;
  }

  void deactivate() {
    if (status == BusinessPurposeStatus.inactive)
      throw DataRetentionException.ruleViolation("Business purpose '" ~ id.value ~ "' is already inactive");
    status = BusinessPurposeStatus.inactive;
  }

  /// Keep the rules for existing data subjects, accept no new ones.
  void deprecate() {
    if (status != BusinessPurposeStatus.active)
      throw DataRetentionException.ruleViolation("Only an active business purpose can be deprecated");
    status = BusinessPurposeStatus.deprecated_;
  }

  void validate() const {
    requireId(id.value, "Business purpose ID");
    requireText(name, "Name");
    requireMaxLength(name, 256, "Name");
    requireMaxLength(description, 2000, "Description");
    if (applicationGroupId.isNull)
      throw DataRetentionException.invalid("The application group of a business purpose is required");
    if (dataSubjectRoleId.isNull)
      throw DataRetentionException.invalid("The data subject role of a business purpose is required");
  }
}

///
unittest {
  BusinessPurpose p;
  p.id = BusinessPurposeId("sales");
  p.name = "Sales";
  assert(failsWith(DrErrorKind.invalid, () { p.validate(); }));
  p.applicationGroupId = ApplicationGroupId("erp");
  p.dataSubjectRoleId = DataSubjectRoleId("customer");
  p.validate();
  assert(!p.appliesRules);
  p.activate(5);
  assert(p.isActive && p.activatedAt == 5 && p.appliesRules);
  assert(failsWith(DrErrorKind.ruleViolation, () { p.activate(6); }));
  p.deprecate();
  assert(p.appliesRules && !p.isActive);
  p.deactivate();
  assert(failsWith(DrErrorKind.ruleViolation, () { p.deactivate(); }));
}
