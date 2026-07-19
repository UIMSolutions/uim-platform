/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.enumerations;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:

// Connection types
enum ConnectionType {
  hana,
  s4hana,
  bw,
  adp,
  hdl,
  odata,
  sql,
  file,
  kafka,
  abap,
  other,
}

ConnectionType toConnectionType(string value) {
  mixin(EnumSwitch("ConnectionType", "hana"));
}

ConnectionType[] toConnectionTypes(string[] values) {
  return values.map!(toConnectionType).array;
}

string toString(ConnectionType type) {
  return type.to!string;
}

string[] toStrings(ConnectionType[] types) {
  return types.map!(toString).array;
}
/// 
unittest {
  mixin(ShowTest!("ConnectionType"));

  assert(ConnectionType.hana.to!string == "hana");
  assert(ConnectionType.s4hana.to!string == "s4hana");
  assert(ConnectionType.bw.to!string == "bw");
  assert(ConnectionType.adp.to!string == "adp");
  assert(ConnectionType.hdl.to!string == "hdl");
  assert(ConnectionType.odata.to!string == "odata");
  assert(ConnectionType.sql.to!string == "sql");
  assert(ConnectionType.file.to!string == "file");
  assert(ConnectionType.kafka.to!string == "kafka");
  assert(ConnectionType.abap.to!string == "abap");
  assert(ConnectionType.other.to!string == "other");

  assert("hana".to!ConnectionType == ConnectionType.hana);
  assert("s4hana".to!ConnectionType == ConnectionType.s4hana);
  assert("bw".to!ConnectionType == ConnectionType.bw);
  assert("adp".to!ConnectionType == ConnectionType.adp);
  assert("hdl".to!ConnectionType == ConnectionType.hdl);
  assert("odata".to!ConnectionType == ConnectionType.odata);
  assert("sql".to!ConnectionType == ConnectionType.sql);
  assert("file".to!ConnectionType == ConnectionType.file);
  assert("kafka".to!ConnectionType == ConnectionType.kafka);
  assert("abap".to!ConnectionType == ConnectionType.abap);
  assert("other".to!ConnectionType == ConnectionType.other);

  assert("hana".toConnectionType == ConnectionType.hana);
  assert("s4hana".toConnectionType == ConnectionType.s4hana);
  assert("bw".toConnectionType == ConnectionType.bw);
  assert("adp".toConnectionType == ConnectionType.adp);
  assert("hdl".toConnectionType == ConnectionType.hdl);
  assert("odata".toConnectionType == ConnectionType.odata);
  assert("sql".toConnectionType == ConnectionType.sql);
  assert("file".toConnectionType == ConnectionType.file);
  assert("kafka".toConnectionType == ConnectionType.kafka);
  assert("abap".toConnectionType == ConnectionType.abap);
  assert("other".toConnectionType == ConnectionType.other);

  assert("noexists".toConnectionType == ConnectionType.hana); // Default case
  assert("".toConnectionType == ConnectionType.hana); // Default case

  assert(ConnectionType.hana.toString == "hana");
  assert(ConnectionType.s4hana.toString == "s4hana");
  assert(ConnectionType.bw.toString == "bw");
  assert(ConnectionType.adp.toString == "adp");
  assert(ConnectionType.hdl.toString == "hdl");
  assert(ConnectionType.odata.toString == "odata");
  assert(ConnectionType.sql.toString == "sql");
  assert(ConnectionType.file.toString == "file");
  assert(ConnectionType.kafka.toString == "kafka");
  assert(ConnectionType.abap.toString == "abap");
  assert(ConnectionType.other.toString == "other");

  assert([
    ConnectionType.hana, ConnectionType.s4hana, ConnectionType.bw,
    ConnectionType.adp, ConnectionType.hdl, ConnectionType.odata,
    ConnectionType.sql, ConnectionType.file, ConnectionType.kafka,
    ConnectionType.abap, ConnectionType.other
  ].toString ==
    [
      "hana", "s4hana", "bw", "adp", "hdl", "odata", "sql", "file", "kafka",
      "abap", "other"
    ]);
  assert([
    "hana", "s4hana", "bw", "adp", "hdl", "odata", "sql", "file", "kafka", "abap",
    "other"
  ].toConnectionTypes ==
    [
      ConnectionType.hana, ConnectionType.s4hana, ConnectionType.bw,
      ConnectionType.adp, ConnectionType.hdl, ConnectionType.odata,
      ConnectionType.sql, ConnectionType.file, ConnectionType.kafka,
      ConnectionType.abap, ConnectionType.other
    ]);
}

