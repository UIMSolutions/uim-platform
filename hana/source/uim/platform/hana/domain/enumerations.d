/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.enumerations;

import uim.platform.hana;

// mixin(ShowModule!());

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
  const map = [
    "hana": InstanceType.hana,
    "hana_express": InstanceType.hanaExpress,
    "hana_cloud": InstanceType.hanaCloud,
    "trial": InstanceType.trial,
    "free": InstanceType.free
  ];
  return map.get(s.toLower, InstanceType.hana);
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
InstanceStatus toInstanceStatus(string s) {
  const map = [
    "creating": InstanceStatus.creating,
    "running": InstanceStatus.running,
    "stopped": InstanceStatus.stopped,
    "starting": InstanceStatus.starting,
    "stopping": InstanceStatus.stopping,
    "updating": InstanceStatus.updating,
    "deleting": InstanceStatus.deleting,
    "error": InstanceStatus.error,
    "suspended": InstanceStatus.suspended
  ];
  return map.get(s.toLower, InstanceStatus.error);
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
InstanceSize toInstanceSize(string s) {
  const map = [
    "xs": InstanceSize.xs,
    "s": InstanceSize.s,
    "m": InstanceSize.m,
    "l": InstanceSize.l,
    "xl": InstanceSize.xl,
    "xxl": InstanceSize.xxl,
    "custom": InstanceSize.custom
  ];
  return map.get(s.toLower, InstanceSize.m);
}

// Data lake storage tier
enum StorageTier {
  hot,
  warm,
  cold,
}
StorageTier toStorageTier(string s) {
  const map = [
    "hot": StorageTier.hot,
    "warm": StorageTier.warm,
    "cold": StorageTier.cold
  ];
  return map.get(s.toLower, StorageTier.warm);
} 

// Data lake status
enum DataLakeStatus {
  creating,
  running,
  stopped,
  error,
  deleting,
}
DataLakeStatus toDataLakeStatus(string s) {
  const map = [
    "creating": DataLakeStatus.creating,
    "running": DataLakeStatus.running,
    "stopped": DataLakeStatus.stopped,
    "error": DataLakeStatus.error,
    "deleting": DataLakeStatus.deleting
  ];
  return map.get(s.toLower, DataLakeStatus.error);
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
  const map = [
    "parquet": FileFormat.parquet,
    "csv": FileFormat.csv,
    "orc": FileFormat.orc,
    "json": FileFormat.json,
    "avro": FileFormat.avro
  ];
  return map.get(s.toLower, FileFormat.parquet);
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
  const map = [
    "standard": SchemaType.standard,
    "hdi": SchemaType.hdi,
    "virtual": SchemaType.virtual,
    "system": SchemaType.system,
    "temporary": SchemaType.temporary
  ];
  return map.get(s.toLower, SchemaType.standard);
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
  const map = [
    "password": AuthType.password,
    "kerberos": AuthType.kerberos,
    "saml": AuthType.saml,
    "x509": AuthType.x509,
    "jwt": AuthType.jwt,
    "ldap": AuthType.ldap
  ];
  return map.get(s.toLower, AuthType.password);
}

// Database user status
enum UserStatus {
  active,
  deactivated,
  locked,
  expired,
}
UserStatus toUserStatus(string s) {
  const map = [
    "active": UserStatus.active,
    "deactivated": UserStatus.deactivated,
    "locked": UserStatus.locked,
    "expired": UserStatus.expired
  ];
  return map.get(s.toLower, UserStatus.active);
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
  const map = [
    "system": PrivilegeType.system,
    "object": PrivilegeType.object_,
    "analytic": PrivilegeType.analytic,
    "package": PrivilegeType.package_,
    "application": PrivilegeType.application,
    "role": PrivilegeType.role
  ];
  return map.get(s.toLower, PrivilegeType.system);
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
  const map = [
    "full": BackupType.full,
    "incremental": BackupType.incremental,
    "differential": BackupType.differential,
    "log": BackupType.log,
    "snapshot": BackupType.snapshot
  ];
  return map.get(s.toLower, BackupType.full);
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
  const map = [
    "scheduled": BackupStatus.scheduled,
    "running": BackupStatus.running,
    "completed": BackupStatus.completed,
    "failed": BackupStatus.failed,
    "cancelled": BackupStatus.cancelled
  ];
  return map.get(s.toLower, BackupStatus.scheduled);
}

// Alert status
enum AlertStatus {
  active,
  acknowledged,
  resolved,
  suppressed,
}
AlertStatus toAlertStatus(string s) {
  const map = [
    "active": AlertStatus.active,
    "acknowledged": AlertStatus.acknowledged,
    "resolved": AlertStatus.resolved,
    "suppressed": AlertStatus.suppressed
  ];
  return map.get(s.toLower, AlertStatus.active);
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
  const map = [
    "performance": AlertCategory.performance,
    "availability": AlertCategory.availability,
    "storage": AlertCategory.storage,
    "memory": AlertCategory.memory,
    "cpu": AlertCategory.cpu,
    "replication": AlertCategory.replication,
    "backup": AlertCategory.backup,
    "security": AlertCategory.security,
    "configuration": AlertCategory.configuration
  ];
  return map.get(s.toLower, AlertCategory.performance);
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
  const map = [
    "creating": HDIContainerStatus.creating,
    "active": HDIContainerStatus.active,
    "inactive": HDIContainerStatus.inactive,
    "error": HDIContainerStatus.error,
    "deleting": HDIContainerStatus.deleting
  ];
  return map.get(s.toLower, HDIContainerStatus.error);
}

// Replication mode
enum ReplicationMode {
  none,
  realtime,
  scheduled,
  snapshot,
  logBased,
}
ReplicationMode toReplicationMode(string s) {
  const map = [
    "none": ReplicationMode.none,
    "realtime": ReplicationMode.realtime,
    "scheduled": ReplicationMode.scheduled,
    "snapshot": ReplicationMode.snapshot,
    "logbased": ReplicationMode.logBased
  ];
  return map.get(s.toLower, ReplicationMode.none);
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
ReplicationTaskStatus toReplicationTaskStatus(string s) {
  const map = [
    "active": ReplicationTaskStatus.active,
    "inactive": ReplicationTaskStatus.inactive,
    "running": ReplicationTaskStatus.running,
    "completed": ReplicationTaskStatus.completed,
    "failed": ReplicationTaskStatus.failed,
    "paused": ReplicationTaskStatus.paused
  ];
  return map.get(s.toLower, ReplicationTaskStatus.inactive);
}

// Configuration scope
enum ConfigScope {
  system,
  database,
  tenant,
  session,
}
ConfigScope toConfigScope(string s) {
  const map = [
    "system": ConfigScope.system,
    "database": ConfigScope.database,
    "tenant": ConfigScope.tenant,
    "session": ConfigScope.session
  ];
  return map.get(s.toLower, ConfigScope.system);
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
  const map = [
    "string": ConfigDataType.string_,
    "integer": ConfigDataType.integer,
    "boolean": ConfigDataType.boolean_,
    "decimal": ConfigDataType.decimal,
    "duration": ConfigDataType.duration
  ];
  return map.get(s.toLower, ConfigDataType.string_);
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
ConnectionType toConnectionType(string s) {
  const map = [
    "jdbc": ConnectionType.jdbc,
    "odbc": ConnectionType.odbc,
    "hdbsql": ConnectionType.hdbsql,
    "nodejs": ConnectionType.nodeJs,
    "python": ConnectionType.python,
    "java": ConnectionType.java,
    "go": ConnectionType.go,
    "dotnet": ConnectionType.dotnet
  ];
  return map.get(s.toLower, ConnectionType.jdbc);
} 

// Connection status
enum ConnectionStatus {
  active,
  inactive,
  error,
  pooled,
}
ConnectionStatus toConnectionStatus(string s) {
  const map = [
    "active": ConnectionStatus.active,
    "inactive": ConnectionStatus.inactive,
    "error": ConnectionStatus.error,
    "pooled": ConnectionStatus.pooled
  ];
  return map.get(s.toLower, ConnectionStatus.inactive);
}
