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

ConnectionType[] toConnectionType(string[] values) {
  return values.map!(toConnectionType).array;
}

string toString(ConnectionType type) {
  return type.to!string;
}

string[] toString(ConnectionType[] types) {
  return types.map!toString.array;
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
    ["hana", "s4hana", "bw", "adp", "hdl", "odata", "sql", "file", "kafka",
      "abap", "other"
    ]);
  assert([
    "hana", "s4hana", "bw", "adp", "hdl", "odata", "sql", "file", "kafka", "abap",
    "other"
  ].toConnectionType ==
    [ConnectionType.hana, ConnectionType.s4hana, ConnectionType.bw,
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
StorageType[] toStorageType(string[] values) {
  return values.map!(toStorageType).array;
}
string toString(StorageType type) {
  return type.to!string;
}
string[] toString(StorageType[] types) {
  return types.map!toString.array;
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

  assert(["inMemory", "disk"].toStorageType ==
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
FlowStatus[] toFlowStatus(string[] values)
  => values.map!toFlowStatus.array;

string toString(FlowStatus status)
  => status.to!string;

string[] toString(FlowStatus[] statuses)
  => statuses.map!toString.array;
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

  assert(["active", "inactive", "running", "completed", "failed", "pending"].toFlowStatus ==
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
ReplicationMode[] toReplicationMode(string[] values) {
  return values.map!(toReplicationMode).array;
}
string toString(ReplicationMode mode) {
  return mode.to!string;
}
string[] toString(ReplicationMode[] modes) {
  return modes.map!toString.array;
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

  assert(["none", "realtime", "scheduled", "snapshot"].toReplicationMode ==
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

ViewSemantic toViewSemantic(string value) {
  mixin(EnumSwitch("ViewSemantic", "fact"));
}
ViewSemantic[] toViewSemantic(string[] values)
  => values.map!(toViewSemantic).array;

string toString(ViewSemantic semantic)
  => semantic.to!string;

string[] toString(ViewSemantic[] semantics)
  => semantics.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("ViewSemantic"));

  assert(ViewSemantic.fact.to!string == "fact");
  assert(ViewSemantic.dimension.to!string == "dimension");
  assert(ViewSemantic.text.to!string == "text");
  assert(ViewSemantic.hierarchy.to!string == "hierarchy");
  assert(ViewSemantic.analytical.to!string == "analytical");
  assert(ViewSemantic.relational.to!string == "relational");

  assert("fact".to!ViewSemantic == ViewSemantic.fact);
  assert("dimension".to!ViewSemantic == ViewSemantic.dimension);
  assert("text".to!ViewSemantic == ViewSemantic.text);
  assert("hierarchy".to!ViewSemantic == ViewSemantic.hierarchy);
  assert("analytical".to!ViewSemantic == ViewSemantic.analytical);
  assert("relational".to!ViewSemantic == ViewSemantic.relational);

  assert("fact".toViewSemantic == ViewSemantic.fact);
  assert("dimension".toViewSemantic == ViewSemantic.dimension);
  assert("text".toViewSemantic == ViewSemantic.text);
  assert("hierarchy".toViewSemantic == ViewSemantic.hierarchy);
  assert("analytical".toViewSemantic == ViewSemantic.analytical);
  assert("relational".toViewSemantic == ViewSemantic.relational);

  assert("noexists".toViewSemantic == ViewSemantic.fact); // Default case
  assert("".toViewSemantic == ViewSemantic.fact); // Default case

  assert(ViewSemantic.fact.toString == "fact");
  assert(ViewSemantic.dimension.toString == "dimension");
  assert(ViewSemantic.text.toString == "text");
  assert(ViewSemantic.hierarchy.toString == "hierarchy");
  assert(ViewSemantic.analytical.toString == "analytical");
  assert(ViewSemantic.relational.toString == "relational");
}

// Task type
enum TaskType {
  dataFlow,
  replication,
  transform,
  deletion,
  persistence,
}

TaskType toTaskType(string value) {
  mixin(EnumSwitch("TaskType", "dataFlow"));
}
TaskType[] toTaskType(string[] values)
  => values.map!(toTaskType).array;
string toString(TaskType type)
  => type.to!string;
string[] toString(TaskType[] types)
  => types.map!toString.array;

///
unittest {
  mixin(ShowTest!("TaskType"));

  assert(TaskType.dataFlow.to!string == "dataFlow");
  assert(TaskType.replication.to!string == "replication");
  assert(TaskType.transform.to!string == "transform");
  assert(TaskType.deletion.to!string == "deletion");
  assert(TaskType.persistence.to!string == "persistence");

  assert("dataFlow".to!TaskType == TaskType.dataFlow);
  assert("replication".to!TaskType == TaskType.replication);
  assert("transform".to!TaskType == TaskType.transform);
  assert("deletion".to!TaskType == TaskType.deletion);
  assert("persistence".to!TaskType == TaskType.persistence);

  assert("dataFlow".toTaskType == TaskType.dataFlow);
  assert("replication".toTaskType == TaskType.replication);
  assert("transform".toTaskType == TaskType.transform);
  assert("deletion".toTaskType == TaskType.deletion);
  assert("persistence".toTaskType == TaskType.persistence);

  assert("noexists".toTaskType == TaskType.dataFlow); // Default case
  assert("".toTaskType == TaskType.dataFlow); // Default case

  assert(TaskType.dataFlow.toString == "dataFlow");
  assert(TaskType.replication.toString == "replication");
  assert(TaskType.transform.toString == "transform");
  assert(TaskType.deletion.toString == "deletion");
  assert(TaskType.persistence.toString == "persistence");

  assert(["dataFlow", "replication", "transform", "deletion", "persistence"].toTaskType ==
         [TaskType.dataFlow, TaskType.replication, TaskType.transform, TaskType.deletion, TaskType.persistence]);
  assert([TaskType.dataFlow, TaskType.replication, TaskType.transform, TaskType.deletion, TaskType.persistence].toString ==
         ["dataFlow", "replication", "transform", "deletion", "persistence"]);
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

TaskStatus toTaskStatus(string value) {
  mixin(EnumSwitch("TaskStatus", "scheduled"));
}
TaskStatus[] toTaskStatuses(string[] values)
  => values.map!(toTaskStatus).array;

string toString(TaskStatus status)
  => status.to!string;

string[] toString(TaskStatus[] statuses)
  => statuses.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("TaskStatus"));

  assert(TaskStatus.scheduled.to!string == "scheduled");
  assert(TaskStatus.running.to!string == "running");
  assert(TaskStatus.completed.to!string == "completed");
  assert(TaskStatus.failed.to!string == "failed");
  assert(TaskStatus.cancelled.to!string == "cancelled");
  assert(TaskStatus.pending.to!string == "pending");

  assert("scheduled".to!TaskStatus == TaskStatus.scheduled);
  assert("running".to!TaskStatus == TaskStatus.running);
  assert("completed".to!TaskStatus == TaskStatus.completed);
  assert("failed".to!TaskStatus == TaskStatus.failed);
  assert("cancelled".to!TaskStatus == TaskStatus.cancelled);
  assert("pending".to!TaskStatus == TaskStatus.pending);

  assert("scheduled".toTaskStatus == TaskStatus.scheduled);
  assert("running".toTaskStatus == TaskStatus.running);
  assert("completed".toTaskStatus == TaskStatus.completed);
  assert("failed".toTaskStatus == TaskStatus.failed);
  assert("cancelled".toTaskStatus == TaskStatus.cancelled);
  assert("pending".toTaskStatus == TaskStatus.pending);

  assert("noexists".toTaskStatus == TaskStatus.scheduled); // Default case
  assert("".toTaskStatus == TaskStatus.scheduled); // Default case

  assert(TaskStatus.scheduled.toString == "scheduled");
  assert(TaskStatus.running.toString == "running");
  assert(TaskStatus.completed.toString == "completed");
  assert(TaskStatus.failed.toString == "failed");
  assert(TaskStatus.cancelled.toString == "cancelled");
  assert(TaskStatus.pending.toString == "pending");

  assert(["scheduled", "running", "completed", "failed", "cancelled", "pending"].toTaskStatuses ==
         [TaskStatus.scheduled, TaskStatus.running, TaskStatus.completed, TaskStatus.failed, TaskStatus.cancelled, TaskStatus.pending]);
  assert([TaskStatus.scheduled, TaskStatus.running, TaskStatus.completed, TaskStatus.failed, TaskStatus.cancelled, TaskStatus.pending].toString ==
         ["scheduled", "running", "completed", "failed", "cancelled", "pending"]);
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

ScheduleFrequency toScheduleFrequency(string value) {
  mixin(EnumSwitch("ScheduleFrequency", "once"));
}
ScheduleFrequency[] toScheduleFrequencies(string[] values) {
  return values.map!(toScheduleFrequency).array;
}
string toString(ScheduleFrequency frequency) {
  return frequency.to!string;
}
string[] toString(ScheduleFrequency[] frequencies) {
  return frequencies.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("ScheduleFrequency"));

  assert(ScheduleFrequency.once.to!string == "once");
  assert(ScheduleFrequency.hourly.to!string == "hourly");
  assert(ScheduleFrequency.daily.to!string == "daily");
  assert(ScheduleFrequency.weekly.to!string == "weekly");
  assert(ScheduleFrequency.monthly.to!string == "monthly");
  assert(ScheduleFrequency.cron.to!string == "cron");

  assert("once".to!ScheduleFrequency == ScheduleFrequency.once);
  assert("hourly".to!ScheduleFrequency == ScheduleFrequency.hourly);
  assert("daily".to!ScheduleFrequency == ScheduleFrequency.daily);
  assert("weekly".to!ScheduleFrequency == ScheduleFrequency.weekly);
  assert("monthly".to!ScheduleFrequency == ScheduleFrequency.monthly);
  assert("cron".to!ScheduleFrequency == ScheduleFrequency.cron);

  assert("once".toScheduleFrequency == ScheduleFrequency.once);
  assert("hourly".toScheduleFrequency == ScheduleFrequency.hourly);
  assert("daily".toScheduleFrequency == ScheduleFrequency.daily);
  assert("weekly".toScheduleFrequency == ScheduleFrequency.weekly);
  assert("monthly".toScheduleFrequency == ScheduleFrequency.monthly);
  assert("cron".toScheduleFrequency == ScheduleFrequency.cron);

  assert("noexists".toScheduleFrequency == ScheduleFrequency.once); // Default case
  assert("".toScheduleFrequency == ScheduleFrequency.once); // Default case
}

// Data access control criteria type
enum CriteriaType {
  singleValues,
  ranges,
  hierarchy,
  responsibility,
}
CriteriaType toCriteriaType(string value) {
  mixin(EnumSwitch("CriteriaType", "singleValues"));
}
CriteriaType[] toCriteriaTypes(string[] values) {
  return values.map!(toCriteriaType).array;
}
string toString(CriteriaType type) {
  return type.to!string;
}
string[] toString(CriteriaType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("CriteriaType"));

  assert(CriteriaType.singleValues.to!string == "singleValues");
  assert(CriteriaType.ranges.to!string == "ranges");
  assert(CriteriaType.hierarchy.to!string == "hierarchy");
  assert(CriteriaType.responsibility.to!string == "responsibility");

  assert("singleValues".to!CriteriaType == CriteriaType.singleValues);
  assert("ranges".to!CriteriaType == CriteriaType.ranges);
  assert("hierarchy".to!CriteriaType == CriteriaType.hierarchy);
  assert("responsibility".to!CriteriaType == CriteriaType.responsibility);

  assert("singleValues".toCriteriaType == CriteriaType.singleValues);
  assert("ranges".toCriteriaType == CriteriaType.ranges);
  assert("hierarchy".toCriteriaType == CriteriaType.hierarchy);
  assert("responsibility".toCriteriaType == CriteriaType.responsibility);

  assert("noexists".toCriteriaType == CriteriaType.singleValues); // Default case
  assert("".toCriteriaType == CriteriaType.singleValues); // Default case
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

AssetType toAssetType(string value) {
  mixin(EnumSwitch("AssetType", "table"));
}
AssetType[] toAssetTypes(string[] values) {
  return values.map!(toAssetType).array;
}
string toString(AssetType type) {
  return type.to!string;
}
string[] toString(AssetType[] types) {
  return types.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("AssetType"));

  assert(AssetType.table.to!string == "table");
  assert(AssetType.view.to!string == "view");
  assert(AssetType.dataFlow.to!string == "dataFlow");
  assert(AssetType.connection.to!string == "connection");
  assert(AssetType.remoteTable.to!string == "remoteTable");
  assert(AssetType.localTable.to!string == "localTable");
  assert(AssetType.other.to!string == "other");

  assert("table".to!AssetType == AssetType.table);
  assert("view".to!AssetType == AssetType.view);
  assert("dataFlow".to!AssetType == AssetType.dataFlow);
  assert("connection".to!AssetType == AssetType.connection);
  assert("remoteTable".to!AssetType == AssetType.remoteTable);
  assert("localTable".to!AssetType == AssetType.localTable);
  assert("other".to!AssetType == AssetType.other);

  assert("table".toAssetType == AssetType.table);
  assert("view".toAssetType == AssetType.view);
  assert("dataFlow".toAssetType == AssetType.dataFlow);
  assert("connection".toAssetType == AssetType.connection);
  assert("remoteTable".toAssetType == AssetType.remoteTable);
  assert("localTable".toAssetType == AssetType.localTable);
  assert("other".toAssetType == AssetType.other);

  assert("noexists".toAssetType == AssetType.table); // Default case
  assert("".toAssetType == AssetType.table); // Default case
}

// Catalog asset quality status
enum QualityStatus {
  excellent,
  good,
  adequate,
  poor,
  unknown,
}

QualityStatus toQualityStatus(string value) {
  mixin(EnumSwitch("QualityStatus", "excellent"));
}
QualityStatus[] toQualityStatuses(string[] values) {
  return values.map!(toQualityStatus).array;
}
string toString(QualityStatus status) {
  return status.to!string;
}
string[] toString(QualityStatus[] statuses) {
  return statuses.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("QualityStatus"));

  assert(QualityStatus.excellent.to!string == "excellent");
  assert(QualityStatus.good.to!string == "good");
  assert(QualityStatus.adequate.to!string == "adequate");
  assert(QualityStatus.poor.to!string == "poor");
  assert(QualityStatus.unknown.to!string == "unknown");

  assert("excellent".toQualityStatus == QualityStatus.excellent);
  assert("good".toQualityStatus == QualityStatus.good);
  assert("adequate".toQualityStatus == QualityStatus.adequate);
  assert("poor".toQualityStatus == QualityStatus.poor);
  assert("unknown".toQualityStatus == QualityStatus.unknown);

  assert("noexists".toQualityStatus == QualityStatus.excellent); // Default case
  assert("".toQualityStatus == QualityStatus.excellent); // Default case

  assert([QualityStatus.excellent, QualityStatus.good, QualityStatus.adequate, QualityStatus.poor, QualityStatus.unknown].toString ==
         ["excellent", "good", "adequate", "poor", "unknown"]);
  assert(["excellent", "good", "adequate", "poor", "unknown"].toQualityStatuses ==
         [QualityStatus.excellent, QualityStatus.good, QualityStatus.adequate, QualityStatus.poor, QualityStatus.unknown]);
}

// Catalog asset sensitivity level
enum SensitivityLevel : string {
  public_ = "public",
  internal = "internal",
  confidential = "confidential",
  restricted = "restricted",
  custom = "custom",
}

SensitivityLevel toSensitivityLevel(string value) {
  switch(value.toLower) {
    case "public": return SensitivityLevel.public_;
    case "internal": return SensitivityLevel.internal;
    case "confidential": return SensitivityLevel.confidential;
    case "restricted": return SensitivityLevel.restricted;
    case "custom": return SensitivityLevel.custom;
    default: return SensitivityLevel.public_; // Default case
  }
}

SensitivityLevel[] toSensitivityLevels(string[] values) {
  return values.map!(toSensitivityLevel).array;
}

string toString(SensitivityLevel level) {
  return cast(string)level;
}

string[] toString(SensitivityLevel[] levels) {
  return levels.map!toString.array;
}

///
unittest {
  mixin(ShowTest!("SensitivityLevel"));

  assert(SensitivityLevel.public_.toString == "public");
  assert(SensitivityLevel.internal.toString == "internal");
  assert(SensitivityLevel.confidential.toString == "confidential");
  assert(SensitivityLevel.restricted.toString == "restricted");
  assert(SensitivityLevel.custom.toString == "custom");

  assert("public".toSensitivityLevel == SensitivityLevel.public_);
  assert("internal".toSensitivityLevel == SensitivityLevel.internal);
  assert("confidential".toSensitivityLevel == SensitivityLevel.confidential);
  assert("restricted".toSensitivityLevel == SensitivityLevel.restricted);
  assert("custom".toSensitivityLevel == SensitivityLevel.custom);

  assert("noexists".toSensitivityLevel == SensitivityLevel.public_); // Default case
  assert("".toSensitivityLevel == SensitivityLevel.public_); // Default case

  assert([SensitivityLevel.public_, SensitivityLevel.internal, SensitivityLevel.confidential, SensitivityLevel.restricted, SensitivityLevel.custom].toString ==
         ["public", "internal", "confidential", "restricted", "custom"]);
  assert(["public", "internal", "confidential", "restricted", "custom"].toSensitivityLevels ==
         [SensitivityLevel.public_, SensitivityLevel.internal, SensitivityLevel.confidential, SensitivityLevel.restricted, SensitivityLevel.custom]);
}

// Data lineage relationship type
enum LineageRelationship {
  source,
  transformation,
  target,
  reference,
  other,
}

LineageRelationship toLineageRelationship(string value) {
  mixin(EnumSwitch("LineageRelationship", "source"));
}

LineageRelationship[] toLineageRelationships(string[] values) {
  return values.map!(toLineageRelationship).array;
}

string toString(LineageRelationship relationship) {
  return relationship.to!string;
}

string[] toString(LineageRelationship[] relationships) {
  return relationships.map!toString.array;
}

///
unittest {
  mixin(ShowTest!("LineageRelationship"));

  assert(LineageRelationship.source.to!string == "source");
  assert(LineageRelationship.transformation.to!string == "transformation");
  assert(LineageRelationship.target.to!string == "target");
  assert(LineageRelationship.reference.to!string == "reference");
  assert(LineageRelationship.other.to!string == "other");

  assert("source".toLineageRelationship == LineageRelationship.source);
  assert("transformation".toLineageRelationship == LineageRelationship.transformation);
  assert("target".toLineageRelationship == LineageRelationship.target);
  assert("reference".toLineageRelationship == LineageRelationship.reference);
  assert("other".toLineageRelationship == LineageRelationship.other);

  assert("noexists".toLineageRelationship == LineageRelationship.source); // Default case
  assert("".toLineageRelationship == LineageRelationship.source); // Default case

  assert([LineageRelationship.source, LineageRelationship.transformation, LineageRelationship.target, LineageRelationship.reference, LineageRelationship.other].toString ==
         ["source", "transformation", "target", "reference", "other"]);
  assert(["source", "transformation", "target", "reference", "other"].toLineageRelationships ==
         [LineageRelationship.source, LineageRelationship.transformation, LineageRelationship.target, LineageRelationship.reference, LineageRelationship.other]);
}

// Data retention policy type
enum RetentionPolicyType {
  timeBased,
  eventBased,
  legalHold,
  custom,
}
RetentionPolicyType toRetentionPolicyType(string value) {
  mixin(EnumSwitch("RetentionPolicyType", "timeBased"));
}
RetentionPolicyType[] toRetentionPolicyTypes(string[] values) {
  return values.map!(toRetentionPolicyType).array;
}
string toString(RetentionPolicyType type) {
  return type.to!string;
}
string[] toString(RetentionPolicyType[] types) {
  return types.map!toString.array;
}

///
unittest {
  mixin(ShowTest!("RetentionPolicyType"));

  assert(RetentionPolicyType.timeBased.to!string == "timeBased");
  assert(RetentionPolicyType.eventBased.to!string == "eventBased");
  assert(RetentionPolicyType.legalHold.to!string == "legalHold");
  assert(RetentionPolicyType.custom.to!string == "custom");

  assert("timeBased".toRetentionPolicyType == RetentionPolicyType.timeBased);
  assert("eventBased".toRetentionPolicyType == RetentionPolicyType.eventBased);
  assert("legalHold".toRetentionPolicyType == RetentionPolicyType.legalHold);
  assert("custom".toRetentionPolicyType == RetentionPolicyType.custom);

  assert("noexists".toRetentionPolicyType == RetentionPolicyType.timeBased); // Default case
  assert("".toRetentionPolicyType == RetentionPolicyType.timeBased); // Default case

  assert([RetentionPolicyType.timeBased, RetentionPolicyType.eventBased, RetentionPolicyType.legalHold, RetentionPolicyType.custom].toString ==
         ["timeBased", "eventBased", "legalHold", "custom"]);
  assert(["timeBased", "eventBased", "legalHold", "custom"].toRetentionPolicyTypes ==
         [RetentionPolicyType.timeBased, RetentionPolicyType.eventBased, RetentionPolicyType.legalHold, RetentionPolicyType.custom]);
}

// Data retention action
enum RetentionAction {
  delete_,
  archive,
  anonymize,
  notify,
  custom,
}

RetentionAction toRetentionAction(string value) {
  mixin(EnumSwitch("RetentionAction", "delete_"));
}
RetentionAction[] toRetentionActions(string[] values) {
  return values.map!(toRetentionAction).array;
}
string toString(RetentionAction action) {
  return action.to!string;
}
string[] toString(RetentionAction[] actions) {
  return actions.map!toString.array;
}
///
unittest {
  mixin(ShowTest!("RetentionAction"));

  assert(RetentionAction.delete_.to!string == "delete_");
  assert(RetentionAction.archive.to!string == "archive");
  assert(RetentionAction.anonymize.to!string == "anonymize");
  assert(RetentionAction.notify.to!string == "notify");
  assert(RetentionAction.custom.to!string == "custom");

  assert("delete_".toRetentionAction == RetentionAction.delete_);
  assert("archive".toRetentionAction == RetentionAction.archive);
  assert("anonymize".toRetentionAction == RetentionAction.anonymize);
  assert("notify".toRetentionAction == RetentionAction.notify);
  assert("custom".toRetentionAction == RetentionAction.custom);

  assert("noexists".toRetentionAction == RetentionAction.delete_); // Default case
  assert("".toRetentionAction == RetentionAction.delete_); // Default case

  assert([RetentionAction.delete_, RetentionAction.archive, RetentionAction.anonymize, RetentionAction.notify, RetentionAction.custom].toString ==
         ["delete_", "archive", "anonymize", "notify", "custom"]);
  assert(["delete_", "archive", "anonymize", "notify", "custom"].toRetentionActions ==
         [RetentionAction.delete_, RetentionAction.archive, RetentionAction.anonymize, RetentionAction.notify, RetentionAction.custom]);
}
