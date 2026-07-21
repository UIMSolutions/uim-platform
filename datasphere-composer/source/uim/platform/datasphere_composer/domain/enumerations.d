/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.enumerations;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:

/// Unification algorithm model
enum UnificationModel : string {
  deterministic = "DETERMINISTIC",
  probabilistic  = "PROBABILISTIC"
}
UnificationModel toUnificationModel(string model) {
  mixin(EnumSwitch("UnificationModel", "deterministic"));
}
UnificationModel[] toUnificationModels(string[] models) {
  return models.map!toUnificationModel.array;
}
string toString(UnificationModel model) {
  return model.to!string;
}
string[] toStrings(UnificationModel[] models) {
  return models.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("UnificationModel"));

  assert("DETERMINISTIC".toUnificationModel == UnificationModel.deterministic);
  assert("PROBABILISTIC".toUnificationModel == UnificationModel.probabilistic);

  assert("".toUnificationModel == UnificationModel.deterministic);
  assert("unknown".toUnificationModel == UnificationModel.deterministic);

  assert(UnificationModel.deterministic.toString == "DETERMINISTIC");
  assert(UnificationModel.probabilistic.toString == "PROBABILISTIC");

  assert([UnificationModel.deterministic, UnificationModel.probabilistic].toStrings == ["DETERMINISTIC", "PROBABILISTIC"]);
  assert(["DETERMINISTIC", "PROBABILISTIC"].toUnificationModels == [UnificationModel.deterministic, UnificationModel.probabilistic]);
}

/// Status of a data product or data product provider
enum DataProductStatus : string {
  active   = "ACTIVE",
  inactive = "INACTIVE",
  pending  = "PENDING",
  error_   = "ERROR"
}
DataProductStatus toDataProductStatus(string status) {
  mixin(EnumSwitch("DataProductStatus", "active"));
}
DataProductStatus[] toDataProductStatuses(string[] statuses) {
  return statuses.map!toDataProductStatus.array;
}
string toString(DataProductStatus status) {
  return status.to!string;
}
string[] toStrings(DataProductStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("DataProductStatus"));

  assert("ACTIVE".toDataProductStatus == DataProductStatus.active);
  assert("INACTIVE".toDataProductStatus == DataProductStatus.inactive);
  assert("PENDING".toDataProductStatus == DataProductStatus.pending);
  assert("ERROR".toDataProductStatus == DataProductStatus.error_);

  assert("".toDataProductStatus == DataProductStatus.active);
  assert("unknown".toDataProductStatus == DataProductStatus.active);

  assert(DataProductStatus.active.toString == "ACTIVE");
  assert(DataProductStatus.inactive.toString == "INACTIVE");
  assert(DataProductStatus.pending.toString == "PENDING");
  assert(DataProductStatus.error_.toString == "ERROR");

  assert([DataProductStatus.active, DataProductStatus.inactive, DataProductStatus.pending, DataProductStatus.error_].toStrings
    == ["ACTIVE", "INACTIVE", "PENDING", "ERROR"]);
  assert(["ACTIVE", "INACTIVE", "PENDING", "ERROR"].toDataProductStatuses
    == [DataProductStatus.active, DataProductStatus.inactive, DataProductStatus.pending, DataProductStatus.error_]);
}

/// Status of a data provider
enum DataProviderStatus : string {
  active   = "ACTIVE",
  inactive = "INACTIVE",
  pending  = "PENDING"
}
DataProviderStatus toDataProviderStatus(string status) {
  mixin(EnumSwitch("DataProviderStatus", "active"));
}
DataProviderStatus[] toDataProviderStatuses(string[] statuses) {
  return statuses.map!toDataProviderStatus.array;
}
string toString(DataProviderStatus status) {
  return status.to!string;
}
string[] toStrings(DataProviderStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("DataProviderStatus"));

  assert("ACTIVE".toDataProviderStatus == DataProviderStatus.active);
  assert("INACTIVE".toDataProviderStatus == DataProviderStatus.inactive);
  assert("PENDING".toDataProviderStatus == DataProviderStatus.pending);

  assert("".toDataProviderStatus == DataProviderStatus.active);
  assert("unknown".toDataProviderStatus == DataProviderStatus.active);

  assert(DataProviderStatus.active.toString == "ACTIVE");
  assert(DataProviderStatus.inactive.toString == "INACTIVE");
  assert(DataProviderStatus.pending.toString == "PENDING");

  assert([DataProviderStatus.active, DataProviderStatus.inactive, DataProviderStatus.pending].toStrings
    == ["ACTIVE", "INACTIVE", "PENDING"]);
  assert(["ACTIVE", "INACTIVE", "PENDING"].toDataProviderStatuses
    == [DataProviderStatus.active, DataProviderStatus.inactive, DataProviderStatus.pending]);
}

