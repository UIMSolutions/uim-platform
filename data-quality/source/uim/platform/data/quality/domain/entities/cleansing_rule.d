/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.entities.cleansing_rule;

// import uim.platform.data.quality.domain.types;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
/// A data cleansing / transformation rule.
struct CleansingRule {
  mixin TenantEntity!(CleansingRuleId);

  string name;
  string description;
  string datasetPattern;
  string fieldName;
  CleansingAction action;
  RuleStatus status = RuleStatus.draft;

  // Action parameters
  string findPattern; // regex to find
  string replaceWith; // replacement value
  string defaultValue; // for defaulted action
  string lookupDataset; // reference data for enrichment
  string lookupField; // field to look up
  bool trimWhitespace;
  bool normalizeCase; // lowercase / uppercase / titlecase
  string caseMode; // "lower", "upper", "title"
  bool removeDiacritics;

  string category;
  int priority;
  
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("datasetPattern", datasetPattern)
      .set("fieldName", fieldName)
      .set("action", action.to!string)
      .set("status", status.to!string)
      .set("findPattern", findPattern)
      .set("replaceWith", replaceWith)
      .set("defaultValue", defaultValue)
      .set("lookupDataset", lookupDataset)
      .set("lookupField", lookupField)
      .set("trimWhitespace", trimWhitespace)
      .set("normalizeCase", normalizeCase)
      .set("caseMode", caseMode)
      .set("removeDiacritics", removeDiacritics)
      .set("category", category)
      .set("priority", priority);
  }
}
