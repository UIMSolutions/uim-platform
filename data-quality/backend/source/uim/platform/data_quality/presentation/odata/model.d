/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the CLI and
/// the GtkD GUI.
///
/// Resources inside a dataset have the composite key "<datasetId>~<id>"
/// (property "key"); "id" and "datasetId" are exposed separately for
/// filtering. Record fields are a collection of "name=value" strings.
/// Scopes: Read (reads), Manage (writes, actions).
module uim.platform.data_quality.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.dataquality";

/// Audit properties (all computed).
private ODataEntitySetDef audited(ODataEntitySetDef set) {
  return set.property("tenantId", Edm.string_, "Tenant")
    .property("createdAt", Edm.dateTimeOffset, "Created At")
    .property("createdBy", Edm.string_, "Created By")
    .property("updatedAt", Edm.dateTimeOffset, "Changed At")
    .property("updatedBy", Edm.string_, "Changed By")
    .computed("tenantId", "createdAt", "createdBy", "updatedAt", "updatedBy");
}

/// Composite key, id and dataset of dataset scoped sets.
private ODataEntitySetDef scoped(ODataEntitySetDef set, string idLabel = "ID") {
  return set.property("key", Edm.string_, "Key", false)
    .keyed("key")
    .property("id", Edm.string_, idLabel)
    .property("datasetId", Edm.string_, "Dataset", false)
    .computed("key")
    .immutableProps("id", "datasetId");
}

/// The five dimension scores, the overall score and its rating.
private ODataEntitySetDef scored(ODataEntitySetDef set) {
  return set.property("overallScore", Edm.double_, "Quality Score")
    .property("rating", Edm.string_, "Rating")
    .property("completeness", Edm.double_, "Completeness")
    .property("validity", Edm.double_, "Validity")
    .property("uniqueness", Edm.double_, "Uniqueness")
    .property("consistency", Edm.double_, "Consistency")
    .property("accuracy", Edm.double_, "Accuracy")
    .computed("overallScore", "rating", "completeness", "validity", "uniqueness", "consistency", "accuracy");
}

private ODataComplexTypeDef scoreProperties(ODataComplexTypeDef t) {
  return t.property("overallScore", Edm.double_, "Quality Score")
    .property("rating", Edm.string_, "Rating")
    .property("completeness", Edm.double_, "Completeness")
    .property("validity", Edm.double_, "Validity")
    .property("uniqueness", Edm.double_, "Uniqueness")
    .property("consistency", Edm.double_, "Consistency")
    .property("accuracy", Edm.double_, "Accuracy");
}