/// Status of a composition run
enum CompositionRunStatus : string {
  pending   = "PENDING",
  running   = "RUNNING",
  completed = "COMPLETED",
  failed    = "FAILED",
  cancelled = "CANCELLED"
}
CompositionRunStatus toCompositionRunStatus(string status) {
  mixin(EnumSwitch("CompositionRunStatus", "pending"));
}
CompositionRunStatus[] toCompositionRunStatuses(string[] statuses) {
  return statuses.map!toCompositionRunStatus.array;
}
string toString(CompositionRunStatus status) {
  return status.to!string;
}
string[] toStrings(CompositionRunStatus[] statuses) {
  return statuses.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("CompositionRunStatus"));

  assert("PENDING".toCompositionRunStatus == CompositionRunStatus.pending);
  assert("RUNNING".toCompositionRunStatus == CompositionRunStatus.running);
  assert("COMPLETED".toCompositionRunStatus == CompositionRunStatus.completed);
  assert("FAILED".toCompositionRunStatus == CompositionRunStatus.failed);
  assert("CANCELLED".toCompositionRunStatus == CompositionRunStatus.cancelled);

  assert("".toCompositionRunStatus == CompositionRunStatus.pending);
  assert("unknown".toCompositionRunStatus == CompositionRunStatus.pending);

  assert(CompositionRunStatus.pending.toString == "PENDING");
  assert(CompositionRunStatus.running.toString == "RUNNING");
  assert(CompositionRunStatus.completed.toString == "COMPLETED");
  assert(CompositionRunStatus.failed.toString == "FAILED");
  assert(CompositionRunStatus.cancelled.toString == "CANCELLED");

  assert([CompositionRunStatus.pending, CompositionRunStatus.running, CompositionRunStatus.completed,
    CompositionRunStatus.failed, CompositionRunStatus.cancelled].toStrings
    == ["PENDING", "RUNNING", "COMPLETED", "FAILED", "CANCELLED"]);
  assert(["PENDING", "RUNNING", "COMPLETED", "FAILED", "CANCELLED"].toCompositionRunStatuses
    == [CompositionRunStatus.pending, CompositionRunStatus.running, CompositionRunStatus.completed,
      CompositionRunStatus.failed, CompositionRunStatus.cancelled]);
}

