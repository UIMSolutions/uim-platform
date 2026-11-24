/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business purposes, their legal grounds and the residence / retention
/// rules of the legal grounds.
///
///   - a purpose can be activated once it has an active legal ground with
///     an active residence rule; an active purpose must keep one
///   - an active purpose cannot be deleted; a deleted purpose takes its
///     legal grounds and rules with it; purposes of data subjects stay
///   - one residence and one retention rule per legal ground
module uim.platform.data_retention.application.usecases.purposes;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageBusinessPurposesUseCase : ResourceInteractor!(BusinessPurpose, BusinessPurposeId, BusinessPurposeInput),
IManageBusinessPurposes {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDrRepository!(BusinessPurpose, BusinessPurposeId) store() {
    return repos.businessPurposes;
  }

  protected override string what() {
    return "Business purpose";
  }

  protected override string eventPrefix() {
    return "businessPurpose";
  }

  protected override BusinessPurposeInput toInput(const BusinessPurpose e) {
    return BusinessPurposeInput(e.name, e.description, e.applicationGroupId.value, e.dataSubjectRoleId.value, e.legalEntityId.value);
  }

  protected override void fromInput(TenantId t, ref BusinessPurpose e, BusinessPurposeInput i, bool creating) {
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.applicationGroupId = applicationGroupOf(t, i.applicationGroupId).id;
    if (i.dataSubjectRoleId.strip.length == 0)
      throw DataRetentionException.invalid("Data subject role is required");
    e.dataSubjectRoleId = DataSubjectRoleId(optionalReference!DataSubjectRoleId(repos.dataSubjectRoles, t,
        i.dataSubjectRoleId, "Data subject role"));
    e.legalEntityId = LegalEntityId(optionalReference!LegalEntityId(repos.legalEntities, t, i.legalEntityId, "Legal entity"));
  }

  protected override void beforeRemove(TenantId t, const BusinessPurpose e, UserId actor) {
    if (e.status != BusinessPurposeStatus.inactive)
      throw DataRetentionException.ruleViolation("Business purpose '" ~ e.id.value ~ "' is " ~ cast(string) e.status
          ~ " — deactivate it before deleting it");
    requireUnused("Business purpose '" ~ e.id.value ~ "'", repos.dataSubjects.countByReference(t, "businessPurposeId",
        e.id.value), "data subjects");
    foreach (r; repos.residenceRules.findByReference(t, "businessPurposeId", e.id.value))
      repos.residenceRules.removeById(t, r.id);
    foreach (r; repos.retentionRules.findByReference(t, "businessPurposeId", e.id.value))
      repos.retentionRules.removeById(t, r.id);
    foreach (g; repos.legalGrounds.findByReference(t, "businessPurposeId", e.id.value))
      repos.legalGrounds.removeById(t, g.id);
  }

  BusinessPurpose activate(TenantId t, BusinessPurposeId id, UserId actor) {
    auto p = get(t, id);
    if (completeLegalGrounds(t, id) == 0)
      throw DataRetentionException.ruleViolation("Business purpose '" ~ id.value ~ "' needs an active legal ground "
          ~ "with an active residence rule before it can be activated");
    p.activate(now);
    return changed(p, actor, "activated");
  }

  BusinessPurpose deactivate(TenantId t, BusinessPurposeId id, UserId actor) {
    auto p = get(t, id);
    p.deactivate();
    return changed(p, actor, "deactivated");
  }

  BusinessPurpose deprecate(TenantId t, BusinessPurposeId id, UserId actor) {
    auto p = get(t, id);
    p.deprecate();
    return changed(p, actor, "deprecated");
  }

  protected BusinessPurpose changed(BusinessPurpose p, UserId actor, string event) {
    stampUpdated(p, actor, now);
    repos.businessPurposes.save(p);
    emit("businessPurpose." ~ event, p.tenantId, p.id.value);
    return p;
  }
}

class ManageLegalGroundsUseCase : ResourceInteractor!(LegalGround, LegalGroundId, LegalGroundInput) {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDrRepository!(LegalGround, LegalGroundId) store() {
    return repos.legalGrounds;
  }

  protected override string what() {
    return "Legal ground";
  }

  protected override string eventPrefix() {
    return "legalGround";
  }

  protected override string[] immutableAttributes() {
    return ["businessPurposeId"];
  }

  protected override LegalGroundInput toInput(const LegalGround e) {
    return LegalGroundInput(e.businessPurposeId.value, e.name, e.description, cast(string) e.type, e.legalReference, e.active);
  }

