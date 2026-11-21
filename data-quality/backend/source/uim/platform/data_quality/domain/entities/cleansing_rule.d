/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A cleansing (transformation) rule for one field of the datasets
/// matching datasetPattern. Cleansing jobs apply the active rules in
/// priority order.
///
/// Parameters by action:
///   replace        findPattern (regular expression), replaceWith ($1 … for groups)
///   defaultValue   defaultValue
///   enrich         lookupDataset, lookupKeyField, lookupValueField, sourceField
///                  (fieldName := lookupValueField of the lookup record whose
///                   lookupKeyField equals this record's sourceField)
///   others         —
module uim.platform.data_quality.domain.entities.cleansing_rule;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

struct CleansingRule {
  mixin TenantEntity!CleansingRuleId;

  string name;
  string description;
  string datasetPattern;
  string fieldName;
  CleansingAction action = CleansingAction.trim;
  RuleStatus status = RuleStatus.draft;

  string findPattern;
  string replaceWith;
  string defaultValue;
  string lookupDataset;
  string lookupKeyField;
  string lookupValueField;
  string sourceField;

  string category;
  int priority = 100;

  bool isActive() const {
    return status == RuleStatus.active;
  }

  bool appliesTo(DatasetId dataset) const {
    return datasetMatches(datasetPattern, dataset.value);
  }

  void validate() const @trusted {
    requireText(name, "Rule name");
    requireMaxLength(name, 256, "Rule name");
    requireMaxLength(description, 5000, "Description");
    requireFieldName(fieldName);
    requireRange(priority, 0, 100_000, "Priority");
    switch (action) {
    case CleansingAction.replace:
      requireText(findPattern, "findPattern of a replace rule");
      try
        regex(findPattern);
      catch (Exception)
        throw DataQualityException.invalid("findPattern '" ~ findPattern ~ "' is not a valid regular expression");
      break;
    case CleansingAction.defaultValue:
      requireText(defaultValue, "defaultValue");
      break;
    case CleansingAction.enrich:
      requireId(lookupDataset, "Lookup dataset");
      requireFieldName(lookupKeyField, "Lookup key field");
      requireFieldName(lookupValueField, "Lookup value field");
      requireFieldName(sourceField, "Source field");
      break;
    default:
      break;
    }
  }
}

///
unittest {
  CleansingRule r;
  r.name = "Trim email";
  r.fieldName = "email";
  r.validate();
  r.action = CleansingAction.replace;
  assert(failsWith(DqErrorKind.invalid, () { r.validate(); }));
  r.findPattern = "\\s+";
  r.validate();
  r.action = CleansingAction.enrich;
  assert(failsWith(DqErrorKind.invalid, () { r.validate(); }));
}