ODataServiceModel dataQualityModel() {
  auto m = new ODataServiceModel(odataNamespace, "DataQualityService", "Data Quality");

  audited(scored(m.entitySet("Datasets", "Dataset")
      .property("id", Edm.string_, "Dataset", false)
      .property("name", Edm.string_, "Name")
      .property("description", Edm.string_, "Description")
      .property("category", Edm.string_, "Category")
      .property("recordCount", Edm.int32, "Records")
      .property("invalidRecords", Edm.int32, "Invalid Records")
      .property("violationCount", Edm.int32, "Violations")
      .property("openDuplicates", Edm.int32, "Open Duplicates")
      .property("scoredAt", Edm.dateTimeOffset, "Scored At")
      .property("validatedAt", Edm.dateTimeOffset, "Validated At")
      .property("profiledAt", Edm.dateTimeOffset, "Profiled At")
      .property("duplicatesCheckedAt", Edm.dateTimeOffset, "Duplicates Checked At")
      .computed("recordCount", "invalidRecords", "violationCount", "openDuplicates", "scoredAt", "validatedAt", "profiledAt",
        "duplicatesCheckedAt")))
    .writable()
    .titled("Dataset", "Datasets", "name", "description")
    .columns("name", "id", "category", "recordCount", "overallScore", "rating", "violationCount", "validatedAt")
    .filters("category", "rating")
    .scopes(readScope, manageScope);

  audited(scoped(m.entitySet("Records", "Record"), "Record ID")
      .collection("fields", Edm.string_, "Fields (name=value)")
      .property("fieldsText", Edm.string_, "Fields")
      .property("summary", Edm.string_, "Summary")
      .property("fieldCount", Edm.int32, "Fields")
      .property("qualityScore", Edm.double_, "Quality Score")
      .property("rulesChecked", Edm.int32, "Rules Checked")
      .property("violationCount", Edm.int32, "Violations")
      .property("worstSeverity", Edm.string_, "Worst Severity")
      .property("validatedAt", Edm.dateTimeOffset, "Validated At")
      .computed("fieldsText", "summary", "fieldCount", "qualityScore", "rulesChecked", "violationCount", "worstSeverity", "validatedAt"))
    .writable()
    .titled("Record", "Records", "id", "summary")
    .columns("id", "summary", "qualityScore", "violationCount", "worstSeverity", "datasetId")
    .filters("datasetId", "worstSeverity")
    .scopes(readScope, manageScope);

  audited(m.entitySet("ValidationRules", "ValidationRule")
      .property("id", Edm.string_, "Rule ID", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("datasetPattern", Edm.string_, "Datasets (pattern)")
      .property("fieldName", Edm.string_, "Field")
      .property("ruleType", Edm.string_, "Type")
      .property("dimension", Edm.string_, "Dimension")
      .property("severity", Edm.string_, "Severity")
      .property("status", Edm.string_, "Status")
      .property("pattern", Edm.string_, "Pattern (regex)")
      .property("minValue", Edm.string_, "Minimum")
      .property("maxValue", Edm.string_, "Maximum")
      .collection("allowedValues", Edm.string_, "Allowed Values")
      .property("caseSensitive", Edm.boolean, "Case Sensitive")
      .property("crossFieldName", Edm.string_, "Other Field")
      .property("operator", Edm.string_, "Operator")
      .property("expression", Edm.string_, "Expression")
      .property("referenceDataset", Edm.string_, "Reference Dataset")
      .property("referenceField", Edm.string_, "Reference Field")
      .property("category", Edm.string_, "Category")
      .property("priority", Edm.int32, "Priority")
      .computed("dimension"))
    .writable()
    .titled("Validation Rule", "Validation Rules", "name", "fieldName")
    .columns("name", "fieldName", "ruleType", "severity", "status", "datasetPattern", "priority")
    .filters("ruleType", "severity", "status", "category")
    .scopes(readScope, manageScope);

  audited(scoped(m.entitySet("Violations", "Violation"), "Violation ID")
      .property("recordId", Edm.string_, "Record")
      .property("recordKey", Edm.string_, "Record Key")
      .property("ruleId", Edm.string_, "Rule")
      .property("ruleName", Edm.string_, "Rule Name")
      .property("ruleType", Edm.string_, "Rule Type")
      .property("dimension", Edm.string_, "Dimension")
      .property("fieldName", Edm.string_, "Field")
      .property("fieldValue", Edm.string_, "Value")
      .property("severity", Edm.string_, "Severity")
      .property("message", Edm.string_, "Message")
      .property("suggestedValue", Edm.string_, "Suggestion"))
    .writable(false, false, false)
    .titled("Violation", "Violations", "message", "ruleName")
    .columns("recordId", "fieldName", "fieldValue", "severity", "message", "suggestedValue", "datasetId")
    .filters("datasetId", "severity", "ruleId", "dimension", "recordId")
    .scopes(readScope, manageScope);

  audited(m.entitySet("CleansingRules", "CleansingRule")
      .property("id", Edm.string_, "Rule ID", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("datasetPattern", Edm.string_, "Datasets (pattern)")
      .property("fieldName", Edm.string_, "Field", false)
      .property("action", Edm.string_, "Action")
      .property("status", Edm.string_, "Status")
      .property("findPattern", Edm.string_, "Find (regex)")
      .property("replaceWith", Edm.string_, "Replace With")
      .property("defaultValue", Edm.string_, "Default Value")
      .property("lookupDataset", Edm.string_, "Lookup Dataset")
      .property("lookupKeyField", Edm.string_, "Lookup Key Field")
      .property("lookupValueField", Edm.string_, "Lookup Value Field")
      .property("sourceField", Edm.string_, "Source Field")
      .property("category", Edm.string_, "Category")
      .property("priority", Edm.int32, "Priority"))
    .writable()
    .titled("Cleansing Rule", "Cleansing Rules", "name", "fieldName")
    .columns("name", "fieldName", "action", "status", "datasetPattern", "priority")
    .filters("action", "status", "category")
    .scopes(readScope, manageScope);

  audited(scoped(m.entitySet("CleansingJobs", "CleansingJob"), "Job ID")
      .collection("ruleIds", Edm.string_, "Rules (empty = all active)")
      .property("dryRun", Edm.boolean, "Dry Run")
      .property("revalidate", Edm.boolean, "Revalidate")
      .property("status", Edm.string_, "Status")
      .property("totalRecords", Edm.int32, "Records")
      .property("processedRecords", Edm.int32, "Processed")
      .property("changedRecords", Edm.int32, "Changed Records")
      .property("changedFields", Edm.int32, "Changed Fields")
      .property("rulesApplied", Edm.int32, "Rules Applied")
      .property("errorMessage", Edm.string_, "Error")
      .collection("changeLog", Edm.string_, "Changes")
      .property("changeLogText", Edm.string_, "Changes (summary)")
      .property("startedAt", Edm.dateTimeOffset, "Started At")
      .property("completedAt", Edm.dateTimeOffset, "Completed At")
      .property("durationMillis", Edm.int32, "Duration (ms)")
      .computed("id", "status", "totalRecords", "processedRecords", "changedRecords", "changedFields", "rulesApplied",
        "errorMessage", "changeLog", "changeLogText", "startedAt", "completedAt", "durationMillis")
      .immutableProps("ruleIds", "dryRun", "revalidate"))
    .writable(true, false, true)
    .titled("Cleansing Job", "Cleansing Jobs", "id", "status")
    .columns("id", "status", "datasetId", "dryRun", "changedRecords", "changedFields", "completedAt")
    .filters("datasetId", "status")
    .scopes(readScope, manageScope);

  audited(scoped(m.entitySet("MatchGroups", "MatchGroup"), "Group ID")
      .property("strategy", Edm.string_, "Strategy")
      .property("threshold", Edm.double_, "Threshold")
      .collection("matchFields", Edm.string_, "Match Fields")
      .collection("candidates", Edm.string_, "Candidates (recordId=score)")
      .property("candidatesText", Edm.string_, "Candidates (summary)")
      .property("matchFieldsText", Edm.string_, "Match Fields (summary)")
      .property("size", Edm.int32, "Records")
      .property("bestScore", Edm.double_, "Best Score")
      .property("survivorRecordId", Edm.string_, "Golden Record")
      .property("resolved", Edm.boolean, "Resolved")
      .property("detectedAt", Edm.dateTimeOffset, "Detected At")
      .property("resolvedAt", Edm.dateTimeOffset, "Resolved At")
      .computed("candidatesText", "matchFieldsText"))
    .writable(false, false, true)
    .titled("Match Group", "Match Groups", "survivorRecordId", "strategy")
    .columns("survivorRecordId", "size", "bestScore", "strategy", "resolved", "datasetId")
    .filters("datasetId", "resolved", "strategy")
    .scopes(readScope, manageScope);

  audited(scoped(m.entitySet("ColumnProfiles", "ColumnProfile"), "Field")
      .property("position", Edm.int32, "Position")
      .property("detectedType", Edm.string_, "Type")
      .property("totalValues", Edm.int32, "Records")
      .property("missingCount", Edm.int32, "Missing")
      .property("distinctCount", Edm.int32, "Distinct")
      .property("duplicateCount", Edm.int32, "Repeated")
      .property("completeness", Edm.double_, "Completeness")
      .property("uniqueness", Edm.double_, "Uniqueness")
      .property("minValue", Edm.string_, "Minimum")
      .property("maxValue", Edm.string_, "Maximum")
      .property("mean", Edm.double_, "Mean")
      .property("numeric", Edm.boolean, "Numeric")
      .property("minLength", Edm.int32, "Min Length")
      .property("maxLength", Edm.int32, "Max Length")
      .property("avgLength", Edm.double_, "Avg Length")
      .collection("topValues", Edm.string_, "Top Values")
      .collection("patterns", Edm.string_, "Patterns")
      .property("topValuesText", Edm.string_, "Top Values (summary)")
      .property("patternsText", Edm.string_, "Patterns (summary)")
      .property("profiledAt", Edm.dateTimeOffset, "Profiled At"))
    .writable(false, false, false)
    .titled("Column Profile", "Column Profiles", "id", "detectedType")
    .columns("id", "detectedType", "completeness", "uniqueness", "distinctCount", "minValue", "maxValue", "datasetId")
    .filters("datasetId", "detectedType")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Addresses", "Address")
      .property("id", Edm.string_, "Address ID", false)
      .property("sourceRecordId", Edm.string_, "Source Record")
      .property("inputLine1", Edm.string_, "Street (input)")
      .property("inputLine2", Edm.string_, "Address Line 2 (input)")
      .property("inputCity", Edm.string_, "City (input)")
      .property("inputRegion", Edm.string_, "Region (input)")
      .property("inputPostalCode", Edm.string_, "Postal Code (input)")
      .property("inputCountry", Edm.string_, "Country (input)")
      .property("line1", Edm.string_, "Street")
      .property("line2", Edm.string_, "Address Line 2")
      .property("city", Edm.string_, "City")
      .property("region", Edm.string_, "Region")
      .property("postalCode", Edm.string_, "Postal Code")
      .property("country", Edm.string_, "Country")
      .property("countryRecognized", Edm.boolean, "Country Recognized")
      .property("postalCodePlausible", Edm.boolean, "Postal Code Plausible")
      .property("quality", Edm.string_, "Quality")
      .collection("changes", Edm.string_, "Changes")
      .property("changesText", Edm.string_, "Changes (summary)")
      .property("cleansedAt", Edm.dateTimeOffset, "Cleansed At")
      .computed("id", "line1", "line2", "city", "region", "postalCode", "country", "countryRecognized", "postalCodePlausible",
        "quality", "changes", "changesText", "cleansedAt"))
    .writable(true, false, true)
    .titled("Address", "Addresses", "line1", "city")
    .columns("line1", "postalCode", "city", "country", "quality", "inputCountry")
    .filters("quality", "country")
    .scopes(readScope, manageScope);

  audited(scored(scoped(m.entitySet("QualitySnapshots", "QualitySnapshot"), "Snapshot ID")
      .property("recordCount", Edm.int32, "Records")
      .property("violationCount", Edm.int32, "Violations")
      .property("takenAt", Edm.dateTimeOffset, "Taken At")))
    .writable(false, false, true)
    .titled("Quality Snapshot", "Quality Snapshots", "takenAt", "rating")
    .columns("takenAt", "overallScore", "rating", "recordCount", "violationCount", "datasetId")
    .filters("datasetId", "rating")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Users", "User")
      .property("id", Edm.string_, "User Name", false)
      .property("displayName", Edm.string_, "Name")
      .property("password", Edm.string_, "Password (write only)")
      .collection("scopes", Edm.string_, "Scopes (Read, Manage, Admin)")
      .property("scopesText", Edm.string_, "Scopes (summary)")
      .property("locked", Edm.boolean, "Locked")
      .property("temporarilyLocked", Edm.boolean, "Temporarily Locked")
      .property("failedLogins", Edm.int32, "Failed Logins")
      .property("lastLoginAt", Edm.dateTimeOffset, "Last Login")
      .computed("scopesText", "temporarilyLocked", "failedLogins", "lastLoginAt"))
    .writable()
    .titled("User", "Users", "id", "displayName")
    .columns("id", "displayName", "scopes", "locked", "lastLoginAt")
    .filters("locked")
    .scopes(adminScope, adminScope);

  m.singletonSet("Statistics", "Statistic")
    .keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false)
    .property("datasets", Edm.int32, "Datasets")
    .property("scoredDatasets", Edm.int32, "Scored Datasets")
    .property("records", Edm.int32, "Records")
    .property("validatedRecords", Edm.int32, "Validated Records")
    .property("invalidRecords", Edm.int32, "Invalid Records")
    .property("validationRules", Edm.int32, "Validation Rules")
    .property("activeValidationRules", Edm.int32, "Active Validation Rules")
    .property("violations", Edm.int32, "Violations")
    .property("criticalViolations", Edm.int32, "Critical Violations")
    .property("errorViolations", Edm.int32, "Error Violations")
    .property("warningViolations", Edm.int32, "Warnings")
    .property("cleansingRules", Edm.int32, "Cleansing Rules")
    .property("activeCleansingRules", Edm.int32, "Active Cleansing Rules")
    .property("cleansingJobs", Edm.int32, "Cleansing Jobs")
    .property("pendingJobs", Edm.int32, "Pending Jobs")
    .property("failedJobs", Edm.int32, "Failed Jobs")
    .property("matchGroups", Edm.int32, "Match Groups")
    .property("openMatchGroups", Edm.int32, "Open Match Groups")
    .property("duplicateRecords", Edm.int32, "Duplicate Records")
    .property("addresses", Edm.int32, "Addresses")
    .property("verifiedAddresses", Edm.int32, "Verified Addresses")
    .property("invalidAddresses", Edm.int32, "Invalid Addresses")
    .property("averageScore", Edm.double_, "Average Quality Score")
    .property("rating", Edm.string_, "Rating")
    .property("computedAt", Edm.dateTimeOffset, "Computed At")
    .titled("Statistics", "Statistics")
    .scopes(readScope, "");

  // ── result types ────────────────────────────────────────────────────────
  scoreProperties(m.complexType("ValidationRunResult")
      .property("datasetId", Edm.string_, "Dataset")
      .property("records", Edm.int32, "Records")
      .property("validRecords", Edm.int32, "Valid Records")
      .property("invalidRecords", Edm.int32, "Invalid Records")
      .property("violations", Edm.int32, "Violations")
      .property("rulesApplied", Edm.int32, "Rules Applied")
      .property("averageScore", Edm.double_, "Average Record Score")
      .property("durationMillis", Edm.int32, "Duration (ms)"));

  m.complexType("RecordValidation")
    .property("key", Edm.string_, "Key")
    .property("qualityScore", Edm.double_, "Quality Score")
    .property("rulesChecked", Edm.int32, "Rules Checked")
    .property("violationCount", Edm.int32, "Violations")
    .property("worstSeverity", Edm.string_, "Worst Severity");

  m.complexType("ProfileRunResult")
    .property("datasetId", Edm.string_, "Dataset")
    .property("records", Edm.int32, "Records")
    .property("columns", Edm.int32, "Columns")
    .property("completeness", Edm.double_, "Completeness")
    .property("uniqueness", Edm.double_, "Uniqueness")
    .property("durationMillis", Edm.int32, "Duration (ms)");

  m.complexType("DetectResult")
    .property("datasetId", Edm.string_, "Dataset")
    .property("records", Edm.int32, "Records")
    .property("groups", Edm.int32, "Match Groups")
    .property("duplicateRecords", Edm.int32, "Duplicates")
    .property("strategy", Edm.string_, "Strategy")
    .property("threshold", Edm.double_, "Threshold")
    .property("durationMillis", Edm.int32, "Duration (ms)");

  m.complexType("ResolveResult")
    .property("datasetId", Edm.string_, "Dataset")
    .property("matchGroupId", Edm.string_, "Match Group")
    .property("survivorRecordId", Edm.string_, "Golden Record")
    .property("removedRecords", Edm.int32, "Removed Records")
    .property("mergedFields", Edm.int32, "Merged Fields");

  scoreProperties(m.complexType("Scorecard")
      .property("datasetId", Edm.string_, "Dataset")
      .property("records", Edm.int32, "Records")
      .property("violations", Edm.int32, "Violations")
      .property("openDuplicates", Edm.int32, "Open Duplicates")
      .property("computedAt", Edm.dateTimeOffset, "Computed At"));

  m.complexType("JobResult")
    .property("key", Edm.string_, "Key")
    .property("id", Edm.string_, "Job")
    .property("status", Edm.string_, "Status")
    .property("changedRecords", Edm.int32, "Changed Records")
    .property("changedFields", Edm.int32, "Changed Fields")
    .property("errorMessage", Edm.string_, "Error");

  m.complexType("ImportResult")
    .property("datasetId", Edm.string_, "Dataset")
    .property("datasetCreated", Edm.boolean, "Dataset Created")
    .property("created", Edm.int32, "Created")
    .property("updated", Edm.int32, "Updated")
    .property("skipped", Edm.int32, "Skipped")
    .property("validated", Edm.boolean, "Validated")
    .property("violations", Edm.int32, "Violations")
    .property("overallScore", Edm.double_, "Quality Score");

  m.complexType("SeedResult")
    .property("datasets", Edm.int32, "Datasets")
    .property("records", Edm.int32, "Records")
    .property("validationRules", Edm.int32, "Validation Rules")
    .property("cleansingRules", Edm.int32, "Cleansing Rules")
    .property("addresses", Edm.int32, "Addresses")
    .property("violations", Edm.int32, "Violations")
    .property("matchGroups", Edm.int32, "Match Groups")
    .property("cleansingJobs", Edm.int32, "Cleansing Jobs");

  // ── actions ─────────────────────────────────────────────────────────────
  m.action("ValidateDataset", "ValidationRunResult").parameter("datasetId", Edm.string_, false)
    .labelled("Validate Dataset").requires(manageScope);
  m.action("ValidateRecord", "RecordValidation").parameter("key", Edm.string_, false)
    .labelled("Validate Record (record key)").requires(manageScope);
  m.action("ProfileDataset", "ProfileRunResult").parameter("datasetId", Edm.string_, false)
    .labelled("Profile Dataset").requires(manageScope);
  m.action("DetectDuplicates", "DetectResult").parameter("datasetId", Edm.string_, false)
    .parameter("matchFields", Edm.string_, false).parameter("strategy", Edm.string_).parameter("threshold", Edm.double_)
    .labelled("Detect Duplicates (match fields comma separated)").requires(manageScope);
  m.action("ResolveMatchGroup", "ResolveResult").parameter("key", Edm.string_, false)
    .parameter("survivorRecordId", Edm.string_).parameter("merge", Edm.boolean)
    .labelled("Resolve Match Group").requires(manageScope);
  m.action("ComputeScorecard", "Scorecard").parameter("datasetId", Edm.string_, false)
    .labelled("Compute Scorecard").requires(manageScope);
  m.action("TakeSnapshot", "Scorecard").parameter("datasetId", Edm.string_, false)
    .labelled("Record Quality Snapshot").requires(manageScope);
  m.action("RunCleansingJob", "JobResult").parameter("key", Edm.string_, false)
    .labelled("Run Cleansing Job").requires(manageScope);
  m.action("CancelCleansingJob", "JobResult").parameter("key", Edm.string_, false)
    .labelled("Cancel Cleansing Job").requires(manageScope);
  m.action("ImportCsv", "ImportResult").parameter("datasetId", Edm.string_, false).parameter("csv", Edm.string_, false)
    .parameter("createDataset", Edm.boolean).parameter("replaceExisting", Edm.boolean)
    .labelled("Import Records (CSV with header line)").requires(manageScope);
  m.action("SeedDemoData", "SeedResult").labelled("Create Demo Content").requires(manageScope);

  m.validate();
  return m;
}

///
unittest {
  auto m = dataQualityModel();
  assert(m.has("Records") && m.find("Statistics").singleton);
  assert(m.find("Records").key == "key" && m.find("Datasets").key == "id");
  assert(m.find("CleansingJobs").insertable && !m.find("CleansingJobs").updatable);
  assert(!m.find("Violations").insertable && m.find("Datasets").propertyOf("overallScore").computed);
  assert(m.findAction("DetectDuplicates").returnEdmType == "uim.dataquality.DetectResult");
}