  protected override void fromInput(TenantId t, ref LegalGround e, LegalGroundInput i, bool creating) {
    if (creating)
      e.businessPurposeId = businessPurposeOf(t, i.businessPurposeId).id;
    else if (e.active && !i.active)
      requirePurposeStaysComplete(t, e.businessPurposeId, e.id, "deactivating legal ground '" ~ e.id.value ~ "'");
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.type = parseDomainEnumOr!LegalGroundType(i.type, LegalGroundType.contract, "type");
    e.legalReference = i.legalReference.strip;
    e.active = i.active;
  }

  protected override void beforeRemove(TenantId t, const LegalGround e, UserId actor) {
    if (e.active)
      requirePurposeStaysComplete(t, e.businessPurposeId, e.id, "deleting legal ground '" ~ e.id.value ~ "'");
    requireUnused("Legal ground '" ~ e.id.value ~ "'", repos.dataSubjects.countByReference(t, "legalGroundId", e.id.value),
      "data subjects");
    foreach (r; repos.residenceRules.findByReference(t, "legalGroundId", e.id.value))
      repos.residenceRules.removeById(t, r.id);
    foreach (r; repos.retentionRules.findByReference(t, "legalGroundId", e.id.value))
      repos.retentionRules.removeById(t, r.id);
  }
}

class ManageResidenceRulesUseCase : ResourceInteractor!(ResidenceRule, ResidenceRuleId, ResidenceRuleInput) {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDrRepository!(ResidenceRule, ResidenceRuleId) store() {
    return repos.residenceRules;
  }

  protected override string what() {
    return "Residence rule";
  }

  protected override string eventPrefix() {
    return "residenceRule";
  }

  protected override string[] immutableAttributes() {
    return ["businessPurposeId", "legalGroundId"];
  }

  protected override ResidenceRuleInput toInput(const ResidenceRule e) {
    return ResidenceRuleInput(e.businessPurposeId.value, e.legalGroundId.value, e.period.duration, cast(string) e.period.unit, e.active);
  }

  protected override void fromInput(TenantId t, ref ResidenceRule e, ResidenceRuleInput i, bool creating) {
    if (creating) {
      auto g = ruleTargetOf(t, i.businessPurposeId, i.legalGroundId);
      if (repos.residenceRules.countByReference(t, "legalGroundId", g.id.value) > 0)
        throw DataRetentionException.conflict("Legal ground '" ~ g.id.value ~ "' already has a residence rule");
      e.businessPurposeId = g.businessPurposeId;
      e.legalGroundId = g.id;
    } else if (e.active && !i.active)
      requirePurposeStaysComplete(t, e.businessPurposeId, e.legalGroundId, "deactivating residence rule '" ~ e.id.value ~ "'");
    e.period = RetentionPeriod(i.duration, parseDomainEnumOr!PeriodUnit(i.periodUnit, PeriodUnit.years, "periodUnit"));
    e.active = i.active;
  }

  protected override void beforeRemove(TenantId t, const ResidenceRule e, UserId actor) {
    if (e.active)
      requirePurposeStaysComplete(t, e.businessPurposeId, e.legalGroundId, "deleting residence rule '" ~ e.id.value ~ "'");
  }
}

class ManageRetentionRulesUseCase : ResourceInteractor!(RetentionRule, RetentionRuleId, RetentionRuleInput) {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDrRepository!(RetentionRule, RetentionRuleId) store() {
    return repos.retentionRules;
  }

  protected override string what() {
    return "Retention rule";
  }

  protected override string eventPrefix() {
    return "retentionRule";
  }

  protected override string[] immutableAttributes() {
    return ["businessPurposeId", "legalGroundId"];
  }

  protected override RetentionRuleInput toInput(const RetentionRule e) {
    return RetentionRuleInput(e.businessPurposeId.value, e.legalGroundId.value, e.period.duration, cast(string) e.period.unit,
      cast(string) e.actionOnExpiry, e.active);
  }

  protected override void fromInput(TenantId t, ref RetentionRule e, RetentionRuleInput i, bool creating) {
    if (creating) {
      auto g = ruleTargetOf(t, i.businessPurposeId, i.legalGroundId);
      if (repos.retentionRules.countByReference(t, "legalGroundId", g.id.value) > 0)
        throw DataRetentionException.conflict("Legal ground '" ~ g.id.value ~ "' already has a retention rule");
      e.businessPurposeId = g.businessPurposeId;
      e.legalGroundId = g.id;
    }
    e.period = RetentionPeriod(i.duration, parseDomainEnumOr!PeriodUnit(i.periodUnit, PeriodUnit.years, "periodUnit"));
    e.actionOnExpiry = parseDomainEnumOr!DeletionAction(i.actionOnExpiry, DeletionAction.delete_, "actionOnExpiry");
    e.active = i.active;
  }
}
