/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.enumerations;

import uim.platform.hana;

mixin(ShowModule!());

@safe:


// Database instance type
enum InstanceType {
  hana,
  hanaExpress,
  hanaCloud,
  trial,
  free,
}
InstanceType toInstanceType(string s) {
  mixin(EnumSwitch!"InstanceType", "free");
}
InstanceType[] toInstanceType(string[] values) {
  return values.map!(v => toInstanceType(v)).array;
}
string toString(InstanceType value) {
  return value.to!string;
}
string[] toString(InstanceType[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"InstanceType");

  assert("hana".toInstanceType == InstanceType.hana);
  assert("hana_express".toInstanceType == InstanceType.hanaExpress);
  assert("hana_cloud".toInstanceType == InstanceType.hanaCloud);
  assert("trial".toInstanceType == InstanceType.trial);
  assert("free".toInstanceType == InstanceType.free);

  assert("".toInstanceType == InstanceType.free);
  assert("unknown".toInstanceType == InstanceType.free);

}

// Instance status
enum InstanceStatus {
  creating,
  running,
  stopped,
  starting,
  stopping,
  updating,
  deleting,
  error,
  suspended,
}
InstanceStatus toInstanceStatus(string value) {
  mixin(EnumSwitch!"InstanceStatus", "error");
}
InstanceStatus[] toInstanceStatus(string[] values) {
  return values.map!(v => toInstanceStatus(v)).array;
}
string toString(InstanceStatus value) {
  return value.to!string; 
}
string[] toString(InstanceStatus[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest { 
mixin(ShowTest!"InstanceStatus");

  assert("creating".toInstanceStatus == InstanceStatus.creating);
  assert("running".toInstanceStatus == InstanceStatus.running);
  assert("stopped".toInstanceStatus == InstanceStatus.stopped);
  assert("starting".toInstanceStatus == InstanceStatus.starting);
  assert("stopping".toInstanceStatus == InstanceStatus.stopping);
  assert("updating".toInstanceStatus == InstanceStatus.updating);
  assert("deleting".toInstanceStatus == InstanceStatus.deleting);
  assert("error".toInstanceStatus == InstanceStatus.error);
  assert("suspended".toInstanceStatus == InstanceStatus.suspended);

  assert("".toInstanceStatus == InstanceStatus.error);
  assert("unknown".toInstanceStatus == InstanceStatus.error);

  assert(toString(InstanceStatus.creating) == "creating");
  assert(toString(InstanceStatus.running) == "running");
  assert(toString(InstanceStatus.stopped) == "stopped");
  assert(toString(InstanceStatus.starting) == "starting");
  assert(toString(InstanceStatus.stopping) == "stopping");
  assert(toString(InstanceStatus.updating) == "updating");
  assert(toString(InstanceStatus.deleting) == "deleting");
  assert(toString(InstanceStatus.error) == "error");
  assert(toString(InstanceStatus.suspended) == "suspended");

  assert(toInstanceStatusArray(["creating", "running", "unknown"]) == [InstanceStatus.creating, InstanceStatus.running, InstanceStatus.error]);
  assert(toStringArray([InstanceStatus.creating, InstanceStatus.suspended]) == ["creating", "suspended"]);  
}

// Instance size class
enum InstanceSize {
  xs,
  s,
  m,
  l,
  xl,
  xxl,
  custom,
}
InstanceSize toInstanceSize(string value) {
  mixin(EnumSwitch!"InstanceSize", "custom");
}
InstanceSize[] toInstanceSize(string[] values) {
  return values.map!(v => toInstanceSize(v)).array;
}
string toString(InstanceSize value) {
  return value.to!string;
}
string[] toString(InstanceSize[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"InstanceSize");

  assert("xs".toInstanceSize == InstanceSize.xs);
  assert("s".toInstanceSize == InstanceSize.s); 
  assert("m".toInstanceSize == InstanceSize.m);
  assert("l".toInstanceSize == InstanceSize.l);
  assert("xl".toInstanceSize == InstanceSize.xl);
  assert("xxl".toInstanceSize == InstanceSize.xxl);
  assert("custom".toInstanceSize == InstanceSize.custom);

  assert("".toInstanceSize == InstanceSize.custom);
  assert("unknown".toInstanceSize == InstanceSize.custom);

  assert(InstanceSize.xs.toString == "xs");
  assert(InstanceSize.s.toString == "s");
  assert(InstanceSize.m.toString == "m");
  assert(InstanceSize.l.toString == "l");
  assert(InstanceSize.xl.toString == "xl");
  assert(InstanceSize.xxl.toString == "xxl");
  assert(InstanceSize.custom.toString == "custom");

  assert([InstanceSize.xs, InstanceSize.m, InstanceSize.custom].toStringArray == ["xs", "m", "custom"]);
  assert(["xs", "m", "custom"].toInstanceSizeArray == [InstanceSize.xs, InstanceSize.m, InstanceSize.custom]);
}

// Data lake storage tier
enum StorageTier {
  hot,
  warm,
  cold,
}
StorageTier toStorageTier(string s) {
  mixin(EnumSwitch!"StorageTier", "cold");
} 
StorageTier[] toStorageTier(string[] values) {
  return values.map!(v => toStorageTier(v)).array;
}
string toString(StorageTier value) {
  return value.to!string;
}
string[] toString(StorageTier[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"StorageTier");

  assert("hot".toStorageTier == StorageTier.hot);
  assert("warm".toStorageTier == StorageTier.warm);
  assert("cold".toStorageTier == StorageTier.cold);

  assert("".toStorageTier == StorageTier.cold);
  assert("unknown".toStorageTier == StorageTier.cold);

  assert(toString(StorageTier.hot) == "hot");
  assert(toString(StorageTier.warm) == "warm");
  assert(toString(StorageTier.cold) == "cold");

  assert(toStorageTierArray(["hot", "warm", "unknown"]) == [StorageTier.hot, StorageTier.warm, StorageTier.cold]);
  assert(toStringArray([StorageTier.hot, StorageTier.cold]) == ["hot", "cold"]);
}

// Data lake status
enum DataLakeStatus {
  creating,
  running,
  stopped,
  error,
  deleting,
}
DataLakeStatus toDataLakeStatus(string value) {
  mixin(EnumSwitch!"DataLakeStatus", "error");
}
DataLakeStatus[] toDataLakeStatus(string[] values) {
  return values.map!(v => toDataLakeStatus(v)).array;
}
string toString(DataLakeStatus value) {
  return value.to!string;
}
string[] toString(DataLakeStatus[] values) {
  return values.map!(v => toString(v)).array;
}
/// 
unittest {
  mixin(ShowTest!"DataLakeStatus");

  assert("creating".toDataLakeStatus == DataLakeStatus.creating);
  assert("running".toDataLakeStatus == DataLakeStatus.running);
  assert("stopped".toDataLakeStatus == DataLakeStatus.stopped);
  assert("error".toDataLakeStatus == DataLakeStatus.error);
  assert("deleting".toDataLakeStatus == DataLakeStatus.deleting);

  assert("".toDataLakeStatus == DataLakeStatus.error);
  assert("unknown".toDataLakeStatus == DataLakeStatus.error);

  assert(toString(DataLakeStatus.creating) == "creating");
  assert(toString(DataLakeStatus.running) == "running");
  assert(toString(DataLakeStatus.stopped) == "stopped");
  assert(toString(DataLakeStatus.error) == "error");
  assert(toString(DataLakeStatus.deleting) == "deleting");

  assert(toDataLakeStatusArray(["creating", "running", "unknown"]) == [DataLakeStatus.creating, DataLakeStatus.running, DataLakeStatus.error]);
  assert(toStringArray([DataLakeStatus.creating, DataLakeStatus.deleting]) == ["creating", "deleting"]);
}

// Data lake file format
enum FileFormat {
  parquet,
  csv,
  orc,
  json,
  avro,
}
FileFormat toFileFormat(string s) {
  mixin(EnumSwitch!"FileFormat", "parquet");
}
FileFormat[] toFileFormat(string[] values) {
  return values.map!(v => toFileFormat(v)).array;
}
string toString(FileFormat value) {
  return value.to!string;
}
string[] toString(FileFormat[] values) {
  return values.map!(v => toString(v)).array;
} 
///
unittest {
  mixin(ShowTest!"FileFormat");

  assert("parquet".toFileFormat == FileFormat.parquet);
  assert("csv".toFileFormat == FileFormat.csv);
  assert("orc".toFileFormat == FileFormat.orc);
  assert("json".toFileFormat == FileFormat.json);
  assert("avro".toFileFormat == FileFormat.avro);

  assert("".toFileFormat == FileFormat.parquet);
  assert("unknown".toFileFormat == FileFormat.parquet);

  assert(toString(FileFormat.parquet) == "parquet");
  assert(toString(FileFormat.csv) == "csv");
  assert(toString(FileFormat.orc) == "orc");
  assert(toString(FileFormat.json) == "json");
  assert(toString(FileFormat.avro) == "avro");

  assert(toFileFormatArray(["parquet", "csv", "unknown"]) == [FileFormat.parquet, FileFormat.csv, FileFormat.parquet]);
  assert(toStringArray([FileFormat.parquet, FileFormat.avro]) == ["parquet", "avro"]);
}

// Schema type
enum SchemaType {
  standard,
  hdi,
  virtual,
  system,
  temporary,
}
SchemaType toSchemaType(string s) {
  mixin(EnumSwitch!"SchemaType", "standard");
}
SchemaType[] toSchemaType(string[] values) {
  return values.map!(v => toSchemaType(v)).array;
}
string toString(SchemaType value) {
  return value.to!string;
}
string[] toString(SchemaType[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"SchemaType");

  assert("standard".toSchemaType == SchemaType.standard);
  assert("hdi".toSchemaType == SchemaType.hdi);
  assert("virtual".toSchemaType == SchemaType.virtual);
  assert("system".toSchemaType == SchemaType.system);
  assert("temporary".toSchemaType == SchemaType.temporary);

  assert("".toSchemaType == SchemaType.standard);
  assert("unknown".toSchemaType == SchemaType.standard);

  assert(toString(SchemaType.standard) == "standard");
  assert(toString(SchemaType.hdi) == "hdi");
  assert(toString(SchemaType.virtual) == "virtual");
  assert(toString(SchemaType.system) == "system");
  assert(toString(SchemaType.temporary) == "temporary");

  assert(toSchemaTypeArray(["standard", "hdi", "unknown"]) == [SchemaType.standard, SchemaType.hdi, SchemaType.standard]);
  assert(toStringArray([SchemaType.standard, SchemaType.temporary]) == ["standard", "temporary"]);
}

// Database user authentication type
enum AuthType {
  password,
  kerberos,
  saml,
  x509,
  jwt,
  ldap,
}
AuthType toAuthType(string s) {
  mixin(EnumSwitch!"AuthType", "password");
}
AuthType[] toAuthType(string[] values) {
  return values.map!(v => toAuthType(v)).array;
}
string toString(AuthType value) {
  return value.to!string;
}
string[] toString(AuthType[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"AuthType");

  assert("password".toAuthType == AuthType.password);
  assert("kerberos".toAuthType == AuthType.kerberos);
  assert("saml".toAuthType == AuthType.saml);
  assert("x509".toAuthType == AuthType.x509);
  assert("jwt".toAuthType == AuthType.jwt);
  assert("ldap".toAuthType == AuthType.ldap);

  assert("".toAuthType == AuthType.password);
  assert("unknown".toAuthType == AuthType.password);

  assert(toString(AuthType.password) == "password");
  assert(toString(AuthType.kerberos) == "kerberos");
  assert(toString(AuthType.saml) == "saml");
  assert(toString(AuthType.x509) == "x509");
  assert(toString(AuthType.jwt) == "jwt");
  assert(toString(AuthType.ldap) == "ldap");  

  assert(toAuthTypeArray(["password", "saml", "unknown"]) == [AuthType.password, AuthType.saml, AuthType.password]);
  assert(toStringArray([AuthType.password, AuthType.ldap]) == ["password", "ldap"]);
}

// Database user status
enum UserStatus {
  active,
  deactivated,
  locked,
  expired,
}
UserStatus toUserStatus(string s) {
  mixin(EnumSwitch!"UserStatus", "active");
}
UserStatus[] toUserStatus(string[] values) {
  return values.map!(v => toUserStatus(v)).array;
}
string toString(UserStatus value) {
  return value.to!string;
}
string[] toString(UserStatus[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"UserStatus");

  assert("active".toUserStatus == UserStatus.active);
  assert("deactivated".toUserStatus == UserStatus.deactivated);
  assert("locked".toUserStatus == UserStatus.locked);
  assert("expired".toUserStatus == UserStatus.expired);

  assert("".toUserStatus == UserStatus.active);
  assert("unknown".toUserStatus == UserStatus.active);

  assert(toString(UserStatus.active) == "active");
  assert(toString(UserStatus.deactivated) == "deactivated");
  assert(toString(UserStatus.locked) == "locked");
  assert(toString(UserStatus.expired) == "expired");

  assert(toUserStatusArray(["active", "locked", "unknown"]) == [UserStatus.active, UserStatus.locked, UserStatus.active]);
  assert(toStringArray([UserStatus.active, UserStatus.expired]) == ["active", "expired"]);
}

// Privilege type
enum PrivilegeType {
  system,
  object_,
  analytic,
  package_,
  application,
  role,
}
PrivilegeType toPrivilegeType(string s) {
  mixin(EnumSwitch!"PrivilegeType", "system");
} 
PrivilegeType[] toPrivilegeType(string[] values) {
  return values.map!(v => toPrivilegeType(v)).array;
}
string toString(PrivilegeType value) {
  return value.to!string;
}
string[] toString(PrivilegeType[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"PrivilegeType");

  assert("system".toPrivilegeType == PrivilegeType.system);
  assert("object".toPrivilegeType == PrivilegeType.object_);
  assert("analytic".toPrivilegeType == PrivilegeType.analytic);
  assert("package".toPrivilegeType == PrivilegeType.package_);
  assert("application".toPrivilegeType == PrivilegeType.application);
  assert("role".toPrivilegeType == PrivilegeType.role);

  assert("".toPrivilegeType == PrivilegeType.system);
  assert("unknown".toPrivilegeType == PrivilegeType.system);

  assert(toString(PrivilegeType.system) == "system");
  assert(toString(PrivilegeType.object_) == "object");
  assert(toString(PrivilegeType.analytic) == "analytic");
  assert(toString(PrivilegeType.package_) == "package");
  assert(toString(PrivilegeType.application) == "application");
  assert(toString(PrivilegeType.role) == "role");

  assert(toPrivilegeTypeArray(["system", "analytic", "unknown"]) == [PrivilegeType.system, PrivilegeType.analytic, PrivilegeType.system]);
  assert(toStringArray([PrivilegeType.system, PrivilegeType.role]) == ["system", "role"]);
}

// Backup type
enum BackupType {
  full,
  incremental,
  differential,
  log,
  snapshot,
}
BackupType toBackupType(string s) {
  mixin(EnumSwitch!"BackupType", "full");
}
BackupType[] toBackupType(string[] values) {
  return values.map!(v => toBackupType(v)).array;
}
string toString(BackupType value) {
  return value.to!string;
}
string[] toString(BackupType[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"BackupType");

  assert("full".toBackupType == BackupType.full);
  assert("incremental".toBackupType == BackupType.incremental);
  assert("differential".toBackupType == BackupType.differential);
  assert("log".toBackupType == BackupType.log);
  assert("snapshot".toBackupType == BackupType.snapshot);

  assert("".toBackupType == BackupType.full);
  assert("unknown".toBackupType == BackupType.full);

  assert(toString(BackupType.full) == "full");
  assert(toString(BackupType.incremental) == "incremental");
  assert(toString(BackupType.differential) == "differential");
  assert(toString(BackupType.log) == "log");
  assert(toString(BackupType.snapshot) == "snapshot");

  assert(toBackupTypeArray(["full", "log", "unknown"]) == [BackupType.full, BackupType.log, BackupType.full]);
  assert(toStringArray([BackupType.full, BackupType.snapshot]) == ["full", "snapshot"]);
}

// Backup status
enum BackupStatus {
  scheduled,
  running,
  completed,
  failed,
  cancelled,
}
BackupStatus toBackupStatus(string s) {
  mixin(EnumSwitch!"BackupStatus", "scheduled");
}
BackupStatus[] toBackupStatus(string[] values) {
  return values.map!(v => toBackupStatus(v)).array;
}
string toString(BackupStatus value) {
  return value.to!string;
}
string[] toString(BackupStatus[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"BackupStatus");

  assert("scheduled".toBackupStatus == BackupStatus.scheduled);
  assert("running".toBackupStatus == BackupStatus.running);
  assert("completed".toBackupStatus == BackupStatus.completed);
  assert("failed".toBackupStatus == BackupStatus.failed);
  assert("cancelled".toBackupStatus == BackupStatus.cancelled);

  assert("".toBackupStatus == BackupStatus.scheduled);
  assert("unknown".toBackupStatus == BackupStatus.scheduled);

  assert(toString(BackupStatus.scheduled) == "scheduled");
  assert(toString(BackupStatus.running) == "running");
  assert(toString(BackupStatus.completed) == "completed");
  assert(toString(BackupStatus.failed) == "failed");
  assert(toString(BackupStatus.cancelled) == "cancelled");

  assert(toBackupStatusArray(["scheduled", "failed", "unknown"]) == [BackupStatus.scheduled, BackupStatus.failed, BackupStatus.scheduled]);
  assert(toStringArray([BackupStatus.scheduled, BackupStatus.cancelled]) == ["scheduled", "cancelled"]);
} 

// Alert status
enum AlertStatus {
  active,
  acknowledged,
  resolved,
  suppressed,
}
AlertStatus toAlertStatus(string s) {
  mixin(EnumSwitch!"AlertStatus", "active");
}
AlertStatus[] toAlertStatus(string[] values) {
  return values.map!(v => toAlertStatus(v)).array;
}
string toString(AlertStatus value) {
  return value.to!string;
}
string[] toString(AlertStatus[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"AlertStatus");

  assert("active".toAlertStatus == AlertStatus.active);
  assert("acknowledged".toAlertStatus == AlertStatus.acknowledged);
  assert("resolved".toAlertStatus == AlertStatus.resolved);
  assert("suppressed".toAlertStatus == AlertStatus.suppressed);

  assert("".toAlertStatus == AlertStatus.active);
  assert("unknown".toAlertStatus == AlertStatus.active);

  assert(toString(AlertStatus.active) == "active");
  assert(toString(AlertStatus.acknowledged) == "acknowledged");
  assert(toString(AlertStatus.resolved) == "resolved");
  assert(toString(AlertStatus.suppressed) == "suppressed");

  assert(toAlertStatusArray(["active", "resolved", "unknown"]) == [AlertStatus.active, AlertStatus.resolved, AlertStatus.active]);
  assert(toStringArray([AlertStatus.active, AlertStatus.suppressed]) == ["active", "suppressed"]);
}

// Alert category
enum AlertCategory {
  performance,
  availability,
  storage,
  memory,
  cpu,
  replication,
  backup,
  security,
  configuration,
}
AlertCategory toAlertCategory(string s) {
  mixin(EnumSwitch!"AlertCategory", "performance");
}
AlertCategory[] toAlertCategory(string[] values) {
  return values.map!(v => toAlertCategory(v)).array;
}
string toString(AlertCategory value) {
  return value.to!string;
}
string[] toString(AlertCategory[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"AlertCategory");

  assert("performance".toAlertCategory == AlertCategory.performance);
  assert("availability".toAlertCategory == AlertCategory.availability);
  assert("storage".toAlertCategory == AlertCategory.storage);
  assert("memory".toAlertCategory == AlertCategory.memory);
  assert("cpu".toAlertCategory == AlertCategory.cpu);
  assert("replication".toAlertCategory == AlertCategory.replication);
  assert("backup".toAlertCategory == AlertCategory.backup);
  assert("security".toAlertCategory == AlertCategory.security);
  assert("configuration".toAlertCategory == AlertCategory.configuration); 

  assert("".toAlertCategory == AlertCategory.performance);
  assert("unknown".toAlertCategory == AlertCategory.performance);

  assert(toString(AlertCategory.performance) == "performance");
  assert(toString(AlertCategory.availability) == "availability");
  assert(toString(AlertCategory.storage) == "storage");
  assert(toString(AlertCategory.memory) == "memory");
  assert(toString(AlertCategory.cpu) == "cpu");
  assert(toString(AlertCategory.replication) == "replication");
  assert(toString(AlertCategory.backup) == "backup"); 
  assert(toString(AlertCategory.security) == "security");
  assert(toString(AlertCategory.configuration) == "configuration");

  assert([AlertCategory.performance, AlertCategory.backup, AlertCategory.unknown].toStringArray == ["performance", "backup", "performance"]);
  assert(["performance", "backup", "unknown"].toAlertCategoryArray == [AlertCategory.performance, AlertCategory.backup, AlertCategory.performance]);
}

// HDI container status
enum HDIContainerStatus {
  creating,
  active,
  inactive,
  error,
  deleting,
}
HDIContainerStatus toHDIContainerStatus(string s) {
  mixin(EnumSwitch!"HDIContainerStatus", "error");
}
HDIContainerStatus[] toHDIContainerStatus(string[] values) {
  return values.map!(v => toHDIContainerStatus(v)).array;
}
string toString(HDIContainerStatus value) {
  return value.to!string;
}
string[] toString(HDIContainerStatus[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"HDIContainerStatus");

  assert("creating".toHDIContainerStatus == HDIContainerStatus.creating);
  assert("active".toHDIContainerStatus == HDIContainerStatus.active);
  assert("inactive".toHDIContainerStatus == HDIContainerStatus.inactive);
  assert("error".toHDIContainerStatus == HDIContainerStatus.error);
  assert("deleting".toHDIContainerStatus == HDIContainerStatus.deleting);

  assert("".toHDIContainerStatus == HDIContainerStatus.error);
  assert("unknown".toHDIContainerStatus == HDIContainerStatus.error);

  assert(toString(HDIContainerStatus.creating) == "creating");
  assert(toString(HDIContainerStatus.active) == "active");
  assert(toString(HDIContainerStatus.inactive) == "inactive");
  assert(toString(HDIContainerStatus.error) == "error");
  assert(toString(HDIContainerStatus.deleting) == "deleting");

  assert(toHDIContainerStatusArray(["creating", "active", "unknown"]) == [HDIContainerStatus.creating, HDIContainerStatus.active, HDIContainerStatus.error]);
  assert(toStringArray([HDIContainerStatus.creating, HDIContainerStatus.deleting]) == ["creating", "deleting"]);
}

// Replication mode
enum ReplicationMode {
  none,
  realtime,
  scheduled,
  snapshot,
  logBased,
}
ReplicationMode toReplicationMode(string value) {
  mixin(EnumSwitch!"ReplicationMode", "none");
}
ReplicationMode[] toReplicationMode(string[] values) {
  return values.map!(v => toReplicationMode(v)).array;
}
string toString(ReplicationMode value) {
  return value.to!string;
}
string[] toString(ReplicationMode[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"ReplicationMode");

  assert("none".toReplicationMode == ReplicationMode.none);
  assert("realtime".toReplicationMode == ReplicationMode.realtime);
  assert("scheduled".toReplicationMode == ReplicationMode.scheduled);
  assert("snapshot".toReplicationMode == ReplicationMode.snapshot);
  assert("logBased".toReplicationMode == ReplicationMode.logBased);

  assert("".toReplicationMode == ReplicationMode.none);
  assert("unknown".toReplicationMode == ReplicationMode.none);

  assert(toString(ReplicationMode.none) == "none");
  assert(toString(ReplicationMode.realtime) == "realtime");
  assert(toString(ReplicationMode.scheduled) == "scheduled");
  assert(toString(ReplicationMode.snapshot) == "snapshot");
  assert(toString(ReplicationMode.logBased) == "logBased");

  assert(toReplicationModeArray(["none", "scheduled", "unknown"]) == [ReplicationMode.none, ReplicationMode.scheduled, ReplicationMode.none]);
  assert(toStringArray([ReplicationMode.none, ReplicationMode.logBased]) == ["none", "logBased"]);
}

// Replication task status
enum ReplicationTaskStatus {
  active,
  inactive,
  running,
  completed,
  failed,
  paused,
}
ReplicationTaskStatus toReplicationTaskStatus(string value) {
  mixin(EnumSwitch!"ReplicationTaskStatus", "inactive");
}
ReplicationTaskStatus[] toReplicationTaskStatus(string[] values) {
  return values.map!(v => toReplicationTaskStatus(v)).array;
}
string toString(ReplicationTaskStatus value) {
  return value.to!string;
}
string[] toStringArray(ReplicationTaskStatus[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"ReplicationTaskStatus");

  assert("active".toReplicationTaskStatus == ReplicationTaskStatus.active);
  assert("inactive".toReplicationTaskStatus == ReplicationTaskStatus.inactive);
  assert("running".toReplicationTaskStatus == ReplicationTaskStatus.running);
  assert("completed".toReplicationTaskStatus == ReplicationTaskStatus.completed);
  assert("failed".toReplicationTaskStatus == ReplicationTaskStatus.failed);
  assert("paused".toReplicationTaskStatus == ReplicationTaskStatus.paused);

  assert("".toReplicationTaskStatus == ReplicationTaskStatus.inactive);
  assert("unknown".toReplicationTaskStatus == ReplicationTaskStatus.inactive);

  assert(toString(ReplicationTaskStatus.active) == "active");
  assert(toString(ReplicationTaskStatus.inactive) == "inactive");
  assert(toString(ReplicationTaskStatus.running) == "running");
  assert(toString(ReplicationTaskStatus.completed) == "completed");
  assert(toString(ReplicationTaskStatus.failed) == "failed");
  assert(toString(ReplicationTaskStatus.paused) == "paused");

  assert(toReplicationTaskStatusArray(["active", "failed", "unknown"]) == [ReplicationTaskStatus.active, ReplicationTaskStatus.failed, ReplicationTaskStatus.inactive]);
  assert(toStringArray([ReplicationTaskStatus.active, ReplicationTaskStatus.paused]) == ["active", "paused"]);
}

// Configuration scope
enum ConfigScope {
  system,
  database,
  tenant,
  session,
}
ConfigScope toConfigScope(string s) {
  mixin(EnumSwitch!"ConfigScope", "system");
}
ConfigScope[] toConfigScope(string[] values) {
  return values.map!(v => toConfigScope(v)).array;
}
string toString(ConfigScope value) {
  return value.to!string;
}
string[] toString(ConfigScope[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"ConfigScope");

  assert("system".toConfigScope == ConfigScope.system);
  assert("database".toConfigScope == ConfigScope.database);
  assert("tenant".toConfigScope == ConfigScope.tenant);
  assert("session".toConfigScope == ConfigScope.session);

  assert("".toConfigScope == ConfigScope.system);
  assert("unknown".toConfigScope == ConfigScope.system);

  assert(toString(ConfigScope.system) == "system");
  assert(toString(ConfigScope.database) == "database");
  assert(toString(ConfigScope.tenant) == "tenant");
  assert(toString(ConfigScope.session) == "session");

  assert(toConfigScopeArray(["system", "tenant", "unknown"]) == [ConfigScope.system, ConfigScope.tenant, ConfigScope.system]);
  assert(toStringArray([ConfigScope.system, ConfigScope.session]) == ["system", "session"]);
}

// Configuration data type
enum ConfigDataType {
  string_,
  integer,
  boolean_,
  decimal,
  duration,
}
ConfigDataType toConfigDataType(string s) {
  mixin(EnumSwitch!"ConfigDataType", "string_");
}
ConfigDataType[] toConfigDataType(string[] values) {
  return values.map!(v => toConfigDataType(v)).array;
}
string toString(ConfigDataType value) {
  return value.to!string;
}
string[] toString(ConfigDataType[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"ConfigDataType"); 

  assert("string".toConfigDataType == ConfigDataType.string_);
  assert("integer".toConfigDataType == ConfigDataType.integer);
  assert("boolean".toConfigDataType == ConfigDataType.boolean_);
  assert("decimal".toConfigDataType == ConfigDataType.decimal);
  assert("duration".toConfigDataType == ConfigDataType.duration); 

  assert("".toConfigDataType == ConfigDataType.string_);
  assert("unknown".toConfigDataType == ConfigDataType.string_);

  assert(toString(ConfigDataType.string_) == "string");
  assert(toString(ConfigDataType.integer) == "integer");
  assert(toString(ConfigDataType.boolean_) == "boolean");
  assert(toString(ConfigDataType.decimal) == "decimal");
  assert(toString(ConfigDataType.duration) == "duration");

  assert(toConfigDataTypeArray(["string", "decimal", "unknown"]) == [ConfigDataType.string_, ConfigDataType.decimal, ConfigDataType.string_]);
  assert(toStringArray([ConfigDataType.string_, ConfigDataType.duration]) == ["string", "duration"]);
}

// Connection type
enum ConnectionType {
  jdbc,
  odbc,
  hdbsql,
  nodeJs,
  python,
  java,
  go,
  dotnet,
}
ConnectionType toConnectionType(string value) {
  mixin(EnumSwitch!"ConnectionType", "jdbc");
} 
ConnectionType[] toConnectionType(string[] values) {
  return values.map!(toConnectionType).array;
}
string toString(ConnectionType type) {
  return type.to!string;
}
string[] toString(ConnectionType[] types) {
  return types.map!(toString).array;
}
///
unittest {
  assert("jdbc".toConnectionType == ConnectionType.jdbc);
  assert("odbc".toConnectionType == ConnectionType.odbc);
  assert("hdbsql".toConnectionType == ConnectionType.hdbsql);
  assert("nodeJs".toConnectionType == ConnectionType.nodeJs);
  assert("python".toConnectionType == ConnectionType.python);
  assert("java".toConnectionType == ConnectionType.java);
  assert("go".toConnectionType == ConnectionType.go);
  assert("dotnet".toConnectionType == ConnectionType.dotnet);

  assert("".toConnectionType == ConnectionType.jdbc);
  assert("unknown".toConnectionType == ConnectionType.jdbc);
  
  assert(ConnectionType.jdbc.toString == "jdbc");
  assert(ConnectionType.odbc.toString == "odbc");
  assert(ConnectionType.hdbsql.toString == "hdbsql");
  assert(ConnectionType.nodeJs.toString == "nodeJs");
  assert(ConnectionType.python.toString == "python");
  assert(ConnectionType.java.toString == "java");
  assert(ConnectionType.go.toString == "go");
  assert(ConnectionType.dotnet.toString == "dotnet");

  assert(["jdbc", "odbc", "java"].toConnectionType == [ConnectionType.jdbc, ConnectionType.odbc, ConnectionType.java]);
  assert([ConnectionType.jdbc, ConnectionType.odbc, ConnectionType.java].toString == ["jdbc", "odbc", "java"]);
}

// Connection status
enum ConnectionStatus {
  active,
  inactive,
  error,
  pooled,
}
ConnectionStatus toConnectionStatus(string s) {
  mixin(EnumSwitch!"ConnectionStatus", "inactive");
}
ConnectionStatus[] toConnectionStatusArray(string[] values) {
  return values.map!(v => toConnectionStatus(v)).array;
}
string toString(ConnectionStatus value) {
  return value.to!string;
}
string[] toStringArray(ConnectionStatus[] values) {
  return values.map!(v => toString(v)).array;
}
///
unittest {
  mixin(ShowTest!"ConnectionStatus");

  assert("active".toConnectionStatus == ConnectionStatus.active);
  assert("inactive".toConnectionStatus == ConnectionStatus.inactive);
  assert("error".toConnectionStatus == ConnectionStatus.error);
  assert("pooled".toConnectionStatus == ConnectionStatus.pooled);

  assert("".toConnectionStatus == ConnectionStatus.inactive);
  assert("unknown".toConnectionStatus == ConnectionStatus.inactive);

  assert(toString(ConnectionStatus.active) == "active");
  assert(toString(ConnectionStatus.inactive) == "inactive");
  assert(toString(ConnectionStatus.error) == "error");
  assert(toString(ConnectionStatus.pooled) == "pooled");

  assert(toConnectionStatusArray(["active", "error", "unknown"]) == [ConnectionStatus.active, ConnectionStatus.error, ConnectionStatus.inactive]);
  assert(toStringArray([ConnectionStatus.active, ConnectionStatus.pooled]) == ["active", "pooled"]);
}
