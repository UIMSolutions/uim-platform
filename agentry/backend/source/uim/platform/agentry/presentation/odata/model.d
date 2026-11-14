/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// EDM model of the Agentry OData v4 service.
module uim.platform.agentry.presentation.odata.model;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Primitive EDM types used by the service.
enum Edm : string {
  string_ = "Edm.String",
  int32 = "Edm.Int32",
  int64 = "Edm.Int64",
  boolean = "Edm.Boolean",
  dateTimeOffset = "Edm.DateTimeOffset",
}

/// A structural property of an entity or complex type.
struct ODataPropertyDef {
  string name;
  string type; /// Edm.* or a qualified complex type name
  bool nullable = true;
  bool collection;
  string label; /// Common.Label for Fiori

  string edmType() const {
    return collection ? "Collection(" ~ type ~ ")" : type;
  }
}

/// A complex type (no key).
struct ODataComplexTypeDef {
  string name;
  ODataPropertyDef[] properties;
}

/// Entity type + entity set (1:1 in this service).
struct ODataEntitySetDef {
  string name; /// entity set name, e.g. "Devices"
  string entityType; /// entity type name, e.g. "Device"
  string key = "id";
  ODataPropertyDef[] properties;
  bool insertable;
  bool updatable;
  bool deletable;
  bool singleton; /// exposed as <Singleton> instead of <EntitySet>

  bool hasProperty(string propertyName) const {
    return properties.any!(p => p.name == propertyName);
  }

  /// Names of the properties with the given EDM type.
  string[] propertiesOfType(string edmType) const {
    string[] names;
    foreach (p; properties)
      if (p.type == edmType)
        names ~= p.name;
    return names;
  }
}

/// An unbound action (POST <service>/<Name> with a JSON parameter object).
struct ODataActionDef {
  string name;
  ODataPropertyDef[] parameters;
  string returnType; /// qualified type name ("" = no return value)
  string returnEntitySet; /// entity set of the returned entity (ActionImport EntitySet)
}

/// The whole EDM model of a service.
class ODataServiceModel {
  string namespace_;
  string containerName;
  ODataEntitySetDef[] entitySets;
  ODataComplexTypeDef[] complexTypes;
  ODataActionDef[] actions;

  this(string namespace_, string containerName) {
    this.namespace_ = namespace_;
    this.containerName = containerName;
  }

  /// True if an entity set or singleton with this name exists.
  bool has(string name) const {
    return entitySets.any!(s => s.name == name);
  }

  /// The entity set or singleton with this name (ODataEntitySetDef.init if unknown).
  const(ODataEntitySetDef) find(string name) const {
    foreach (s; entitySets)
      if (s.name == name)
        return s;
    return ODataEntitySetDef.init;
  }

  bool hasAction(string name) const {
    return actions.any!(a => a.name == name);
  }

  const(ODataActionDef) findAction(string name) const {
    foreach (a; actions)
      if (a.name == name)
        return a;
    return ODataActionDef.init;
  }

  string qualified(string typeName) const {
    return namespace_ ~ "." ~ typeName;
  }
}

private ODataPropertyDef p(string name, Edm type, string label, bool nullable = true) {
  return ODataPropertyDef(name, cast(string) type, nullable, false, label);
}

private ODataPropertyDef[] tenantEntityProperties() {
  return [
    p("id", Edm.string_, "ID", false),
    p("tenantId", Edm.string_, "Tenant"),
    p("createdBy", Edm.string_, "Created By"),
    p("createdAt", Edm.dateTimeOffset, "Created At"),
    p("updatedBy", Edm.string_, "Changed By"),
    p("updatedAt", Edm.dateTimeOffset, "Changed At"),
  ];
}

/// Namespace of the Agentry EDM model.
enum agentryNamespace = "uim.agentry";

