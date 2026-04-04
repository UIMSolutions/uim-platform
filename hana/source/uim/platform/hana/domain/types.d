/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.domain.types;

// ID aliases
alias InstanceId = string;
alias DataLakeId = string;
alias SchemaId = string;
alias DatabaseUserId = string;
alias BackupId = string;
alias AlertId = string;
alias HDIContainerId = string;
alias ReplicationTaskId = string;
alias ConfigurationId = string;
alias DatabaseConnectionId = string;
alias TenantId = string;

// Database instance type
enum InstanceType {
  hana,
  hanaExpress,
  hanaCloud,
  trial,
  free,
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

// Data lake storage tier
enum StorageTier {
  hot,
  warm,
  cold,
}

// Data lake status
enum DataLakeStatus {
  creating,
  running,
  stopped,
  error,
  deleting,
}

// Data lake file format
enum FileFormat {
  parquet,
  csv,
  orc,
  json,
  avro,
}

// Schema type
enum SchemaType {
  standard,
  hdi,
  virtual,
  system,
  temporary,
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

// Database user status
enum UserStatus {
  active,
  deactivated,
  locked,
  expired,
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

// Backup type
enum BackupType {
  full,
  incremental,
  differential,
  log,
  snapshot,
}

// Backup status
enum BackupStatus {
  scheduled,
  running,
  completed,
  failed,
  cancelled,
}

// Alert severity
enum AlertSeverity {
  info,
  warning,
  error,
  critical,
}

// Alert status
enum AlertStatus {
  active,
  acknowledged,
  resolved,
  suppressed,
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

// HDI container status
enum HDIContainerStatus {
  creating,
  active,
  inactive,
  error,
  deleting,
}

// Replication mode
enum ReplicationMode {
  none,
  realtime,
  scheduled,
  snapshot,
  logBased,
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

// Configuration scope
enum ConfigScope {
  system,
  database,
  tenant,
  session,
}

// Configuration data type
enum ConfigDataType {
  string_,
  integer,
  boolean_,
  decimal,
  duration,
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

// Connection status
enum ConnectionStatus {
  active,
  inactive,
  error,
  pooled,
}
