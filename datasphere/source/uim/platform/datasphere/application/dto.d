/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.dto;

import uim.platform.datasphere.domain.types;

// --- Generic result ---

struct CommandResult {
  bool success;
  string id;
  string error;
}

// --- Space ---

struct CreateSpaceRequest {
  string tenantId;
  string id;
  string name;
  string description;
  string businessName;
  int priority;
  string[][] members;
  string[][] labels;
}

struct UpdateSpaceRequest {
  string tenantId;
  string id;
  string name;
  string description;
  string businessName;
  int priority;
}

// --- Connection ---

struct CreateConnectionRequest {
  string tenantId;
  string spaceId;
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
  string tenantId;
  string spaceId;
  string connectionId;
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
  string tenantId;
  string spaceId;
  string connectionId;
  string name;
  string description;
  string remoteSchema;
  string remoteObjectName;
  string replicationMode;
  string replicationSchedule;
}

struct UpdateRemoteTableRequest {
  string tenantId;
  string spaceId;
  string remoteTableId;
  string replicationMode;
  string replicationSchedule;
}

// --- Data Flow ---

struct CreateDataFlowRequest {
  string tenantId;
  string spaceId;
  string name;
  string description;
  string scheduleExpression;
  string scheduleFrequency;
}

struct PatchDataFlowRequest {
  string tenantId;
  string spaceId;
  string dataFlowId;
  string targetStatus;
}

// --- View ---

struct CreateViewRequest {
  string tenantId;
  string spaceId;
  string name;
  string description;
  string businessName;
  string semantic;
  string sqlExpression;
  bool isExposed;
}

struct UpdateViewRequest {
  string tenantId;
  string spaceId;
  string viewId;
  string name;
  string description;
  string businessName;
  string sqlExpression;
  bool isExposed;
  bool isPersisted;
}

// --- Task ---

struct CreateTaskRequest {
  string tenantId;
  string spaceId;
  string name;
  string description;
  string type;
  string targetObjectId;
  string scheduleExpression;
  string scheduleFrequency;
  int maxRetries;
}

struct PatchTaskRequest {
  string tenantId;
  string spaceId;
  string taskId;
  string targetStatus;
}

// --- Task Chain ---

struct CreateTaskChainRequest {
  string tenantId;
  string spaceId;
  string name;
  string description;
  string scheduleExpression;
  string scheduleFrequency;
  string[][] steps;
}

struct PatchTaskChainRequest {
  string tenantId;
  string spaceId;
  string taskChainId;
  string targetStatus;
}

// --- Data Access Control ---

struct CreateDataAccessControlRequest {
  string tenantId;
  string spaceId;
  string name;
  string description;
  string criteriaType;
  string[] targetViewIds;
  string[] assignedUserIds;
}

struct UpdateDataAccessControlRequest {
  string tenantId;
  string spaceId;
  string controlId;
  string name;
  string description;
  string[] targetViewIds;
  string[] assignedUserIds;
  bool isEnabled;
}

// --- Catalog Asset ---

struct CreateCatalogAssetRequest {
  string tenantId;
  string spaceId;
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
  string tenantId;
  string spaceId;
  string assetId;
  string name;
  string description;
  string businessName;
  string qualityStatus;
  string owner;
  string[][] tags;
  string[] glossaryTerms;
}