/// The EDM model of the Agentry OData service.
ODataServiceModel agentryODataModel() {
  enum ns = agentryNamespace;
  auto m = new ODataServiceModel(ns, "AgentryService");

  ODataEntitySetDef mobileApplications = {
    name: "MobileApplications", entityType: "MobileApplication", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Name"),
      p("description", Edm.string_, "Description"),
      p("platform", Edm.string_, "Platform"),
      p("status", Edm.string_, "Status"),
      p("iconUrl", Edm.string_, "Icon URL"),
      p("category", Edm.string_, "Category"),
      p("vendor", Edm.string_, "Vendor"),
      p("contactEmail", Edm.string_, "Contact Email"),
      p("backendSystemId", Edm.string_, "Backend System Id"),
      p("offlineCapable", Edm.boolean, "Offline Capable"),
      p("pushNotificationsEnabled", Edm.boolean, "Push Notifications Enabled"),
      p("minOsVersion", Edm.string_, "Min. OS Version"),
      p("packageName", Edm.string_, "Package Name"),
    ]
  };
  m.entitySets ~= mobileApplications;

  ODataEntitySetDef appDefinitions = {
    name: "AppDefinitions", entityType: "AppDefinition", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("applicationId", Edm.string_, "Application"),
      p("name", Edm.string_, "Name"),
      p("description", Edm.string_, "Description"),
      p("status", Edm.string_, "Status"),
      p("definitionContent", Edm.string_, "Definition Content"),
      p("definitionFormat", Edm.string_, "Definition Format"),
      p("schemaVersion", Edm.string_, "Schema Version"),
      p("authoredBy", Edm.string_, "Authored By"),
      p("targetPlatform", Edm.string_, "Target Platform"),
      p("businessObjectModel", Edm.string_, "Business Object Model"),
      p("validationPassed", Edm.boolean, "Validation Passed"),
      p("validationErrors", Edm.string_, "Validation Errors"),
      p("publishedAt", Edm.dateTimeOffset, "Published At"),
    ]
  };
  m.entitySets ~= appDefinitions;

  ODataEntitySetDef appVersions = {
    name: "AppVersions", entityType: "AppVersion", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("mobileApplicationId", Edm.string_, "Application"),
      p("definitionId", Edm.string_, "Definition"),
      p("versionNumber", Edm.string_, "Version Number"),
      p("releaseNotes", Edm.string_, "Release Notes"),
      p("status", Edm.string_, "Status"),
      p("builtAt", Edm.dateTimeOffset, "Built At"),
      p("publishedAt", Edm.dateTimeOffset, "Published At"),
      p("artifactUrl", Edm.string_, "Artifact URL"),
      p("checksum", Edm.string_, "Checksum"),
      p("minOsVersion", Edm.string_, "Min. OS Version"),
      p("changeLog", Edm.string_, "Change Log"),
      p("isMandatoryUpdate", Edm.boolean, "Mandatory Update"),
    ]
  };
  m.entitySets ~= appVersions;

  ODataEntitySetDef devices = {
    name: "Devices", entityType: "Device", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("mobileApplicationId", Edm.string_, "Application"),
      p("deviceName", Edm.string_, "Device Name"),
      p("deviceModel", Edm.string_, "Device Model"),
      p("manufacturer", Edm.string_, "Manufacturer"),
      p("platform", Edm.string_, "Platform"),
      p("osVersion", Edm.string_, "OS Version"),
      p("appVersionInstalled", Edm.string_, "App Version Installed"),
      p("status", Edm.string_, "Status"),
      p("enrolledAt", Edm.dateTimeOffset, "Enrolled At"),
      p("lastSeenAt", Edm.dateTimeOffset, "Last Seen At"),
      p("userId", Edm.string_, "User ID"),
      p("userEmail", Edm.string_, "User Email"),
      p("groupName", Edm.string_, "Group Name"),
      p("isManaged", Edm.boolean, "Managed"),
      p("mdmDeviceId", Edm.string_, "MDM Device ID"),
    ]
  };
  m.entitySets ~= devices;

  ODataEntitySetDef syncSessions = {
    name: "SyncSessions", entityType: "SyncSession", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("deviceId", Edm.string_, "Device"),
      p("applicationId", Edm.string_, "Application"),
      p("connectionId", Edm.string_, "Backend Connection"),
      p("status", Edm.string_, "Status"),
      p("direction", Edm.string_, "Direction"),
      p("startedAt", Edm.dateTimeOffset, "Started At"),
      p("completedAt", Edm.dateTimeOffset, "Completed At"),
      p("bytesSent", Edm.int64, "Bytes Sent"),
      p("bytesReceived", Edm.int64, "Bytes Received"),
      p("recordsSent", Edm.int64, "Records Sent"),
      p("recordsReceived", Edm.int64, "Records Received"),
      p("errorMessage", Edm.string_, "Error Message"),
      p("clientAppVersion", Edm.string_, "Client App Version"),
      p("triggeredBy", Edm.string_, "Triggered By"),
    ]
  };
  m.entitySets ~= syncSessions;

  ODataEntitySetDef backendConnections = {
    name: "BackendConnections", entityType: "BackendConnection", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Name"),
      p("description", Edm.string_, "Description"),
      p("backendType", Edm.string_, "Backend Type"),
      p("status", Edm.string_, "Status"),
      p("backendUrl", Edm.string_, "Backend URL"),
      p("clientId", Edm.string_, "Client ID"),
      p("authMethod", Edm.string_, "Auth Method"),
      p("sysId", Edm.string_, "System ID"),
      p("sysNumber", Edm.string_, "System Number"),
      p("client", Edm.string_, "Client"),
      p("language", Edm.string_, "Language"),
      p("destinationName", Edm.string_, "Destination Name"),
      p("lastTestedAt", Edm.dateTimeOffset, "Last Tested At"),
      p("lastTestedBy", Edm.string_, "Last Tested By"),
      p("sslEnabled", Edm.boolean, "SSL"),
      p("certificateFingerprint", Edm.string_, "Certificate Fingerprint"),
    ]
  };
  m.entitySets ~= backendConnections;

  ODataEntitySetDef deployments = {
    name: "Deployments", entityType: "Deployment", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("mobileApplicationId", Edm.string_, "Application"),
      p("appVersionId", Edm.string_, "App Version"),
      p("status", Edm.string_, "Status"),
      p("scope", Edm.string_, "Scope"),
      p("targetDeviceId", Edm.string_, "Target Device Id"),
      p("targetGroupName", Edm.string_, "Target Group Name"),
      p("scheduledAt", Edm.dateTimeOffset, "Scheduled At"),
      p("startedAt", Edm.dateTimeOffset, "Started At"),
      p("completedAt", Edm.dateTimeOffset, "Completed At"),
      p("rollbackVersionId", Edm.string_, "Rollback Version Id"),
      p("deployedBy", Edm.string_, "Deployed By"),
      p("notes", Edm.string_, "Notes"),
      p("devicesTotal", Edm.int32, "Devices Total"),
      p("devicesSucceeded", Edm.int32, "Devices Succeeded"),
      p("devicesFailed", Edm.int32, "Devices Failed"),
    ]
  };
  m.entitySets ~= deployments;
  ODataEntitySetDef statistics = {
    name: "Statistics", entityType: "Statistic", key: "tenantId", singleton: true,
    properties: [
      p("tenantId", Edm.string_, "Tenant", false),
      p("mobileApplications", Edm.int32, "Applications"),
      p("activeApplications", Edm.int32, "Active Applications"),
      p("appDefinitions", Edm.int32, "Definitions"),
      p("publishedDefinitions", Edm.int32, "Published Definitions"),
      p("appVersions", Edm.int32, "Versions"),
      p("publishedVersions", Edm.int32, "Published Versions"),
      p("devices", Edm.int32, "Devices"),
      p("activeDevices", Edm.int32, "Active Devices"),
      p("suspendedDevices", Edm.int32, "Suspended Devices"),
      p("syncSessions", Edm.int32, "Sync Sessions"),
      p("runningSyncs", Edm.int32, "Running Syncs"),
      p("failedSyncs", Edm.int32, "Failed Syncs"),
      p("backendConnections", Edm.int32, "Backend Connections"),
      p("connectionErrors", Edm.int32, "Connection Errors"),
      p("deployments", Edm.int32, "Deployments"),
      p("runningDeployments", Edm.int32, "Running Deployments"),
      p("failedDeployments", Edm.int32, "Failed Deployments"),
      p("bytesTransferred", Edm.int64, "Bytes Transferred"),
      p("recordsTransferred", Edm.int64, "Records Transferred"),
      p("lastSyncAt", Edm.dateTimeOffset, "Last Sync"),
      p("devicesIos", Edm.int32, "iOS Devices"),
      p("devicesAndroid", Edm.int32, "Android Devices"),
      p("devicesWindows", Edm.int32, "Windows Devices"),
      p("devicesWeb", Edm.int32, "Web Clients"),
      p("devicesCross", Edm.int32, "Cross-Platform Devices"),
    ]
  };
  m.entitySets ~= statistics;

  // ── unbound actions (lifecycle operations) ──────────────────────────────
  auto id = [p("id", Edm.string_, "ID", false)];
  void action(string name, string entityType, string set, ODataPropertyDef[] extra = null) {
    m.actions ~= ODataActionDef(name, id ~ extra, ns ~ "." ~ entityType, set);
  }

  action("SetMobileApplicationStatus", "MobileApplication", "MobileApplications", [p("status", Edm.string_, "Status", false)]);
  action("ValidateAppDefinition", "AppDefinition", "AppDefinitions");
  action("PublishAppDefinition", "AppDefinition", "AppDefinitions");
  action("ArchiveAppDefinition", "AppDefinition", "AppDefinitions");
  action("PublishAppVersion", "AppVersion", "AppVersions");
  action("WithdrawAppVersion", "AppVersion", "AppVersions");
  action("SetDeviceStatus", "Device", "Devices", [p("status", Edm.string_, "Status", false)]);
  action("StartSyncSession", "SyncSession", "SyncSessions");
  action("CompleteSyncSession", "SyncSession", "SyncSessions", [
      p("bytesSent", Edm.int64, "Bytes Sent"), p("bytesReceived", Edm.int64, "Bytes Received"),
      p("recordsSent", Edm.int64, "Records Sent"), p("recordsReceived", Edm.int64, "Records Received")
    ]);
  action("FailSyncSession", "SyncSession", "SyncSessions", [p("errorMessage", Edm.string_, "Error")]);
  action("CancelSyncSession", "SyncSession", "SyncSessions");
  action("TestBackendConnection", "BackendConnection", "BackendConnections");
  action("StartDeployment", "Deployment", "Deployments");
  action("CompleteDeployment", "Deployment", "Deployments", [
      p("devicesSucceeded", Edm.int32, "Succeeded"), p("devicesFailed", Edm.int32, "Failed")
    ]);
  action("RollbackDeployment", "Deployment", "Deployments");

  return m;
}

///
unittest {
  mixin(ShowTest!("agentryODataModel"));

  auto m = agentryODataModel();
  assert(m.has("Devices"));
  assert(m.find("Devices").hasProperty("deviceName"));
  assert(!m.find("Devices").hasProperty("pushToken"));
  assert(m.find("Deployments").hasProperty("scope"));
  assert(m.find("Statistics").singleton);
  assert(m.hasAction("PublishAppVersion"));
  assert(m.findAction("CompleteSyncSession").parameters.length == 5);
  assert(m.find("SyncSessions").propertiesOfType("Edm.Int64") == ["bytesSent", "bytesReceived", "recordsSent", "recordsReceived"]);
}
