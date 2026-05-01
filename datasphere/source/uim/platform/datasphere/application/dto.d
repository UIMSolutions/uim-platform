/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.dto;

import uim.platform.datasphere;
mixin(ShowModule!());
@safe:

// --- Space ---

struct CreateSpaceRequest {
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  string businessName;
  int priority;
  string[][] members;
  string[][] labels;
}

struct UpdateSpaceRequest {
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  string businessName;
  int priority;
}

// --- Connection ---

struct CreateConnectionRequest {
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  string type;
  string host;
  int port;
  string database;
  string user;
  string password;
  string[][] properties;
}

struct UpdateConnectionRequest {
  TenantId tenantId;
  SpaceId spaceId;
  ConnectionId connectionId;
  string name;
  string description;
  string host;
  int port;
  string database;
  string user;
  string password;
}

// --- Remote Table ---

struct CreateRemoteTableRequest {
  TenantId tenantId;
  SpaceId spaceId;
  ConnectionId connectionId;
  string name;
  string description;
  string remoteSchema;
  string remoteObjectName;
  string replicationMode;
  string replicationSchedule;
}

struct UpdateRemoteTableRequest {
  TenantId tenantId;
  SpaceId spaceId;
  RemoteTableId remoteTableId;
  string replicationMode;
  string replicationSchedule;
}

// --- Data Flow ---

struct CreateDataFlowRequest {
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  string scheduleExpression;
  string scheduleFrequency;
}

struct PatchDataFlowRequest {
  TenantId tenantId;
  SpaceId spaceId;
  DataFlowId dataFlowId;
  string targetStatus;
}

// --- View ---

struct CreateViewRequest {
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  string businessName;
  string semantic;
  string sqlExpression;
  bool isExposed;
}

struct UpdateViewRequest {
  TenantId tenantId;
  SpaceId spaceId;
  ViewId viewId;
  string name;
  string description;
  string businessName;
  string sqlExpression;
  bool isExposed;
  bool isPersisted;
}

// --- DSTask ---

struct CreateTaskRequest {
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  string type;
  string targetObjectId;
  string scheduleExpression;
  string scheduleFrequency;
  int maxRetries;
}

struct PatchTaskRequest {
  TenantId tenantId;
  SpaceId spaceId;
  TaskId taskId;
  string targetStatus;
}

// --- Task Chain ---

struct CreateTaskChainRequest {
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  string scheduleExpression;
  string scheduleFrequency;
  string[][] steps;
}

struct PatchTaskChainRequest {
  TenantId tenantId;
  SpaceId spaceId;
  TaskChainId taskChainId;
  string targetStatus;
}

// --- Data Access Control ---

struct CreateDataAccessControlRequest {
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  string criteriaType;
  ViewId[] targetViewIds;
  UserId[] assignedUserIds;
}

struct UpdateDataAccessControlRequest {
  TenantId tenantId;
  SpaceId spaceId;
  DataAccessControlId controlId;
  string name;
  string description;
  ViewId[] targetViewIds;
  UserId[] assignedUserIds;
  bool isEnabled;
}

// --- Catalog Asset ---

struct CreateCatalogAssetRequest {
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  string businessName;
  string assetType;
  string sourceObjectId;
  string owner;
  string[][] tags;
  string[] glossaryTerms;
}

struct UpdateCatalogAssetRequest {
  TenantId tenantId;
  SpaceId spaceId;
  string assetId;
  string name;
  string description;
  string businessName;
  string qualityStatus;
  string owner;
  string[][] tags;
  string[] glossaryTerms;
}
