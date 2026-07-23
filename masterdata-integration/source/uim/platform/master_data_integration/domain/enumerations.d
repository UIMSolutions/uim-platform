/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.enumerations;

import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:

/// Category of master data object.
enum MasterDataCategory {
  businessPartner,
  costCenter,
  profitCenter,
  companyCode,
  workforcePerson,
  bankAccount,
  plant,
  purchasingOrganization,
  salesOrganization,
  customerMaterial,
  supplierMaterial,
  custom,
}

MasterDataCategory toMasterDataCategory(string value) {
  mixin(EnumSwitch("MasterDataCategory", "custom"));
}

MasterDataCategory[] toMasterDataCategories(string[] cats)
  => cats.map!toMasterDataCategory.array;

string toString(MasterDataCategory cat)
  => cat.to!string;

string[] toStrings(MasterDataCategory[] cats)
  => cats.map!toString.array;

///
unittest {
  mixin(ShowTest!("MasterDataCategory"));

  assert("businessPartner".toMasterDataCategory == MasterDataCategory.businessPartner);
  assert("costCenter".toMasterDataCategory == MasterDataCategory.costCenter);
  assert("profitCenter".toMasterDataCategory == MasterDataCategory.profitCenter);
  assert("companyCode".toMasterDataCategory == MasterDataCategory.companyCode);
  assert("workforcePerson".toMasterDataCategory == MasterDataCategory.workforcePerson);
  assert("bankAccount".toMasterDataCategory == MasterDataCategory.bankAccount);
  assert("plant".toMasterDataCategory == MasterDataCategory.plant);
  assert("purchasingOrganization".toMasterDataCategory == MasterDataCategory.purchasingOrganization);
  assert("salesOrganization".toMasterDataCategory == MasterDataCategory.salesOrganization);
  assert("customerMaterial".toMasterDataCategory == MasterDataCategory.customerMaterial);
  assert("supplierMaterial".toMasterDataCategory == MasterDataCategory.supplierMaterial);
  assert("custom".toMasterDataCategory == MasterDataCategory.custom);

  assert(["businessPartner", "plant"].toMasterDataCategories == [
      MasterDataCategory.businessPartner, MasterDataCategory.plant
    ]);
}

/// Status of a master data record.
enum RecordStatus {
  active,
  inactive,
  blocked,
  markedForDeletion,
}

RecordStatus toRecordStatus(string value) {
  mixin(EnumSwitch("RecordStatus", "active"));
}

RecordStatus[] toRecordStatuses(string[] values)
  => values.map!toRecordStatus.array;

string toString(RecordStatus value)
  => value.to!string;

string[] toStrings(RecordStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("RecordStatus"));

  assert("active".toRecordStatus == RecordStatus.active);
  assert("inactive".toRecordStatus == RecordStatus.inactive);
  assert("blocked".toRecordStatus == RecordStatus.blocked);
  assert("markedForDeletion".toRecordStatus == RecordStatus.markedForDeletion);

  assert(["active", "blocked"].toRecordStatuses == [
      RecordStatus.active, RecordStatus.blocked
    ]);
  assert([RecordStatus.active, RecordStatus.blocked].toStrings == [
      "active", "blocked"
    ]);
}

/// Type of change in a change log.
enum ChangeType {
  create_,
  update_,
  delete_,
  merge,
  activate,
  deactivate,
}

ChangeType toChangeType(string s) {
  switch (s.toLower) {
  case "create":
    return ChangeType.create_;
  case "update":
    return ChangeType.update_;
  case "delete":
    return ChangeType.delete_;
  case "merge":
    return ChangeType.merge;
  case "activate":
    return ChangeType.activate;
  case "deactivate":
    return ChangeType.deactivate;
  default:
    return ChangeType.update_; // Default case
  }
}

ChangeType[] toChangeTypes(string[] values)
  => values.map!toChangeType.array;

string toString(ChangeType value)
  => value.to!string;

