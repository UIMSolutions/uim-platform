/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.dto;

import uim.platform.hana;

// --- Database Instance ---

struct CreateInstanceRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string type;
  string size;
  string version_;
  string region;
  string availabilityZone;
  long memoryGB;
  int vcpus;
  long storageGB;
  bool enableScriptServer;
  bool enableDocStore;
  bool enableDataLake;
  bool allowAllIpAccess;
  string[] whitelistedIps;
  string[][] labels;
}

struct UpdateInstanceRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string size;
  long memoryGB;
  int vcpus;
  long storageGB;
  bool enableScriptServer;
  bool enableDocStore;
  bool allowAllIpAccess;
  string[] whitelistedIps;
}

struct InstanceActionRequest {
  TenantId tenantId;
  string id;
  string action;
}

// --- Data Lake ---

struct CreateDataLakeRequest {
  TenantId tenantId;
  string instanceId;
  string id;
  string name;
  string description;
  int computeNodes;
  string[][] storage;
}

struct UpdateDataLakeRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  int computeNodes;
}

// --- Schema ---

struct CreateSchemaRequest {
  TenantId tenantId;
  string instanceId;
  string id;
  string name;
  string owner;
  string type;
}

struct UpdateSchemaRequest {
  TenantId tenantId;
  string id;
  string owner;
}

// --- Database User ---

struct CreateDatabaseUserRequest {
  TenantId tenantId;
  string instanceId;
  string id;
  string userName;
  string password;
  string authType;
  string defaultSchema;
  bool isRestricted;
  bool forcePasswordChange;
  string[] roles;
}

struct UpdateDatabaseUserRequest {
  TenantId tenantId;
  string id;
  string password;
  string defaultSchema;
  bool isRestricted;
  bool forcePasswordChange;
  string[] roles;
}

// --- Backup ---

struct CreateBackupRequest {
  TenantId tenantId;
  string instanceId;
  string id;
  string name;
  string type;
  string destination;
  bool encrypted;
  string cronExpression;
  int retentionDays;
}

struct UpdateBackupRequest {
  TenantId tenantId;
  string id;
  string name;
  string destination;
  string cronExpression;
  int retentionDays;
}

// --- Alert ---

struct CreateAlertRequest {
  TenantId tenantId;
  string instanceId;
  string id;
  string name;
  string description;
  string severity;
  string category;
  string metricName;
  double warningValue;
  double criticalValue;
  string unit;
}

struct UpdateAlertRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string severity;
  double warningValue;
  double criticalValue;
}

struct AcknowledgeAlertRequest {
  TenantId tenantId;
  string id;
  string acknowledgedBy;
}

// --- HDI Container ---

struct CreateHDIContainerRequest {
  TenantId tenantId;
  string instanceId;
  string id;
  string name;
  string description;
  string appUser;
  string[] grantedSchemas;
}

struct UpdateHDIContainerRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string[] grantedSchemas;
}

// --- Replication Task ---

struct CreateReplicationTaskRequest {
  TenantId tenantId;
  string instanceId;
  string id;
  string name;
  string description;
  string mode;
  string sourceConnectionId;
  string targetConnectionId;
  string scheduleExpression;
  string[][] mappings;
}

struct UpdateReplicationTaskRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string mode;
  string scheduleExpression;
}

// --- Configuration ---

struct CreateConfigurationRequest {
  TenantId tenantId;
  string instanceId;
  string id;
  string section;
  string key;
  string value;
  string scope_;
  string dataType;
  string description;
}

struct UpdateConfigurationRequest {
  TenantId tenantId;
  string id;
  string value;
}

// --- Database Connection ---

struct CreateDatabaseConnectionRequest {
  TenantId tenantId;
  string instanceId;
  string id;
  string name;
  string description;
  string type;
  string host;
  int port;
  string database;
  string user;
  string password;
  bool useTls;
  int minConnections;
  int maxConnections;
  string[][] properties;
}

struct UpdateDatabaseConnectionRequest {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string host;
  int port;
  string database;
  string user;
  string password;
}
