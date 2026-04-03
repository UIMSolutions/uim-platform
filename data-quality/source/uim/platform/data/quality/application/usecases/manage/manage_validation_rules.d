/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.application.usecases.manage_validation_rules;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.validation_rule;
import uim.platform.data.quality.domain.ports.validation_rule_repository;
import uim.platform.data.quality.application.dto;

class ManageValidationRulesUseCase
{
  private ValidationRuleRepository repo;

  this(ValidationRuleRepository repo)
  {
    this.repo = repo;
  }

  CommandResult create(CreateValidationRuleRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Rule name is required");
    if (req.fieldName.length == 0)
      return CommandResult("", "Field name is required");

    auto rule = ValidationRule();
    rule.id = randomUUID().toString();
    rule.tenantId = req.tenantId;
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
    rule.createdAt = Clock.currStdTime();
    rule.updatedAt = rule.createdAt;

    repo.save(rule);
    return CommandResult(rule.id, "");
  }

  CommandResult update(UpdateValidationRuleRequest req)
  {
    if (req.id.length == 0)
      return CommandResult("", "Rule ID is required");

    auto existing = repo.findById(req.id);
    if (existing is null)
      return CommandResult("", "Validation rule not found");
    if (existing.tenantId != req.tenantId)
      return CommandResult("", "Tenant mismatch");

    auto rule = *existing;
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
    rule.updatedAt = Clock.currStdTime();

    repo.update(rule);
    return CommandResult(rule.id, "");
  }

  CommandResult remove(RuleId id, TenantId tenantId)
  {
    auto existing = repo.findById(id);
    if (existing is null)
      return CommandResult("", "Validation rule not found");
    if (existing.tenantId != tenantId)
      return CommandResult("", "Tenant mismatch");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }

  ValidationRule* getById(RuleId id)
  {
    return repo.findById(id);
  }

  ValidationRule[] listByTenant(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  ValidationRule[] listActive(TenantId tenantId)
  {
    return repo.findActive(tenantId);
  }
}