string[] toStrings(ChangeType[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("ChangeType"));

  assert("create".toChangeType == ChangeType.create_);
  assert("update".toChangeType == ChangeType.update_);
  assert("delete".toChangeType == ChangeType.delete_);
  assert("merge".toChangeType == ChangeType.merge);
  assert("activate".toChangeType == ChangeType.activate);
  assert("deactivate".toChangeType == ChangeType.deactivate);

  assert(["create", "delete"].toChangeTypes == [
      ChangeType.create_, ChangeType.delete_
    ]);
  assert([ChangeType.create_, ChangeType.delete_].toStrings == [
      "create_", "delete_"
    ]);
}

/// Status of a distribution model.
enum DistributionModelStatus {
  active,
  inactive,
  draft,
}

DistributionModelStatus toDistributionModelStatus(string value) {
  mixin(EnumSwitch("DistributionModelStatus", "draft"));
}

DistributionModelStatus[] toDistributionModelStatuses(string[] values)
  => values.map!toDistributionModelStatus.array;

string toString(DistributionModelStatus value)
  => value.to!string;

string[] toStrings(DistributionModelStatus[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("DistributionModelStatus"));

  assert("active".toDistributionModelStatus == DistributionModelStatus.active);
  assert("inactive".toDistributionModelStatus == DistributionModelStatus.inactive);
  assert("draft".toDistributionModelStatus == DistributionModelStatus.draft);

  assert(["active", "draft"].toDistributionModelStatuses == [
      DistributionModelStatus.active, DistributionModelStatus.draft
    ]);
  assert([DistributionModelStatus.active, DistributionModelStatus.draft].toStrings == [
      "active", "draft"
    ]);
}

/// Direction of data flow in distribution.
enum DistributionDirection {
  outbound,
  inbound,
  bidirectional,
}

DistributionDirection toDistributionDirection(string s) {
  mixin(EnumSwitch("DistributionDirection", "outbound"));
}

DistributionDirection[] toDistributionDirections(string[] values)
  => values.map!toDistributionDirection.array;

string toString(DistributionDirection value)
  => value.to!string;

string[] toStrings(DistributionDirection[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("DistributionDirection"));

  assert("outbound".toDistributionDirection == DistributionDirection.outbound);
  assert("inbound".toDistributionDirection == DistributionDirection.inbound);
  assert("bidirectional".toDistributionDirection == DistributionDirection.bidirectional);

  assert(["outbound", "inbound"].toDistributionDirections == [
      DistributionDirection.outbound, DistributionDirection.inbound
    ]);
  assert([DistributionDirection.outbound, DistributionDirection.inbound].toStrings == [
      "outbound", "inbound"
    ]);
}

/// Status of a connected client system.
enum ClientStatus {
  connected,
  disconnected,
  error,
  suspended,
}

ClientStatus toClientStatus(string s) {
  mixin(EnumSwitch("ClientStatus", "disconnected"));
}

ClientStatus[] toClientStatuses(string[] values)
  => values.map!toClientStatus.array;

string toString(ClientStatus value)
  => value.to!string;

string[] toStrings(ClientStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("ClientStatus"));

  assert("connected".toClientStatus == ClientStatus.connected);
  assert("disconnected".toClientStatus == ClientStatus.disconnected);
  assert("error".toClientStatus == ClientStatus.error);
  assert("suspended".toClientStatus == ClientStatus.suspended);

  assert(["connected", "error"].toClientStatuses == [
      ClientStatus.connected, ClientStatus.error
    ]);
  assert([ClientStatus.connected, ClientStatus.error].toStrings == [
      "connected", "error"
    ]);
}

/// Type of the connected client.
enum ClientType {
  sapS4Hana,
  sapSuccessFactors,
  sapAriba,
  sapFieldglass,
  sapConcur,
  sapBusinessByDesign,
  thirdParty,
  custom,
}

ClientType toClientType(string s) {
  mixin(EnumSwitch("ClientType", "custom"));
}

ClientType[] toClientTypes(string[] values)
  => values.map!toClientType.array;

string toString(ClientType value)
  => value.to!string;