// Space storage allocation
enum StorageType {
  inMemory,
  disk,
}
StorageType toStorageType(string value) {
  mixin(EnumSwitch("StorageType", "inMemory"));
}
StorageType[] toStorageTypes(string[] values) {
  return values.map!(toStorageType).array;
}
string toString(StorageType type) {
  return type.to!string;
}
string[] toStrings(StorageType[] types) {
  return types.map!(toString).array;
}
/// 
unittest {
  mixin(ShowTest!("StorageType"));

  assert(StorageType.inMemory.to!string == "inMemory");
  assert(StorageType.disk.to!string == "disk");

  assert("inMemory".to!StorageType == StorageType.inMemory);
  assert("disk".to!StorageType == StorageType.disk);

  assert("inMemory".toStorageType == StorageType.inMemory);
  assert("disk".toStorageType == StorageType.disk);

  assert("noexists".toStorageType == StorageType.inMemory); // Default case
  assert("".toStorageType == StorageType.inMemory); // Default case

  assert(StorageType.inMemory.toString == "inMemory");
  assert(StorageType.disk.toString == "disk");

  assert(["inMemory", "disk"].toStorageTypes ==
         [StorageType.inMemory, StorageType.disk]);
  assert([StorageType.inMemory, StorageType.disk].toString ==
         ["inMemory", "disk"]);
}

// Data flow status
enum FlowStatus {
  active,
  inactive,
  running,
  completed,
  failed,
  pending,
}
FlowStatus toFlowStatus(string value) {
  mixin(EnumSwitch("FlowStatus", "active"));
}
FlowStatus[] toFlowStatuses(string[] values) {
  return values.map!(toFlowStatus).array;
}
string toString(FlowStatus status) {
  return status.to!string;
}
string[] toStrings(FlowStatus[] statuses) {
  return statuses.map!(toString).array;
} 
///
unittest {
  mixin(ShowTest!("FlowStatus"));

  assert(FlowStatus.active.to!string == "active");
  assert(FlowStatus.inactive.to!string == "inactive");
  assert(FlowStatus.running.to!string == "running");
  assert(FlowStatus.completed.to!string == "completed");
  assert(FlowStatus.failed.to!string == "failed");
  assert(FlowStatus.pending.to!string == "pending");

  assert("active".to!FlowStatus == FlowStatus.active);
  assert("inactive".to!FlowStatus == FlowStatus.inactive);
  assert("running".to!FlowStatus == FlowStatus.running);
  assert("completed".to!FlowStatus == FlowStatus.completed);
  assert("failed".to!FlowStatus == FlowStatus.failed);
  assert("pending".to!FlowStatus == FlowStatus.pending);

  assert("active".toFlowStatus == FlowStatus.active);
  assert("inactive".toFlowStatus == FlowStatus.inactive);
  assert("running".toFlowStatus == FlowStatus.running);
  assert("completed".toFlowStatus == FlowStatus.completed);
  assert("failed".toFlowStatus == FlowStatus.failed);
  assert("pending".toFlowStatus == FlowStatus.pending);

  assert("noexists".toFlowStatus == FlowStatus.active); // Default case
  assert("".toFlowStatus == FlowStatus.active); // Default case

  assert(FlowStatus.active.toString == "active");
  assert(FlowStatus.inactive.toString == "inactive");
  assert(FlowStatus.running.toString == "running");
  assert(FlowStatus.completed.toString == "completed");
  assert(FlowStatus.failed.toString == "failed");
  assert(FlowStatus.pending.toString == "pending");

  assert(["active", "inactive", "running", "completed", "failed", "pending"].toFlowStatuses ==
         [FlowStatus.active, FlowStatus.inactive, FlowStatus.running, FlowStatus.completed, FlowStatus.failed, FlowStatus.pending]);
  assert([FlowStatus.active, FlowStatus.inactive, FlowStatus.running, FlowStatus.completed, FlowStatus.failed, FlowStatus.pending].toString ==
         ["active", "inactive", "running", "completed", "failed", "pending"]);
}


