/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.filter_rules;

import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.filter_rule;
import uim.platform.master_data_integration.domain.ports.repositories.filter_rules;
import uim.platform.master_data_integration.domain.types;

/// Application service for filter rule management.
class ManageFilterRulesUseCase : UIMUseCase {
  private FilterRuleRepository repo;

  this(FilterRuleRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateFilterRuleRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Filter rule name is required");

    // import std.uuid : randomUUID;

    FilterRule rule;
    rule.id = randomUUID();
    rule.tenantId = req.tenantId;
    rule.name = req.name;
    rule.description = req.description;
    rule.category = parseCategory(req.category);
    rule.dataModelId = req.dataModelId;
    rule.objectType = req.objectType;
    rule.conditions = toConditions(req.conditions);
    rule.logicOperator = req.logicOperator.length > 0 ? req.logicOperator : "AND";
    rule.isActive = true;
    rule.createdBy = req.createdBy;
    rule.createdAt = clockSeconds();
    rule.modifiedAt = rule.createdAt;

    repo.save(rule);
    return CommandResult(true, id.toString, "");
  }

  CommandResult updateRule(FilterRuleId id, UpdateFilterRuleRequest req) {
    auto rule = repo.findById(id);
    if (rule.id.isEmpty)
      return CommandResult(false, "", "Filter rule not found");

    if (req.name.length > 0)
      rule.name = req.name;
    if (req.description.length > 0)
      rule.description = req.description;
    if (req.conditions.length > 0)
      rule.conditions = toConditions(req.conditions);
    if (req.logicOperator.length > 0)
      rule.logicOperator = req.logicOperator;
    rule.isActive = req.isActive;
    rule.modifiedAt = clockSeconds();

    repo.update(rule);
    return CommandResult(true, id.toString, "");
  }

  FilterRule getRule(FilterRuleId id) {
    return repo.findById(id);
  }

  FilterRule[] listByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  FilterRule[] listByCategory(TenantId tenantId, string category) {
    return repo.findByCategory(tenantId, parseCategory(category));
  }

  FilterRule[] listActive(TenantId tenantId) {
    return repo.findActive(tenantId);
  }

  CommandResult deleteRule(FilterRuleId id) {
    auto rule = repo.findById(id);
    if (rule.id.isEmpty)
      return CommandResult(false, "", "Filter rule not found");
    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  private FilterCondition[] toConditions(FilterConditionDto[] dtos) {
    FilterCondition[] result;
    foreach (dto; dtos) {
      FilterCondition cond;
      cond.fieldName = dto.fieldName;
      cond.operator = parseOperator(dto.operator);
      cond.value = dto.value;
      cond.valueList = dto.valueList;
      cond.lowerBound = dto.lowerBound;
      cond.upperBound = dto.upperBound;
      result ~= cond;
    }
    return result;
  }

  private FilterOperator parseOperator(string s) {
    switch (s) {
    case "equals":
      return FilterOperator.equals;
    case "notEquals":
      return FilterOperator.notEquals;
    case "contains":
      return FilterOperator.contains;
    case "startsWith":
      return FilterOperator.startsWith;
    case "endsWith":
      return FilterOperator.endsWith;
    case "greaterThan":
      return FilterOperator.greaterThan;
    case "lessThan":
      return FilterOperator.lessThan;
    case "inList":
      return FilterOperator.inList;
    case "notInList":
      return FilterOperator.notInList;
    case "between":
      return FilterOperator.between;
    case "isNull":
      return FilterOperator.isNull;
    case "isNotNull":
      return FilterOperator.isNotNull;
    default:
      return FilterOperator.equals;
    }
  }

  private MasterDataCategory parseCategory(string s) {
    switch (s) {
    case "businessPartner":
      return MasterDataCategory.businessPartner;
    case "costCenter":
      return MasterDataCategory.costCenter;
    case "profitCenter":
      return MasterDataCategory.profitCenter;
    case "companyCode":
      return MasterDataCategory.companyCode;
    case "workforcePerson":
      return MasterDataCategory.workforcePerson;
    case "custom":
      return MasterDataCategory.custom;
    default:
      return MasterDataCategory.businessPartner;
    }
  }
}


