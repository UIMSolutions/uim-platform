/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.retention_rules;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.retention_rule;
// import uim.platform.data.privacy.domain.ports.repositories.retention_rules;
// import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageRetentionRulesUseCase : UIMUseCase {
  private RetentionRuleRepository repo;

  this(RetentionRuleRepository repo) {
    this.repo = repo;
  }

  CommandResult createRule(CreateRetentionRuleRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Rule name is required");
    if (req.retentionDays <= 0)
      return CommandResult("", "Retention days must be positive");

    auto now = Clock.currStdTime();
    auto rule = RetentionRule();
    rule.id = randomUUID();
    rule.tenantId = req.tenantId;
    rule.name = req.name;
    rule.description = req.description;
    rule.purpose = req.purpose;
    rule.categories = req.categories;
    rule.retentionDays = req.retentionDays;
    rule.legalReference = req.legalReference;
    rule.status = RetentionRuleStatus.active;
    rule.isDefault = req.isDefault;
    rule.createdAt = now;
    rule.updatedAt = now;

    repo.save(rule);
    return CommandResult(rule.id, "");
  }

  RetentionRule* getRule(RetentionRuleId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  RetentionRule[] listRules(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  RetentionRule[] listByPurpose(TenantId tenantId, ProcessingPurpose purpose) {
    return repo.findByPurpose(tenantId, purpose);
  }

  CommandResult updateRule(UpdateRetentionRuleRequest req) {
    auto rule = repo.findById(req.id, req.tenantId);
    if (rule is null)
      return CommandResult("", "Retention rule not found");

    if (req.name.length > 0)
      rule.name = req.name;
    if (req.description.length > 0)
      rule.description = req.description;
    if (req.retentionDays > 0)
      rule.retentionDays = req.retentionDays;
    if (req.categories.length > 0)
      rule.categories = req.categories;
    if (req.legalReference.length > 0)
      rule.legalReference = req.legalReference;
    rule.status = req.status;
    rule.updatedAt = Clock.currStdTime();

    repo.update(*rule);
    return CommandResult(rule.id, "");
  }

  void deleteRule(RetentionRuleId id, TenantId tenantId) {
    repo.remove(id, tenantId);
  }
}
