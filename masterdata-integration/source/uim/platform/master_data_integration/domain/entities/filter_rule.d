/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.entities.filter_rule;

import uim.platform.master_data_integration.domain.types;

/// A filter rule for selective master data distribution.
struct FilterRule {
  FilterRuleId id;
  TenantId tenantId;
  string name;
  string description;

  // Target scope
  MasterDataCategory category = MasterDataCategory.businessPartner;
  DataModelId dataModelId;
  string objectType;

  // Conditions
  FilterCondition[] conditions;
  string logicOperator; // "AND" or "OR"

  bool isActive;
  UserId createdBy;
  long createdAt;
  long updatedAt;
}

/// A single filter condition.
struct FilterCondition {
  string fieldName;
  FilterOperator operator = FilterOperator.equals;
  string value;
  string[] valueList; // For inList / notInList operators
  string lowerBound; // For between operator
  string upperBound; // For between operator
}
