/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.retention_rules;

// import uim.platform.data.privacy.domain.entities.retention_rule;
// import uim.platform.data.privacy.domain.ports.repositories.retention_rules;
// import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageRetentionRulesUseCase {
  protected IRetentionRuleRepository repo;

  this(IRetentionRuleRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createRule(CreateRetentionRuleRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Rule name is required");
    if (req.retentionDays <= 0)
      return UsecaseResult(false, "", "Retention days must be positive");

    auto rule = RetentionRule(req.tenantId);
    rule.name = req.name;
    rule.description = req.description;
    rule.purpose = req.purpose.toProcessingPurpose;
    rule.categories = req.categories.map!(c => c.toPersonalDataCategory).array;
    rule.retentionDays = req.retentionDays;
    rule.legalReference = req.legalReference;
    rule.status = RetentionRuleStatus.active;
    rule.isDefault = req.isDefault;

    repo.save(rule);
    return UsecaseResult(true, rule.id.value, "");
  }

  RetentionRule getRule(TenantId tenantId, RetentionRuleId id) {
    return repo.findById(tenantId, id);
  }

  RetentionRule[] listRules(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  RetentionRule[] listRules(TenantId tenantId, ProcessingPurpose purpose) {
    return repo.findByPurpose(tenantId, purpose);
  }

  UsecaseResult updateRule(UpdateRetentionRuleRequest req) {
    auto rule = repo.findById(req.tenantId, req.ruleId);
    if (rule.isNull)
      return UsecaseResult(false, "", "Retention rule not found");

    if (req.name.length > 0)
      rule.name = req.name;
    if (req.description.length > 0)
      rule.description = req.description;
    if (req.retentionDays > 0)
      rule.retentionDays = req.retentionDays;
    if (req.categories.length > 0)
      rule.categories = req.categories.map!(c => c.toPersonalDataCategory).array;
    if (req.legalReference.length > 0)
      rule.legalReference = req.legalReference;
    rule.status = req.status.toRetentionRuleStatus;
    rule.updatedAt = currentTimestamp();

    repo.update(rule);
    return UsecaseResult(true, rule.id.value, "");
  }

  UsecaseResult deleteRule(TenantId tenantId, RetentionRuleId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Retention rule not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }
}
