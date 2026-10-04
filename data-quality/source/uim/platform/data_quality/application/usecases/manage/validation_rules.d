/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.application.usecases.manage.validation_rules;


import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class ManageValidationRulesUseCase {
  protected IValidationRuleRepository repo;

  this(IValidationRuleRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createValidationRule(CreateValidationRuleRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Rule name is required");
    if (req.fieldname.isEmpty)
      return UsecaseResult(false, "", "Field name is required");

    auto rule = ValidationRule(req.tenantId);
    rule.name = req.name;
    rule.description = req.description;
    rule.datasetPattern = req.datasetPattern;
    rule.fieldName = req.fieldName;
    rule.ruleType = req.ruleType;
    rule.severity = req.severity;
    rule.status = RuleStatus.draft;
    rule.pattern = req.pattern;
    rule.minValue = req.minValue;
    rule.maxValue = req.maxValue;
    rule.allowedValues = req.allowedValues;
    rule.expression = req.expression;
    rule.referenceDataset = req.referenceDataset;
    rule.crossFieldName = req.crossFieldName;
    rule.category = req.category;
    rule.priority = req.priority;

    repo.save(rule);
    return UsecaseResult(true, rule.id.value, "");
  }

  UsecaseResult updateValidationRule(UpdateValidationRuleRequest req) {
    if (req.ruleId.isEmpty)
      return UsecaseResult(false, "", "Rule ID is required");

    auto rule = repo.findById(req.tenantId, req.ruleId);
    if (rule.isNull)
      return UsecaseResult(false, "", "Validation rule not found");
      
    if (rule.tenantId != req.tenantId)
      return UsecaseResult(false, "", "Tenant mismatch");

    rule.name = req.name;
    rule.description = req.description;
    rule.datasetPattern = req.datasetPattern;
    rule.fieldName = req.fieldName;
    rule.ruleType = req.ruleType;
    rule.severity = req.severity;
    rule.status = req.status;
    rule.pattern = req.pattern;
    rule.minValue = req.minValue;
    rule.maxValue = req.maxValue;
    rule.allowedValues = req.allowedValues;
    rule.expression = req.expression;
    rule.referenceDataset = req.referenceDataset;
    rule.crossFieldName = req.crossFieldName;
    rule.category = req.category;
    rule.priority = req.priority;
    rule.updatedAt = currentTimestamp();

    repo.update(rule);
    return UsecaseResult(true, rule.id.value, "");
  }

  ValidationRule getValidationRule(TenantId tenantId, ValidationRuleId id) {
    return repo.findById(tenantId, id);
  }

  ValidationRule[] listValidationRules(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  ValidationRule[] listActive(TenantId tenantId) {
    return repo.findActive(tenantId);
  }

  UsecaseResult deleteValidationRule(TenantId tenantId, ValidationRuleId id) {
    auto rule = repo.findById(tenantId, id);
    if (rule.isNull)
      return UsecaseResult(false, "", "Validation rule not found");

    repo.remove(rule);
    return UsecaseResult(true, rule.id.value, "");
  }
}
