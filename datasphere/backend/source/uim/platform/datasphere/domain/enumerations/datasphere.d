/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business enumerations and status values. All enumerations are string
/// valued: the value is what the APIs accept and return.
module uim.platform.datasphere.domain.enumerations.datasphere;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

// ── spaces ──────────────────────────────────────────────────────────────────

enum SpaceStatus : string {
  active = "active",
  locked = "locked" /// over its disk quota or locked by an administrator: no runs, no new objects
}

/// Role of a member in a space (SAP Datasphere scoped roles).
enum SpaceRole : string {
  viewer = "viewer", /// reads the objects of the space
  modeler = "modeler", /// builds views, data flows and catalog entries
  integrator = "integrator", /// maintains connections and remote tables, runs tasks
  administrator = "administrator" /// manages the space and its members
}

// ── connections and remote tables ───────────────────────────────────────────

enum ConnectionType : string {
  hana = "hana", /// SAP HANA (on premise or Cloud)
  s4hana = "s4hana", /// SAP S/4HANA (Cloud)
  bw = "bw", /// SAP BW/4HANA
  hdl = "hdl", /// SAP HANA Cloud, data lake files
  odata = "odata", /// generic OData service
  sql = "sql", /// generic JDBC / SQL database
  abap = "abap", /// SAP ABAP system (CDS views, ODP)
  kafka = "kafka", /// Apache Kafka (streaming)
  file = "file", /// object store files (S3, ADLS, GCS)
  other = "other"
}

/// Connection types that need host and port.
bool needsEndpoint(ConnectionType t) pure {
  return t != ConnectionType.file && t != ConnectionType.other;
}

/// Connection types whose remote objects can be replicated in real time.
bool supportsRealtime(ConnectionType t) pure {
  return t == ConnectionType.hana || t == ConnectionType.s4hana || t == ConnectionType.abap || t == ConnectionType.kafka;
}

enum ConnectionStatus : string {
  untested = "untested", /// created or changed, not validated yet
  valid = "valid",
  invalid = "invalid" /// the last validation failed (see statusMessage)
}

/// How a remote table accesses its remote object.
enum ReplicationMode : string {
  remote = "remote", /// federated access, no data in the space
  snapshot = "snapshot", /// one-time copy on demand
  scheduled = "scheduled", /// copy by a replication task
  realtime = "realtime" /// change data capture
}

enum ReplicationStatus : string {
  notReplicated = "notReplicated",
  replicated = "replicated", /// a snapshot is available
  active = "active", /// real-time replication running
  failed = "failed"
}

// ── modeling ────────────────────────────────────────────────────────────────

/// Design-time state of views and data flows.
enum DeploymentStatus : string {
  notDeployed = "notDeployed",
  deployed = "deployed",
  changesToDeploy = "changesToDeploy" /// deployed, then changed
}

/// Semantic usage of a view.
enum ViewSemantic : string {
  relationalDataset = "relationalDataset",
  analyticalDataset = "analyticalDataset", /// consumable by SAP Analytics Cloud
  fact = "fact",
  dimension = "dimension",
  text = "text",
  hierarchy = "hierarchy"
}

/// Load behaviour of a data flow target.
enum LoadMode : string {
  append = "append",
  truncate = "truncate", /// delete the target before loading
  upsert = "upsert"
}

// ── scheduling and runs ─────────────────────────────────────────────────────

/// What a task runs.
enum TaskType : string {
  replication = "replication", /// snapshot of a remote table
  dataFlow = "dataFlow", /// run of a data flow
  viewPersistence = "viewPersistence" /// persist (materialise) a view
}

enum ScheduleFrequency : string {
  manual = "manual", /// only on demand
  interval = "interval", /// every intervalMinutes
  hourly = "hourly",
  daily = "daily",
  weekly = "weekly",
  monthly = "monthly"
}

/// Schedule state of a task or task chain.
enum ScheduleStatus : string {
  active = "active",
  paused = "paused" /// the schedule does not fire; manual runs are possible
}

/// What to do when a step of a task chain fails.
enum FailurePolicy : string {
  stop = "stop",
  continue_ = "continue"
}

/// Outcome of a run (and last-run state of runnable objects).
enum RunStatus : string {
  notRun = "notRun",
  running = "running",
  completed = "completed",
  failed = "failed",
  cancelled = "cancelled" /// skipped step of a stopped task chain
}

/// Kind of object a run belongs to.
enum RunObjectType : string {
  replication = "replication",
  dataFlow = "dataFlow",
  viewPersistence = "viewPersistence",
  taskChain = "taskChain"
}

/// How a run was started.
enum RunTrigger : string {
  manual = "manual",
  schedule = "schedule",
  chain = "chain"
}

// ── governance ──────────────────────────────────────────────────────────────

/// Row level criteria of a data access control.
enum CriteriaOperator : string {
  equals = "equals",
  oneOf = "oneOf", /// any of the values
  startsWith = "startsWith",
  between = "between" /// two values: low, high (text or numbers)
}

enum AssetType : string {
  table = "table",
  view = "view",
  remoteTable = "remoteTable",
  dataFlow = "dataFlow",
  analyticModel = "analyticModel",
  connection = "connection",
  other = "other"
}

enum QualityStatus : string {
  unknown = "unknown",
  poor = "poor",
  adequate = "adequate",
  good = "good",
  excellent = "excellent"
}

enum Sensitivity : string {
  public_ = "public",
  internal = "internal",
  confidential = "confidential",
  restricted = "restricted"
}

///
unittest {
  assert(needsEndpoint(ConnectionType.hana) && !needsEndpoint(ConnectionType.file));
  assert(supportsRealtime(ConnectionType.s4hana) && !supportsRealtime(ConnectionType.odata));
  assert(cast(string) FailurePolicy.continue_ == "continue" && cast(string) Sensitivity.public_ == "public");
}