string[] toStrings(ClientType[] values) 
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("ClientType"));

  assert("sapS4Hana".toClientType == ClientType.sapS4Hana);
  assert("sapSuccessFactors".toClientType == ClientType.sapSuccessFactors);
  assert("sapAriba".toClientType == ClientType.sapAriba);
  assert("sapFieldglass".toClientType == ClientType.sapFieldglass);
  assert("sapConcur".toClientType == ClientType.sapConcur);
  assert("sapBusinessByDesign".toClientType == ClientType.sapBusinessByDesign);
  assert("thirdParty".toClientType == ClientType.thirdParty);
  assert("custom".toClientType == ClientType.custom);

  assert(["sapS4Hana", "thirdParty"].toClientTypes == [
      ClientType.sapS4Hana, ClientType.thirdParty
    ]);
  assert([ClientType.sapS4Hana, ClientType.thirdParty].toStrings == [
      "sapS4Hana", "thirdParty"
    ]);
}

/// Status of a replication job.
enum ReplicationJobStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
  paused,
}

ReplicationJobStatus toReplicationJobStatus(string value) {
  mixin(EnumSwitch("ReplicationJobStatus", "pending"));
}

ReplicationJobStatus[] toReplicationJobStatuses(string[] values)
  => values.map!toReplicationJobStatus.array;

  string toString(ReplicationJobStatus value)
  => value.to!string;

string[] toStrings(ReplicationJobStatus[] values)
  => values.map!toString.array;

unittest {
  mixin(ShowTest!("ReplicationJobStatus"));

  assert("pending".toReplicationJobStatus == ReplicationJobStatus.pending);
  assert("running".toReplicationJobStatus == ReplicationJobStatus.running);
  assert("completed".toReplicationJobStatus == ReplicationJobStatus.completed);
  assert("failed".toReplicationJobStatus == ReplicationJobStatus.failed);
  assert("cancelled".toReplicationJobStatus == ReplicationJobStatus.cancelled);
  assert("paused".toReplicationJobStatus == ReplicationJobStatus.paused);

  assert(["pending", "failed"].toReplicationJobStatuses == [
      ReplicationJobStatus.pending, ReplicationJobStatus.failed
    ]);
  assert([ReplicationJobStatus.pending, ReplicationJobStatus.failed].toStrings == [
      "pending", "failed"
    ]);
}

/// Trigger mode for replication.
enum ReplicationTrigger {
  manual,
  scheduled,
  eventDriven,
  onChange,
}

ReplicationTrigger toReplicationTrigger(string s) {
  mixin(EnumSwitch("ReplicationTrigger", "manual"));
}

ReplicationTrigger[] toReplicationTriggers(string[] values)
  => values.map!toReplicationTrigger.array;

string toString(ReplicationTrigger value)
  => value.to!string;

string[] toStrings(ReplicationTrigger[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("ReplicationTrigger"));

  assert("manual".toReplicationTrigger == ReplicationTrigger.manual);
  assert("scheduled".toReplicationTrigger == ReplicationTrigger.scheduled);
  assert("eventDriven".toReplicationTrigger == ReplicationTrigger.eventDriven);
  assert("onChange".toReplicationTrigger == ReplicationTrigger.onChange);

  assert(["manual", "eventDriven"].toReplicationTriggers == [
      ReplicationTrigger.manual, ReplicationTrigger.eventDriven
    ]);
  assert([ReplicationTrigger.manual, ReplicationTrigger.eventDriven].toStrings == [
      "manual", "eventDriven"
    ]);
}

/// Filter operator for filtering rules.
enum FilterOperator {
  equals,
  notEquals,
  contains,
  startsWith,
  endsWith,
  greaterThan,
  lessThan,
  inList,
  notInList,
  between,
  isNull,
  isNotNull,
}

FilterOperator toFilterOperator(string value) {
  mixin(EnumSwitch("FilterOperator", "equals"));
}

FilterOperator[] toFilterOperators(string[] values)
  => values.map!toFilterOperator.array;

string toString(FilterOperator value)
  => value.to!string;