/// Transformation type for attribute mappings
enum TransformationType : string {
  none      = "NONE",
  toString_ = "TO_STRING",
  toNumber  = "TO_NUMBER",
  toDate    = "TO_DATE",
  trim      = "TRIM",
  upper     = "UPPER",
  lower     = "LOWER",
  append    = "APPEND",
  custom    = "CUSTOM"
}
TransformationType toTransformationType(string type) {
  mixin(EnumSwitch("TransformationType", "none"));
}
TransformationType[] toTransformationTypes(string[] types) {
  return types.map!toTransformationType.array;
}
string toString(TransformationType type) {
  return type.to!string;
}
string[] toStrings(TransformationType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("TransformationType"));

  assert("NONE".toTransformationType == TransformationType.none);
  assert("TO_STRING".toTransformationType == TransformationType.toString_);
  assert("TO_NUMBER".toTransformationType == TransformationType.toNumber);
  assert("TO_DATE".toTransformationType == TransformationType.toDate);
  assert("TRIM".toTransformationType == TransformationType.trim);
  assert("UPPER".toTransformationType == TransformationType.upper);
  assert("LOWER".toTransformationType == TransformationType.lower);
  assert("APPEND".toTransformationType == TransformationType.append);
  assert("CUSTOM".toTransformationType == TransformationType.custom); 

  assert("".toTransformationType == TransformationType.none);
  assert("unknown".toTransformationType == TransformationType.none);

  assert(TransformationType.none.toString == "NONE");
  assert(TransformationType.toString_.toString == "TO_STRING");
  assert(TransformationType.toNumber.toString == "TO_NUMBER");
  assert(TransformationType.toDate.toString == "TO_DATE");
  assert(TransformationType.trim.toString == "TRIM");
  assert(TransformationType.upper.toString == "UPPER");
  assert(TransformationType.lower.toString == "LOWER");
  assert(TransformationType.append.toString == "APPEND");
  assert(TransformationType.custom.toString == "CUSTOM");

  assert([TransformationType.none, TransformationType.toString_, TransformationType.toNumber,
    TransformationType.toDate, TransformationType.trim, TransformationType.upper, TransformationType.lower,
    TransformationType.append, TransformationType.custom].toStrings
    == ["NONE", "TO_STRING", "TO_NUMBER", "TO_DATE", "TRIM", "UPPER", "LOWER", "APPEND", "CUSTOM"]);
  assert(["NONE", "TO_STRING", "TO_NUMBER", "TO_DATE", "TRIM", "UPPER", "LOWER", "APPEND", "CUSTOM"].toTransformationTypes
    == [TransformationType.none, TransformationType.toString_, TransformationType.toNumber,
      TransformationType.toDate, TransformationType.trim, TransformationType.upper, TransformationType.lower,
      TransformationType.append, TransformationType.custom]);
}

/// Timestamp ingestion format
enum TimestampFormat : string {
  iso           = "ISO",
  unix_sec      = "UNIX_SEC",
  unix_milli    = "UNIX_MILLI",
  microsoft_json = "MICROSOFT_JSON",
  custom        = "CUSTOM"
}
TimestampFormat toTimestampFormat(string format) {
  mixin(EnumSwitch("TimestampFormat", "iso"));
}
TimestampFormat[] toTimestampFormats(string[] formats) {
  return formats.map!toTimestampFormat.array;
}
string toString(TimestampFormat format) {
  return format.to!string;
}
string[] toStrings(TimestampFormat[] formats) {
  return formats.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("TimestampFormat"));

  assert("ISO".toTimestampFormat == TimestampFormat.iso);
  assert("UNIX_SEC".toTimestampFormat == TimestampFormat.unix_sec);
  assert("UNIX_MILLI".toTimestampFormat == TimestampFormat.unix_milli);
  assert("MICROSOFT_JSON".toTimestampFormat == TimestampFormat.microsoft_json);
  assert("CUSTOM".toTimestampFormat == TimestampFormat.custom);

  assert("".toTimestampFormat == TimestampFormat.iso);
  assert("unknown".toTimestampFormat == TimestampFormat.iso);

  assert(TimestampFormat.iso.toString == "ISO");
  assert(TimestampFormat.unix_sec.toString == "UNIX_SEC");
  assert(TimestampFormat.unix_milli.toString == "UNIX_MILLI");
  assert(TimestampFormat.microsoft_json.toString == "MICROSOFT_JSON");
  assert(TimestampFormat.custom.toString == "CUSTOM");

  assert([TimestampFormat.iso, TimestampFormat.unix_sec, TimestampFormat.unix_milli,
    TimestampFormat.microsoft_json, TimestampFormat.custom].toStrings
    == ["ISO", "UNIX_SEC", "UNIX_MILLI", "MICROSOFT_JSON", "CUSTOM"]);
  assert(["ISO", "UNIX_SEC", "UNIX_MILLI", "MICROSOFT_JSON", "CUSTOM"].toTimestampFormats
    == [TimestampFormat.iso, TimestampFormat.unix_sec, TimestampFormat.unix_milli,
      TimestampFormat.microsoft_json, TimestampFormat.custom]);
}

