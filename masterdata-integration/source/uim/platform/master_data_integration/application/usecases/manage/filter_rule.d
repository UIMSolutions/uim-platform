/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.filter_rule;

// import uim.platform.master_data_integration.domain.entities.filter_rule;
// import uim.platform.master_data_integration.domain.ports.repositories.filter_rules;

import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
/// Application service for filter rule management.
class ManageFilterRulesUseCase { // TODO: UIMUseCase {
  private FilterRuleRepository repo;

  this(FilterRuleRepository repo) {
    this.repo = repo;
  }

  CommandResult createRule(CreateFilterRuleRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Filter rule name is required");

    auto rule = FilterRule(req.tenantId); //, UserId("test-user"));
    rule.name = req.name;
    rule.description = req.description;
    rule.category = toMasterDataCategory(req.category);
    rule.dataModelId = req.modelId;
    rule.objectType = req.objectType;
    rule.conditions = toConditions(req.conditions);
    rule.logicOperator = req.logicOperator.length > 0 ? req.logicOperator : "AND";
    rule.isActive = true;

    repo.save(rule);
    return CommandResult(true, rule.id.value, "");
  }

  CommandResult updateRule(UpdateFilterRuleRequest req) {
    auto rule = repo.findById(req.tenantId, req.ruleId);
    if (rule.isNull)
      return CommandResult(false, "", "Filter rule not found");

    if (req.name.length > 0)
      rule.description = req.description;
    if (req.conditions.length > 0)
      rule.conditions = toConditions(req.conditions);
    if (req.logicOperator.length > 0)
      rule.logicOperator = req.logicOperator;
    rule.isActive = req.isActive;
    rule.updatedAt = clockSeconds();

    repo.update(rule);
    return CommandResult(true, rule.id.value, "");
  }

  FilterRule getRule(TenantId tenantId, FilterRuleId id) {
    return repo.findById(tenantId, id);
  }

  FilterRule[] listRules(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  FilterRule[] listRulesByCategory(TenantId tenantId, string category) {
    return repo.findByCategory(tenantId, toMasterDataCategory(category));
  }

  FilterRule[] listRulesActive(TenantId tenantId) {
    return repo.findActive(tenantId);
  }

  CommandResult deleteRule(TenantId tenantId, FilterRuleId id) {
    auto rule = repo.findById(tenantId, id);
    if (rule.isNull)
      return CommandResult(false, "", "Filter rule not found");
      
    repo.remove(rule);
    return CommandResult(true, rule.id.value, "");
  }

  private FilterCondition[] toConditions(FilterConditionDto[] dtos) {
    FilterCondition[] result;
    foreach (dto; dtos) {
      FilterCondition cond;
      cond.fieldName = dto.fieldName;
      cond.operator = toFilterOperator(dto.operator);
      cond.value = dto.value;
      cond.valueList = dto.valueList;
      cond.lowerBound = dto.lowerBound;
      cond.upperBound = dto.upperBound;
      result ~= cond;
    }
    return result;
  }
}


