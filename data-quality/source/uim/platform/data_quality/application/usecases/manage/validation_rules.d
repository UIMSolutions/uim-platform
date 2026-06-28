/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.application.usecases.manage.validation_rules;


import uim.platform.data_quality;

// mixin(ShowModule!());

@safe:
class ManageValidationRulesUseCase { // TODO: UIMUseCase {
  private ValidationRuleRepository repo;

  this(ValidationRuleRepository repo) {
    this.repo = repo;
  }

  CommandResult createValidationRule(CreateValidationRuleRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Rule name is required");
    if (req.fieldName.length == 0)
      return CommandResult(false, "", "Field name is required");

    ValidationRule rule;
    rule.initEntity(req.tenantId, req.requestedBy);

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
    return CommandResult(true, rule.id.value, "");
  }

  CommandResult updateValidationRule(UpdateValidationRuleRequest req) {
    if (req.ruleId.isEmpty)
      return CommandResult(false, "", "Rule ID is required");

    auto rule = repo.findById(req.tenantId, req.ruleId);
    if (rule.isNull)
      return CommandResult(false, "", "Validation rule not found");
      
    if (rule.tenantId != req.tenantId)
      return CommandResult(false, "", "Tenant mismatch");

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
    return CommandResult(true, rule.id.value, "");
  }

  ValidationRule getValidationRule(TenantId tenantId, ValidationRuleId id) {
    return repo.find(tenantId, id);
  }

  ValidationRule[] listValidationRules(TenantId tenantId) {
    return repo.find(tenantId);
  }

  ValidationRule[] listActive(TenantId tenantId) {
    return repo.findActive(tenantId);
  }

  CommandResult deleteValidationRule(TenantId tenantId, ValidationRuleId id) {
    auto rule = repo.find(tenantId, id);
    if (rule.isNull)
      return CommandResult(false, "", "Validation rule not found");

    repo.remove(rule);
    return CommandResult(true, rule.id.value, "");
  }
}
