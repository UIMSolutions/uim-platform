/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.application.usecases.manage.cleansing_rules;



// import uim.platform.data_quality.domain.entities.cleansing_rule;
// import uim.platform.data_quality.domain.ports.repositories.cleansing_rules;
// import uim.platform.data_quality.application.dto;
import uim.platform.data_quality;

// mixin(ShowModule!());

@safe:
class ManageCleansingRulesUseCase { // TODO: UIMUseCase {
  private CleansingRuleRepository repo;

  this(CleansingRuleRepository repo) {
    this.repo = repo;
  }

  CommandResult createCleansingRule(CreateCleansingRuleRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Rule name is required");
    if (req.fieldName.length == 0)
      return CommandResult(false, "", "Field name is required");

    auto rule = CleansingRule();
    rule.initEntity(req.tenantId);
    rule.name = req.name;
    rule.description = req.description;
    rule.datasetPattern = req.datasetPattern;
    rule.fieldName = req.fieldName;
    rule.action = req.action;
    rule.status = RuleStatus.draft;
    rule.findPattern = req.findPattern;
    rule.replaceWith = req.replaceWith;
    rule.defaultValue = req.defaultValue;
    rule.lookupDataset = req.lookupDataset;
    rule.lookupField = req.lookupField;
    rule.trimWhitespace = req.trimWhitespace;
    rule.normalizeCase = req.normalizeCase;
    rule.caseMode = req.caseMode;
    rule.removeDiacritics = req.removeDiacritics;
    rule.category = req.category;
    rule.priority = req.priority;

    repo.save(rule);
    return CommandResult(true, rule.id.value, "");
  }

  CommandResult updateCleansingRule(UpdateCleansingRuleRequest req) {
    if (req.ruleId.isEmpty)
      return CommandResult(false, "", "Rule ID is required");

    auto existing = repo.findById(req.tenantId, req.ruleId);
    if (existing.isNull)
      return CommandResult(false, "", "Cleansing rule not found");

    if (existing.tenantId != req.tenantId)
      return CommandResult(false, "", "Tenant mismatch");

    auto rule = existing;
    rule.name = req.name;
    rule.description = req.description;
    rule.datasetPattern = req.datasetPattern;
    rule.fieldName = req.fieldName;
    rule.action = req.action;
    rule.status = req.status;
    rule.findPattern = req.findPattern;
    rule.replaceWith = req.replaceWith;
    rule.defaultValue = req.defaultValue;
    rule.lookupDataset = req.lookupDataset;
    rule.lookupField = req.lookupField;
    rule.trimWhitespace = req.trimWhitespace;
    rule.normalizeCase = req.normalizeCase;
    rule.caseMode = req.caseMode;
    rule.removeDiacritics = req.removeDiacritics;
    rule.category = req.category;
    rule.priority = req.priority;
    rule.updatedAt = currentTimestamp();

    repo.update(rule);
    return CommandResult(true, rule.id.value, "");
  }

  CommandResult deleteCleansingRule(TenantId tenantId, CleansingRuleId id) {
    auto rule = repo.findById(tenantId, id);
    if (rule.isNull)
      return CommandResult(false, "", "Cleansing rule not found");

    if (rule.tenantId != tenantId)
      return CommandResult(false, "", "Tenant mismatch");

    repo.remove(rule);
    return CommandResult(true, rule.id.value, "");
  }

  CleansingRule getCleansingRule(TenantId tenantId, CleansingRuleId id) {
    return repo.findById(tenantId, id);
  }

  CleansingRule[] listCleansingRules(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CleansingRule[] listActiveCleansingRules(TenantId tenantId) {
    return repo.findActive(tenantId);
  }
}