/// Data quality rank (confidence level of incoming data)
enum DataQualityRank : string {
  critical = "CRITICAL",
  high     = "HIGH",
  medium   = "MEDIUM",
  low      = "LOW",
  minimal  = "MINIMAL"
}
DataQualityRank toDataQualityRank(string rank) {
  mixin(EnumSwitch("DataQualityRank", "critical"));
}
DataQualityRank[] toDataQualityRanks(string[] ranks) {
  return ranks.map!toDataQualityRank.array;
}
string toString(DataQualityRank rank) {
  return rank.to!string;
}
string[] toStrings(DataQualityRank[] ranks) {
  return ranks.map!toString.array;
} 
/// 
unittest {
  mixin(ShowTest!("DataQualityRank"));

  assert("CRITICAL".toDataQualityRank == DataQualityRank.critical);
  assert("HIGH".toDataQualityRank == DataQualityRank.high);
  assert("MEDIUM".toDataQualityRank == DataQualityRank.medium);
  assert("LOW".toDataQualityRank == DataQualityRank.low);
  assert("MINIMAL".toDataQualityRank == DataQualityRank.minimal);

  assert("".toDataQualityRank == DataQualityRank.critical);
  assert("unknown".toDataQualityRank == DataQualityRank.critical);

  assert(DataQualityRank.critical.toString == "CRITICAL");
  assert(DataQualityRank.high.toString == "HIGH");
  assert(DataQualityRank.medium.toString == "MEDIUM");
  assert(DataQualityRank.low.toString == "LOW");
  assert(DataQualityRank.minimal.toString == "MINIMAL");

  assert([DataQualityRank.critical, DataQualityRank.high, DataQualityRank.medium,
    DataQualityRank.low, DataQualityRank.minimal].toStrings
    == ["CRITICAL", "HIGH", "MEDIUM", "LOW", "MINIMAL"]);
  assert(["CRITICAL", "HIGH", "MEDIUM", "LOW", "MINIMAL"].toDataQualityRanks
    == [DataQualityRank.critical, DataQualityRank.high, DataQualityRank.medium,
      DataQualityRank.low, DataQualityRank.minimal]);
}

/// Role of a tenant user
enum TenantUserRole : string {
  admin  = "ADMIN",
  editor = "EDITOR",
  viewer = "VIEWER"
}
TenantUserRole toTenantUserRole(string role) {
  mixin(EnumSwitch("TenantUserRole", "viewer"));
}
TenantUserRole[] toTenantUserRoles(string[] roles) {
  return roles.map!toTenantUserRole.array;
}
string toString(TenantUserRole role) {
  return role.to!string;
}
string[] toStrings(TenantUserRole[] roles) {
  return roles.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("TenantUserRole"));

  assert("ADMIN".toTenantUserRole == TenantUserRole.admin);
  assert("EDITOR".toTenantUserRole == TenantUserRole.editor);
  assert("VIEWER".toTenantUserRole == TenantUserRole.viewer);

  assert("".toTenantUserRole == TenantUserRole.viewer);
  assert("unknown".toTenantUserRole == TenantUserRole.viewer);

  assert(TenantUserRole.admin.toString == "ADMIN");
  assert(TenantUserRole.editor.toString == "EDITOR");
  assert(TenantUserRole.viewer.toString == "VIEWER");

  assert([TenantUserRole.admin, TenantUserRole.editor, TenantUserRole.viewer].toStrings
    == ["ADMIN", "EDITOR", "VIEWER"]);
  assert(["ADMIN", "EDITOR", "VIEWER"].toTenantUserRoles
    == [TenantUserRole.admin, TenantUserRole.editor, TenantUserRole.viewer]);
}

