/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.domain.enumerations;

import uim.platform.master_data_integration;

// mixin(ShowModule!());

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
MasterDataCategory toMasterDataCategory(string s) {
  const map = [
    "businessPartner": MasterDataCategory.businessPartner,
    "costCenter": MasterDataCategory.costCenter,
    "profitCenter": MasterDataCategory.profitCenter,
    "companyCode": MasterDataCategory.companyCode,
    "workforcePerson": MasterDataCategory.workforcePerson,
    "bankAccount": MasterDataCategory.bankAccount,
    "plant": MasterDataCategory.plant,
    "purchasingOrganization": MasterDataCategory.purchasingOrganization,
    "salesOrganization": MasterDataCategory.salesOrganization,
    "customerMaterial": MasterDataCategory.customerMaterial,
    "supplierMaterial": MasterDataCategory.supplierMaterial,
    "custom": MasterDataCategory.custom,
  ];
  return map.get(s.toLower, MasterDataCategory.custom);
}

/// Status of a master data record.
enum RecordStatus {
  active,
  inactive,
  blocked,
  markedForDeletion,
}
RecordStatus toRecordStatus(string s) {
  const map = [
    "active": RecordStatus.active,
    "inactive": RecordStatus.inactive,
    "blocked": RecordStatus.blocked,
    "markedForDeletion": RecordStatus.markedForDeletion,
  ];
  return map.get(s.toLower, RecordStatus.active);
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
  const map = [
    "create": ChangeType.create_,
    "update": ChangeType.update_,
    "delete": ChangeType.delete_,
    "merge": ChangeType.merge,
    "activate": ChangeType.activate,
    "deactivate": ChangeType.deactivate,
  ];
  return map.get(s.toLower, ChangeType.create_);
}

/// Status of a distribution model.
enum DistributionModelStatus {
  active,
  inactive,
  draft,
}
DistributionModelStatus toDistributionModelStatus(string s) {
  const map = [
    "active": DistributionModelStatus.active,
    "inactive": DistributionModelStatus.inactive,
    "draft": DistributionModelStatus.draft,
  ];
  return map.get(s.toLower, DistributionModelStatus.draft);
}

/// Direction of data flow in distribution.
enum DistributionDirection {
  outbound,
  inbound,
  bidirectional,
}
DistributionDirection toDistributionDirection(string s) {
  const map = [
    "outbound": DistributionDirection.outbound,
    "inbound": DistributionDirection.inbound,
    "bidirectional": DistributionDirection.bidirectional,
  ];
  return map.get(s.toLower, DistributionDirection.outbound);
}

/// Status of a connected client system.
enum ClientStatus {
  connected,
  disconnected,
  error,
  suspended,
}
ClientStatus toClientStatus(string s) {
  const map = [
    "connected": ClientStatus.connected,
    "disconnected": ClientStatus.disconnected,
    "error": ClientStatus.error,
    "suspended": ClientStatus.suspended,
  ];
  return map.get(s.toLower, ClientStatus.disconnected);
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
  const map = [
    "sapS4Hana": ClientType.sapS4Hana,
    "sapSuccessFactors": ClientType.sapSuccessFactors,
    "sapAriba": ClientType.sapAriba,
    "sapFieldglass": ClientType.sapFieldglass,
    "sapConcur": ClientType.sapConcur,
    "sapBusinessByDesign": ClientType.sapBusinessByDesign,
    "thirdParty": ClientType.thirdParty,
    "custom": ClientType.custom,
  ];
  return map.get(s.toLower, ClientType.custom);
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
ReplicationJobStatus toReplicationJobStatus(string s) {
  const map = [
    "pending": ReplicationJobStatus.pending,
    "running": ReplicationJobStatus.running,
    "completed": ReplicationJobStatus.completed,
    "failed": ReplicationJobStatus.failed,
    "cancelled": ReplicationJobStatus.cancelled,
    "paused": ReplicationJobStatus.paused,
  ];
  return map.get(s.toLower, ReplicationJobStatus.pending);
}

/// Trigger mode for replication.
enum ReplicationTrigger {
  manual,
  scheduled,
  eventDriven,
  onChange,
}
ReplicationTrigger toReplicationTrigger(string s) {
  const map = [
    "manual": ReplicationTrigger.manual,
    "scheduled": ReplicationTrigger.scheduled,
    "eventDriven": ReplicationTrigger.eventDriven,
    "onChange": ReplicationTrigger.onChange,
  ];
  return map.get(s.toLower, ReplicationTrigger.manual);
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
FilterOperator toFilterOperator(string s) {
  const map = [
    "equals": FilterOperator.equals,
    "notEquals": FilterOperator.notEquals,
    "contains": FilterOperator.contains,
    "startsWith": FilterOperator.startsWith,
    "endsWith": FilterOperator.endsWith,
    "greaterThan": FilterOperator.greaterThan,
    "lessThan": FilterOperator.lessThan,
    "inList": FilterOperator.inList,
    "notInList": FilterOperator.notInList,
    "between": FilterOperator.between,
    "isNull": FilterOperator.isNull,
    "isNotNull": FilterOperator.isNotNull,
  ];
  return map.get(s.toLower, FilterOperator.equals);
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
  const map = [
    "string": FieldType.string_,
    "integer": FieldType.integer_,
    "decimal": FieldType.decimal_,
    "boolean": FieldType.boolean_,
    "date": FieldType.date,
    "timestamp": FieldType.timestamp,
    "reference": FieldType.reference,
    "array": FieldType.array_,
    "object": FieldType.object_,
  ];
  return map.get(s.toLower, FieldType.string_);
}

/// Key mapping source type.
enum KeyMappingSourceType {
  local,
  remote,
  universal,
}
KeyMappingSourceType toKeyMappingSourceType(string s) {
  const map = [
    "local": KeyMappingSourceType.local,
    "remote": KeyMappingSourceType.remote,
    "universal": KeyMappingSourceType.universal,
  ];
  return map.get(s.toLower, KeyMappingSourceType.local);
}