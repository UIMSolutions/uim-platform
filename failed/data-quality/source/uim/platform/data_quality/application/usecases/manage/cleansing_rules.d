/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.application.usecases.manage.cleansing_rules;

// import uim.platform.data_quality.domain.entities.cleansing_rule;
// import uim.platform.data_quality.domain.ports.repositories.cleansing_rules;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class ManageCleansingRulesUseCase {
  protected ICleansingRuleRepository repo;

  this(ICleansingRuleRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createCleansingRule(CreateCleansingRuleRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Rule name is required");
    if (req.fieldname.isEmpty)
      return UsecaseResult(false, "", "Field name is required");

    auto rule = CleansingRule(req.tenantId);
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
    return UsecaseResult(true, rule.id.value, "");
  }

  UsecaseResult updateCleansingRule(UpdateCleansingRuleRequest req) {
    if (req.ruleId.isEmpty)
      return UsecaseResult(false, "", "Rule ID is required");

    auto existing = repo.findById(req.tenantId, req.ruleId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Cleansing rule not found");

    if (existing.tenantId != req.tenantId)
      return UsecaseResult(false, "", "Tenant mismatch");

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
    return UsecaseResult(true, rule.id.value, "");
  }

  UsecaseResult deleteCleansingRule(TenantId tenantId, CleansingRuleId id) {
    auto rule = repo.findById(tenantId, id);
    if (rule.isNull)
      return UsecaseResult(false, "", "Cleansing rule not found");

    if (rule.tenantId != tenantId)
      return UsecaseResult(false, "", "Tenant mismatch");

    repo.remove(rule);
    return UsecaseResult(true, rule.id.value, "");
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