/// Attribute data type in a schema
enum AttributeDataType : string {
  string_  = "STRING",
  number   = "NUMBER",
  integer  = "INTEGER",
  boolean_ = "BOOLEAN",
  date     = "DATE",
  datetime = "DATETIME",
  object_  = "OBJECT",
  array_   = "ARRAY"
}
AttributeDataType toAttributeDataType(string type) {
  mixin(EnumSwitch("AttributeDataType", "string_"));
}
AttributeDataType[] toAttributeDataTypes(string[] types) {
  return types.map!toAttributeDataType.array;
}
string toString(AttributeDataType type) {
  return type.to!string;
}   
string[] toStrings(AttributeDataType[] types) {
  return types.map!toString.array;
}
/// 
unittest {
  mixin(ShowTest!("AttributeDataType"));

  assert("STRING".toAttributeDataType == AttributeDataType.string_);
  assert("NUMBER".toAttributeDataType == AttributeDataType.number);
  assert("INTEGER".toAttributeDataType == AttributeDataType.integer);
  assert("BOOLEAN".toAttributeDataType == AttributeDataType.boolean_);
  assert("DATE".toAttributeDataType == AttributeDataType.date);
  assert("DATETIME".toAttributeDataType == AttributeDataType.datetime);
  assert("OBJECT".toAttributeDataType == AttributeDataType.object_);
  assert("ARRAY".toAttributeDataType == AttributeDataType.array_);

  assert("".toAttributeDataType == AttributeDataType.string_);
  assert("unknown".toAttributeDataType == AttributeDataType.string_);

  assert(AttributeDataType.string_.toString == "STRING");
  assert(AttributeDataType.number.toString == "NUMBER");
  assert(AttributeDataType.integer.toString == "INTEGER");
  assert(AttributeDataType.boolean_.toString == "BOOLEAN");
  assert(AttributeDataType.date.toString == "DATE");
  assert(AttributeDataType.datetime.toString == "DATETIME");
  assert(AttributeDataType.object_.toString == "OBJECT");
  assert(AttributeDataType.array_.toString == "ARRAY");

  assert([AttributeDataType.string_, AttributeDataType.number, AttributeDataType.integer,
    AttributeDataType.boolean_, AttributeDataType.date, AttributeDataType.datetime,
    AttributeDataType.object_, AttributeDataType.array_].toStrings
    == ["STRING", "NUMBER", "INTEGER", "BOOLEAN", "DATE", "DATETIME", "OBJECT", "ARRAY"]);
  assert(["STRING", "NUMBER", "INTEGER", "BOOLEAN", "DATE", "DATETIME", "OBJECT", "ARRAY"].toAttributeDataTypes
    == [AttributeDataType.string_, AttributeDataType.number, AttributeDataType.integer,
      AttributeDataType.boolean_, AttributeDataType.date, AttributeDataType.datetime,
      AttributeDataType.object_, AttributeDataType.array_]);
}

/// Output data product publication status
enum OutputProductStatus : string {
  disabled = "DISABLED",
  enabling = "ENABLING",
  enabled  = "ENABLED",
  error_   = "ERROR"
}
OutputProductStatus toOutputProductStatus(string status) {
  mixin(EnumSwitch("OutputProductStatus", "disabled"));
}
OutputProductStatus[] toOutputProductStatuses(string[] statuses) {
  return statuses.map!toOutputProductStatus.array;
}
string toString(OutputProductStatus status) {
  return status.to!string;
}
string[] toStrings(OutputProductStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("OutputProductStatus"));

  assert("DISABLED".toOutputProductStatus == OutputProductStatus.disabled);
  assert("ENABLING".toOutputProductStatus == OutputProductStatus.enabling);
  assert("ENABLED".toOutputProductStatus == OutputProductStatus.enabled);
  assert("ERROR".toOutputProductStatus == OutputProductStatus.error_);

  assert("".toOutputProductStatus == OutputProductStatus.disabled);
  assert("unknown".toOutputProductStatus == OutputProductStatus.disabled);

  assert(OutputProductStatus.disabled.toString == "DISABLED");
  assert(OutputProductStatus.enabling.toString == "ENABLING");
  assert(OutputProductStatus.enabled.toString == "ENABLED");
  assert(OutputProductStatus.error_.toString == "ERROR");

  assert([OutputProductStatus.disabled, OutputProductStatus.enabling, OutputProductStatus.enabled,
    OutputProductStatus.error_].toStrings
    == ["DISABLED", "ENABLING", "ENABLED", "ERROR"]);
  assert(["DISABLED", "ENABLING", "ENABLED", "ERROR"].toOutputProductStatuses
    == [OutputProductStatus.disabled, OutputProductStatus.enabling, OutputProductStatus.enabled,
      OutputProductStatus.error_]);
}
