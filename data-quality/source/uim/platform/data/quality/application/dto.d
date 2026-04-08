/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.application.dto;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.validation_result : RuleViolation;
// import uim.platform.data.quality.domain.entities.match_group : MatchCandidate, FieldMatch;
// import uim.platform.data.quality.domain.entities.data_profile : ColumnProfile;
// import uim.platform.data.quality.domain.entities.quality_dashboard : RuleSeverityCount,
//   QualityTrendPoint;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
// ──────────────── Validation Rule DTOs ────────────────

struct CreateValidationRuleRequest {
  TenantId tenantId;
  string name;
  string description;
  string datasetPattern;
  string fieldName;
  RuleType ruleType;
  RuleSeverity severity;

  string pattern;
  string minValue;
  string maxValue;
  string[] allowedValues;
  string expression;
  string referenceDataset;
  string crossFieldName;

  string category;
  int priority;
}

struct UpdateValidationRuleRequest {
  RuleId id;
  TenantId tenantId;
  string name;
  string description;
  string datasetPattern;
  string fieldName;
  RuleType ruleType;
  RuleSeverity severity;
  RuleStatus status;

  string pattern;
  string minValue;
  string maxValue;
  string[] allowedValues;
  string expression;
  string referenceDataset;
  string crossFieldName;

  string category;
  int priority;
}

// ──────────────── Validation Execution DTOs ────────────────

struct ValidateRecordRequest {
  TenantId tenantId;
  DatasetId datasetId;
  RecordId recordId;
  string[string] fieldValues;
}

struct ValidateBatchRequest {
  TenantId tenantId;
  DatasetId datasetId;
  RecordFieldValues[] records;
}

struct RecordFieldValues {
  RecordId recordId;
  string[string] fieldValues;
}

// ──────────────── Address Cleansing DTOs ────────────────

struct CleanseAddressRequest {
  TenantId tenantId;
  RecordId sourceRecordId;
  string line1;
  string line2;
  string city;
  string region;
  string postalCode;
  string country;
}

struct CleanseBatchAddressRequest {
  TenantId tenantId;
  CleanseAddressRequest[] addresses;
}

// ──────────────── Duplicate Detection DTOs ────────────────

struct DetectDuplicatesRequest {
  TenantId tenantId;
  DatasetId datasetId;
  string[][] matchFields; // groups of fields to compare
  MatchStrategy strategy;
  double threshold = 70.0; // minimum score to consider a match
  DuplicateRecordInput[] records;
}

struct DuplicateRecordInput {
  RecordId recordId;
  string[string] fieldValues;
}

struct ResolveDuplicateRequest {
  TenantId tenantId;
  MatchGroupId groupId;
  RecordId survivorRecordId; // chosen golden record
}

// ──────────────── Data Profiling DTOs ────────────────

struct ProfileDatasetRequest {
  TenantId tenantId;
  DatasetId datasetId;
  string datasetName;
  ProfileRecordInput[] records;
}

struct ProfileRecordInput {
  RecordId recordId;
  string[string] fieldValues;
}

// ──────────────── Cleansing Rule DTOs ────────────────

struct CreateCleansingRuleRequest {
  TenantId tenantId;
  string name;
  string description;
  string datasetPattern;
  string fieldName;
  CleansingAction action;

  string findPattern;
  string replaceWith;
  string defaultValue;
  string lookupDataset;
  string lookupField;
  bool trimWhitespace;
  bool normalizeCase;
  string caseMode;
  bool removeDiacritics;

  string category;
  int priority;
}

struct UpdateCleansingRuleRequest {
  RuleId id;
  TenantId tenantId;
  string name;
  string description;
  string datasetPattern;
  string fieldName;
  CleansingAction action;
  RuleStatus status;

  string findPattern;
  string replaceWith;
  string defaultValue;
  string lookupDataset;
  string lookupField;
  bool trimWhitespace;
  bool normalizeCase;
  string caseMode;
  bool removeDiacritics;

  string category;
  int priority;
}

// ──────────────── Cleansing Job DTOs ────────────────

struct CreateCleansingJobRequest {
  TenantId tenantId;
  DatasetId datasetId;
  UserId requestedBy;
  RuleId[] ruleIds;
}

// ──────────────── Quality Dashboard DTOs ────────────────

struct ComputeDashboardRequest {
  TenantId tenantId;
  DatasetId datasetId;
  string datasetName;
}

