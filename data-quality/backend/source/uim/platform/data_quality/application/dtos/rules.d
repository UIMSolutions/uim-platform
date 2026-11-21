/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Requests of the rule catalogs. Enumerations travel as text and are
/// parsed (and rejected) by the interactors.
module uim.platform.data_quality.application.dtos.rules;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct ValidationRuleInput {
  string name;
  string description;
  string datasetPattern;
  string fieldName;
  string ruleType = "required";
  string severity = "error";
  string status = "draft";
  string pattern;
  string minValue;
  string maxValue;
  string[] allowedValues;
  bool caseSensitive = true;
  string crossFieldName;
  string operator = "eq";
  string expression;
  string referenceDataset;
  string referenceField;
  string category;
  int priority = 100;
}

struct CreateValidationRuleRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// "" = generated
  ValidationRuleInput rule;
}

struct UpdateValidationRuleRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  Changes!ValidationRuleInput changes;
}

struct CleansingRuleInput {
  string name;
  string description;
  string datasetPattern;
  string fieldName;
  string action = "trim";
  string status = "draft";
  string findPattern;
  string replaceWith;
  string defaultValue;
  string lookupDataset;
  string lookupKeyField;
  string lookupValueField;
  string sourceField;
  string category;
  int priority = 100;
}

struct CreateCleansingRuleRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  CleansingRuleInput rule;
}

struct UpdateCleansingRuleRequest {
  TenantId tenantId;
  UserId actor;
  string id;
  Changes!CleansingRuleInput changes;
}