// Remote table replication mode
enum ReplicationMode {
  none,
  realtime,
  scheduled,
  snapshot,
}
ReplicationMode toReplicationMode(string value) {
  mixin(EnumSwitch("ReplicationMode", "none"));
}
ReplicationMode[] toReplicationModes(string[] values) {
  return values.map!(toReplicationMode).array;
}
string toString(ReplicationMode mode) {
  return mode.to!string;
}
string[] toStrings(ReplicationMode[] modes) {
  return modes.map!(toString).array;
}
///
ReplicationMode toReplicationMode(string value) {
  mixin(EnumSwitch("ReplicationMode", "none"));
}
ReplicationMode[] toReplicationModes(string[] values) {
  return values.map!(toReplicationMode).array;
}
string toString(ReplicationMode mode) {
  return mode.to!string;
}
string[] toStrings(ReplicationMode[] modes) {
  return modes.map!(toString).array;
}
/// 
unittest {
  mixin(ShowTest!("ReplicationMode"));

  assert(ReplicationMode.none.to!string == "none");
  assert(ReplicationMode.realtime.to!string == "realtime");
  assert(ReplicationMode.scheduled.to!string == "scheduled");
  assert(ReplicationMode.snapshot.to!string == "snapshot");

  assert("none".to!ReplicationMode == ReplicationMode.none);
  assert("realtime".to!ReplicationMode == ReplicationMode.realtime);
  assert("scheduled".to!ReplicationMode == ReplicationMode.scheduled);
  assert("snapshot".to!ReplicationMode == ReplicationMode.snapshot);

  assert("none".toReplicationMode == ReplicationMode.none);
  assert("realtime".toReplicationMode == ReplicationMode.realtime);
  assert("scheduled".toReplicationMode == ReplicationMode.scheduled);
  assert("snapshot".toReplicationMode == ReplicationMode.snapshot);

  assert("noexists".toReplicationMode == ReplicationMode.none); // Default case
  assert("".toReplicationMode == ReplicationMode.none); // Default case

  assert(ReplicationMode.none.toString == "none");
  assert(ReplicationMode.realtime.toString == "realtime");
  assert(ReplicationMode.scheduled.toString == "scheduled");
  assert(ReplicationMode.snapshot.toString == "snapshot");

  assert(["none", "realtime", "scheduled", "snapshot"].toReplicationModes ==
         [ReplicationMode.none, ReplicationMode.realtime, ReplicationMode.scheduled, ReplicationMode.snapshot]);
  assert([ReplicationMode.none, ReplicationMode.realtime, ReplicationMode.scheduled, ReplicationMode.snapshot].toString ==
         ["none", "realtime", "scheduled", "snapshot"]);
}

// View semantic type
enum ViewSemantic {
  fact,
  dimension,
  text,
  hierarchy,
  analytical,
  relational,
}
// Task type
enum TaskType {
  dataFlow,
  replication,
  transform,
  deletion,
  persistence,
}
// DSTask execution status
enum TaskStatus {
  scheduled,
  running,
  completed,
  failed,
  cancelled,
  pending,
}
// Schedule frequency
enum ScheduleFrequency {
  once,
  hourly,
  daily,
  weekly,
  monthly,
  cron,
}
// Data access control criteria type
enum CriteriaType {
  singleValues,
  ranges,
  hierarchy,
  responsibility,
}
// Catalog asset type
enum AssetType {
  table,
  view,
  dataFlow,
  connection,
  remoteTable,
  localTable,
  other,
}
// Catalog asset quality status
enum QualityStatus {
  excellent,
  good,
  adequate,
  poor,
  unknown,
}
// Catalog asset sensitivity level
enum SensitivityLevel {
  public_,
  internal,
  confidential,
  restricted,
  custom,
}

// Data lineage relationship type
enum LineageRelationship {
  source,
  transformation,
  target,
  reference,
  other,
}

// Data retention policy type
enum RetentionPolicyType {
  timeBased,
  eventBased,
  legalHold,
  custom,
}

// Data retention action
enum RetentionAction {
  delete_,
  archive,
  anonymize,
  notify,
  custom,
}
