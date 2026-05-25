module uim.platform.databricks.application.dto;
import uim.platform.databricks;

mixin(ShowModule!());

@safe:

// ─── Workspace DTOs ────────────────────────────────────────────────────────
struct CreateWorkspaceRequest {
  TenantId      tenantId;
  WorkspaceId   id;
  string        name;
  string        region;
  WorkspaceTier tier;
  string        cloudProvider;
  string        storageRoot;
  string        credentialId;
}

struct UpdateWorkspaceRequest {
  TenantId      tenantId;
  WorkspaceId   id;
  string        name;
  WorkspaceTier tier;
  string        storageRoot;
}

// ─── Cluster DTOs ──────────────────────────────────────────────────────────
struct CreateClusterRequest {
  TenantId    tenantId;
  ClusterId   id;
  WorkspaceId workspaceId;
  string      name;
  ClusterType clusterType;
  string      nodeType;
  string      driverNodeType;
  int         numWorkers;
  bool        autoscaleEnabled;
  int         autoscaleMinWorkers;
  int         autoscaleMaxWorkers;
  int         autoTerminationMinutes;
  string      sparkVersion;
  string      runtimeVersion;
  string      creatorId;
}

struct UpdateClusterRequest {
  TenantId  tenantId;
  ClusterId id;
  string    name;
  int       numWorkers;
  bool      autoscaleEnabled;
  int       autoscaleMinWorkers;
  int       autoscaleMaxWorkers;
  int       autoTerminationMinutes;
}

// ─── Notebook DTOs ─────────────────────────────────────────────────────────
struct CreateNotebookRequest {
  TenantId         tenantId;
  NotebookId       id;
  WorkspaceId      workspaceId;
  string           path;
  string           name;
  NotebookLanguage language;
  string           content;
  string           format;
  string           ownerId;
}

struct UpdateNotebookRequest {
  TenantId   tenantId;
  NotebookId id;
  string     name;
  string     content;
  string     format;
}

// ─── Job DTOs ──────────────────────────────────────────────────────────────
struct CreateJobRequest {
  TenantId    tenantId;
  JobId       id;
  WorkspaceId workspaceId;
  string      name;
  string      description;
  string      creatorId;
  string      schedule;
  string      taskType;
  string      taskSettings;
  int         maxRetries;
  int         minRetryIntervalMs;
  int         maxConcurrentRuns;
  string      clusterId;
}

struct UpdateJobRequest {
  TenantId tenantId;
  JobId    id;
  string   name;
  string   description;
  string   schedule;
  string   taskSettings;
  int      maxRetries;
  int      maxConcurrentRuns;
}

// ─── Job Run DTOs ──────────────────────────────────────────────────────────
struct CreateJobRunRequest {
  TenantId    tenantId;
  JobRunId    id;
  JobId       jobId;
  WorkspaceId workspaceId;
  RunTrigger  triggerType;
  string      runType;
  string      clusterId;
}

struct UpdateJobRunRequest {
  TenantId tenantId;
  JobRunId id;
  RunState state;
  string   stateMessage;
  string   resultState;
  long     endTime;
}

// ─── Delta Table DTOs ──────────────────────────────────────────────────────
struct CreateDeltaTableRequest {
  TenantId     tenantId;
  DeltaTableId id;
  WorkspaceId  workspaceId;
  string       catalogName;
  string       schemaName;
  string       tableName;
  TableType    tableType;
  string       storageLocation;
  string       comment;
  string       ownerId;
  string       dataSourceFormat;
}

struct UpdateDeltaTableRequest {
  TenantId     tenantId;
  DeltaTableId id;
  string       comment;
  string       storageLocation;
}

// ─── Data Product DTOs ─────────────────────────────────────────────────────
struct CreateDataProductRequest {
  TenantId      tenantId;
  DataProductId id;
  WorkspaceId   workspaceId;
  string        name;
  string        description;
  string        provider;
  string        version_;
  ShareMode     shareMode;
  string        targetCatalog;
  string        targetSchema;
  string        sourceSystemId;
  string        tags;
}

struct UpdateDataProductRequest {
  TenantId      tenantId;
  DataProductId id;
  string        description;
  string        version_;
  ShareMode     shareMode;
  string        targetCatalog;
  string        targetSchema;
  string        tags;
}

// ─── ML Experiment DTOs ────────────────────────────────────────────────────
struct CreateMlExperimentRequest {
  TenantId       tenantId;
  MlExperimentId id;
  WorkspaceId    workspaceId;
  string         name;
  string         artifactLocation;
  string         ownerId;
  string         tags;
}

struct UpdateMlExperimentRequest {
  TenantId       tenantId;
  MlExperimentId id;
  string         name;
  string         tags;
}

// ─── ML Model DTOs ─────────────────────────────────────────────────────────
struct CreateMlModelRequest {
  TenantId    tenantId;
  MlModelId   id;
  WorkspaceId workspaceId;
  string      name;
  string      description;
  string      ownerId;
  string      source;
  string      tags;
}

struct UpdateMlModelRequest {
  TenantId   tenantId;
  MlModelId  id;
  string     description;
  ModelStage latestStage;
  string     tags;
}

// ─── SQL Warehouse DTOs ────────────────────────────────────────────────────
struct CreateSqlWarehouseRequest {
  TenantId       tenantId;
  SqlWarehouseId id;
  WorkspaceId    workspaceId;
  string         name;
  WarehouseType  warehouseType;
  WarehouseSize  size;
  int            numClusters;
  int            autoStopMinutes;
  bool           enablePhoton;
  bool           enableServerlessCompute;
  string         creatorId;
}

struct UpdateSqlWarehouseRequest {
  TenantId       tenantId;
  SqlWarehouseId id;
  string         name;
  WarehouseSize  size;
  int            numClusters;
  int            autoStopMinutes;
  bool           enablePhoton;
}

// ─── Generic result wrapper ────────────────────────────────────────────────
struct UseCaseResult(T) {
  bool   success;
  string message;
  T      data;
}