string[] toStrings(FilterOperator[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("FilterOperator"));

  assert("equals".toFilterOperator == FilterOperator.equals);
  assert("notEquals".toFilterOperator == FilterOperator.notEquals);
  assert("contains".toFilterOperator == FilterOperator.contains);
  assert("startsWith".toFilterOperator == FilterOperator.startsWith);
  assert("endsWith".toFilterOperator == FilterOperator.endsWith);
  assert("greaterThan".toFilterOperator == FilterOperator.greaterThan);
  assert("lessThan".toFilterOperator == FilterOperator.lessThan);
  assert("inList".toFilterOperator == FilterOperator.inList);
  assert("notInList".toFilterOperator == FilterOperator.notInList);
  assert("between".toFilterOperator == FilterOperator.between);
  assert("isNull".toFilterOperator == FilterOperator.isNull);
  assert("isNotNull".toFilterOperator == FilterOperator.isNotNull);

  assert(["equals", "contains"].toFilterOperators == [
      FilterOperator.equals, FilterOperator.contains
    ]);
  assert([FilterOperator.equals, FilterOperator.contains].toStrings == [
      "equals", "contains"
    ]);
}

/// Data model field type.
enum FieldType : string {
  string_ = "string",
  integer_ = "integer",
  decimal_ = "decimal",
  boolean_ = "boolean",
  date = "date",
  timestamp = "timestamp",
  reference = "reference",
  array_ = "array",
  object_ = "object",
}

FieldType toFieldType(string s) {
  switch (s.toLower) {
  case "string":
    return FieldType.string_;
  case "integer":
    return FieldType.integer_;
  case "decimal": 
    return FieldType.decimal_;
  case "boolean":
    return FieldType.boolean_;
  case "date":
    return FieldType.date;
  case "timestamp":
    return FieldType.timestamp;
  case "reference":
    return FieldType.reference; 
  case "array":
    return FieldType.array_;
  case "object":
    return FieldType.object_;
  default:
    return FieldType.string_; // Default case
  }
}

FieldType[] toFieldTypes(string[] values)
  => values.map!toFieldType.array;

string toString(FieldType value)
  => value.to!string;

string[] toStrings(FieldType[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("FieldType"));

  assert("string".toFieldType == FieldType.string_);
  assert("integer".toFieldType == FieldType.integer_);
  assert("decimal".toFieldType == FieldType.decimal_);
  assert("boolean".toFieldType == FieldType.boolean_);
  assert("date".toFieldType == FieldType.date);
  assert("timestamp".toFieldType == FieldType.timestamp);
  assert("reference".toFieldType == FieldType.reference);
  assert("array".toFieldType == FieldType.array_);
  assert("object".toFieldType == FieldType.object_);

  assert(["string", "date"].toFieldTypes == [
      FieldType.string_, FieldType.date
    ]);
  assert([FieldType.string_, FieldType.date].toStrings == [
      "string_", "date"
    ]);
}

/// Key mapping source type.
enum KeyMappingSourceType {
  local,
  remote,
  universal,
}

KeyMappingSourceType toKeyMappingSourceType(string s) {
  mixin(EnumSwitch("KeyMappingSourceType", "local"));
}

KeyMappingSourceType[] toKeyMappingSourceTypes(string[] values)
  => values.map!toKeyMappingSourceType.array;

string toString(KeyMappingSourceType value)
  => value.to!string;

string[] toStrings(KeyMappingSourceType[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("KeyMappingSourceType"));

  assert("local".toKeyMappingSourceType == KeyMappingSourceType.local);
  assert("remote".toKeyMappingSourceType == KeyMappingSourceType.remote);
  assert("universal".toKeyMappingSourceType == KeyMappingSourceType.universal);

  assert(["local", "remote"].toKeyMappingSourceTypes == [
      KeyMappingSourceType.local, KeyMappingSourceType.remote
    ]);
  assert([KeyMappingSourceType.local, KeyMappingSourceType.remote].toStrings == [
      "local", "remote"
    ]);
}
