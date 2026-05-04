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

  Json toJson() const {
    return Json.emptyObject.set("tenantId", tenantId.value)
      .set("id", id)
      .set("name", name)
      .set("description", description)
      .set("type", type)
      .set("size", size)
      .set("version", version_)
      .set("region", region)
      .set("availabilityZone", availabilityZone)
      .set("memoryGB", memoryGB)
      .set("vcpus", vcpus)
      .set("storageGB", storageGB)
      .set("enableScriptServer", enableScriptServer)
      .set("enableDocStore", enableDocStore)
      .set("enableDataLake", enableDataLake)
      .set("allowAllIpAccess", allowAllIpAccess)
      .set("whitelistedIps", whitelistedIps)
      .set("labels", labels);
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

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("name", name)
        .set("description", description)
        .set("size", size)
        .set("memoryGB", memoryGB)
        .set("vcpus", vcpus)
        .set("storageGB", storageGB)
        .set("enableScriptServer", enableScriptServer)
        .set("enableDocStore", enableDocStore)
        .set("allowAllIpAccess", allowAllIpAccess)
        .set("whitelistedIps", whitelistedIps);
    }
  }

  struct InstanceActionRequest {
    TenantId tenantId;
    string id;
    string action;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("action", action);
    }
  }

  // --- Data Lake ---

  struct CreateDataLakeRequest {
    TenantId tenantId;
    InstanceId instanceId;
    string id;
    string name;
    string description;
    int computeNodes;
    string[][] storage;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("instanceId", instanceId)
        .set("id", id)
        .set("name", name)
        .set("description", description)
        .set("computeNodes", computeNodes)
        .set("storage", storage);
    }
  }

  struct UpdateDataLakeRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    int computeNodes;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("name", name)
        .set("description", description)
        .set("computeNodes", computeNodes);
    }

  }

  // --- Schema ---

  struct CreateSchemaRequest {
    TenantId tenantId;
    InstanceId instanceId;
    string id;
    string name;
    string owner;
    string type;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("instanceId", instanceId)
        .set("id", id)
        .set("name", name)
        .set("owner", owner)
        .set("type", type);
    }
  }

  struct UpdateSchemaRequest {
    TenantId tenantId;
    string id;
    string owner;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("owner", owner);
    }
  }

  // --- Database User ---

  struct CreateDatabaseUserRequest {
    TenantId tenantId;
    InstanceId instanceId;
    string id;
    string userName;
    string password;
    string authType;
    string defaultSchema;
    bool isRestricted;
    bool forcePasswordChange;
    string[] roles;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("instanceId", instanceId)
        .set("id", id)
        .set("userName", userName)
        .set("password", password)
        .set("authType", authType)
        .set("defaultSchema", defaultSchema)
        .set("isRestricted", isRestricted)
        .set("forcePasswordChange", forcePasswordChange)
        .set("roles", roles);
    }
  }

  struct UpdateDatabaseUserRequest {
    TenantId tenantId;
    string id;
    string password;
    string defaultSchema;
    bool isRestricted;
    bool forcePasswordChange;
    string[] roles;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("password", password)
        .set("defaultSchema", defaultSchema)
        .set("isRestricted", isRestricted)
        .set("forcePasswordChange", forcePasswordChange)
        .set("roles", roles);
    }
  }

  // --- Backup ---

  struct CreateBackupRequest {
    TenantId tenantId;
    InstanceId instanceId;
    string id;
    string name;
    string type;
    string destination;
    bool encrypted;
    string cronExpression;
    int retentionDays;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("instanceId", instanceId)
        .set("id", id)
        .set("name", name)
        .set("type", type)
        .set("destination", destination)
        .set("encrypted", encrypted)
        .set("cronExpression", cronExpression)
        .set("retentionDays", retentionDays);
    }
  }

  struct UpdateBackupRequest {
    TenantId tenantId;
    string id;
    string name;
    string destination;
    string cronExpression;
    int retentionDays;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("name", name)
        .set("destination", destination)
        .set("cronExpression", cronExpression)
        .set("retentionDays", retentionDays);
    }
  }

  // --- Alert ---

  struct CreateAlertRequest {
    TenantId tenantId;
    InstanceId instanceId;
    string id;
    string name;
    string description;
    string severity;
    string category;
    string metricName;
    double warningValue;
    double criticalValue;
    string unit;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("instanceId", instanceId)
        .set("id", id)
        .set("name", name)
        .set("description", description)
        .set("severity", severity)
        .set("category", category)
        .set("metricName", metricName)
        .set("warningValue", warningValue)
        .set("criticalValue", criticalValue)
        .set("unit", unit);
    }
  }

  struct UpdateAlertRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string severity;
    double warningValue;
    double criticalValue;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("name", name)
        .set("description", description)
        .set("severity", severity)
        .set("warningValue", warningValue)
        .set("criticalValue", criticalValue);
    }
  }

  struct AcknowledgeAlertRequest {
    TenantId tenantId;
    string id;
    UserId acknowledgedBy;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("acknowledgedBy", acknowledgedBy);
    }
  }

  // --- HDI Container ---

  struct CreateHDIContainerRequest {
    TenantId tenantId;
    InstanceId instanceId;
    string id;
    string name;
    string description;
    string appUser;
    string[] grantedSchemas;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("instanceId", instanceId)
        .set("id", id)
        .set("name", name)
        .set("description", description)
        .set("appUser", appUser)
        .set("grantedSchemas", grantedSchemas);
    }
  }

  struct UpdateHDIContainerRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string[] grantedSchemas;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("name", name)
        .set("description", description)
        .set("grantedSchemas", grantedSchemas);
    }
  }

  // --- Replication Task ---

  struct CreateReplicationTaskRequest {
    TenantId tenantId;
    InstanceId instanceId;
    string id;
    string name;
    string description;
    string mode;
    string sourceConnectionId;
    string targetConnectionId;
    string scheduleExpression;
    string[][] mappings;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("instanceId", instanceId)
        .set("id", id)
        .set("name", name)
        .set("description", description)
        .set("mode", mode)
        .set("sourceConnectionId", sourceConnectionId)
        .set("targetConnectionId", targetConnectionId)
        .set("scheduleExpression", scheduleExpression)
        .set("mappings", mappings);
    }
  }

  struct UpdateReplicationTaskRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string mode;
    string scheduleExpression;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("name", name)
        .set("description", description)
        .set("mode", mode)
        .set("scheduleExpression", scheduleExpression);
    }
  }

  // --- Configuration ---

  struct CreateConfigurationRequest {
    TenantId tenantId;
    InstanceId instanceId;
    ConfigurationId id;
    string section;
    string key;
    string value;
    string scope_;
    string dataType;
    string description;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("instanceId", instanceId)
        .set("id", id)
        .set("section", section)
        .set("key", key)
        .set("value", value)
        .set("scope_", scope_)
        .set("dataType", dataType)
        .set("description", description);
    }
  }

  struct UpdateConfigurationRequest {
    TenantId tenantId;
    ConfigurationId id;
    string value;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("value", value);
    }
  }

  // --- Database Connection ---

  struct CreateDatabaseConnectionRequest {
    TenantId tenantId;
    InstanceId instanceId;
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

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("instanceId", instanceId)
        .set("id", id)
        .set("name", name)
        .set("description", description)
        .set("type", type)
        .set("host", host)
        .set("port", port)
        .set("database", database)
        .set("user", user)
        .set("password", password)
        .set("useTls", useTls)
        .set("minConnections", minConnections)
        .set("maxConnections", maxConnections)
        .set("properties", properties);
    }
  }

  struct UpdateDatabaseConnectionRequest {
    TenantId tenantId;
    InstanceId instanceId;
    DatabaseConnectionId id;
    string name;
    string description;
    string host;
    int port;
    string database;
    string user;
    string password;

    Json toJson() const {
      return Json.emptyObject
        .set("tenantId", tenantId.value)
        .set("id", id)
        .set("name", name)
        .set("description", description)
        .set("host", host)
        .set("port", port)
        .set("database", database)
        .set("user", user)
        .set("password", password);
    }
  }
