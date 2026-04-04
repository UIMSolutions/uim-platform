/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.types;

// ID aliases
alias SpaceId = string;
alias ConnectionId = string;
alias RemoteTableId = string;
alias DataFlowId = string;
alias ViewId = string;
alias TaskId = string;
alias TaskChainId = string;
alias DataAccessControlId = string;
alias CatalogAssetId = string;
alias TenantId = string;

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

// Space storage allocation
enum StorageType {
  inMemory,
  disk,
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

// Remote table replication mode
enum ReplicationMode {
  none,
  realtime,
  scheduled,
  snapshot,
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

// Task execution status
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
