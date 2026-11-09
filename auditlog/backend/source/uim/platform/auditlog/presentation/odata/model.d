/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.odata.model;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:

/// Primitive EDM types used by the service.
enum Edm : string {
  string_ = "Edm.String",
  int32 = "Edm.Int32",
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
  string name; /// entity set name, e.g. "AuditLogs"
  string entityType; /// entity type name, e.g. "AuditLog"
  string key = "id";
  ODataPropertyDef[] properties;
  bool insertable;
  bool updatable;
  bool deletable;
  bool singleton; /// exposed as <Singleton> instead of <EntitySet>

  bool hasProperty(string propertyName) const {
    return properties.any!(p => p.name == propertyName);
  }
}

/// An unbound action.
struct ODataActionDef {
  string name;
  ODataPropertyDef[] parameters;
  string returnType;
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

  string qualified(string typeName) const {
    return namespace_ ~ "." ~ typeName;
  }
}

private ODataPropertyDef p(string name, Edm type, string label, bool nullable = true) {
  return ODataPropertyDef(name, cast(string) type, nullable, false, label);
}

private ODataPropertyDef strings(string name, string label) {
  return ODataPropertyDef(name, cast(string) Edm.string_, true, true, label);
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

/// The EDM model of the audit log OData service.
ODataServiceModel auditLogODataModel() {
  enum ns = "uim.auditlog";
  auto m = new ODataServiceModel(ns, "AuditLogService");

  m.complexTypes ~= ODataComplexTypeDef("AuditAttribute", [
      p("name", Edm.string_, "Attribute"),
      p("oldValue", Edm.string_, "Old Value"),
      p("newValue", Edm.string_, "New Value"),
    ]);
  m.complexTypes ~= ODataComplexTypeDef("RetentionResult", [
      p("tenantId", Edm.string_, "Tenant"),
      p("retentionDays", Edm.int32, "Retention (Days)"),
      p("removed", Edm.int32, "Removed Records"),
      p("cutoff", Edm.dateTimeOffset, "Cutoff"),
    ]);

  ODataEntitySetDef auditLogs = {
    name: "AuditLogs", entityType: "AuditLog", insertable: true,
    properties: tenantEntityProperties() ~ [
      p("timestamp", Edm.dateTimeOffset, "Time"),
      p("category", Edm.string_, "Category"),
      p("severity", Edm.string_, "Severity"),
      p("action", Edm.string_, "Action"),
      p("outcome", Edm.string_, "Outcome"),
      p("userId", Edm.string_, "User ID"),
      p("userName", Edm.string_, "User"),
      p("serviceId", Edm.string_, "Service ID"),
      p("serviceName", Edm.string_, "Service"),
      p("objectType", Edm.string_, "Object Type"),
      p("objectId", Edm.string_, "Object ID"),
      p("message", Edm.string_, "Message"),
      ODataPropertyDef("attributes", ns ~ ".AuditAttribute", true, true, "Attributes"),
      p("ipAddress", Edm.string_, "IP Address"),
      p("userAgent", Edm.string_, "User Agent"),
      p("correlationId", Edm.string_, "Correlation ID"),
      p("originApp", Edm.string_, "Origin Application"),
      p("formatVersion", Edm.string_, "Format Version"),
    ]
  };
  m.entitySets ~= auditLogs;

  ODataEntitySetDef securityEvents = {
    name: "SecurityEvents", entityType: "SecurityEvent", insertable: true,
    properties: tenantEntityProperties() ~ [
      p("timestamp", Edm.dateTimeOffset, "Time"),
      p("auditLogId", Edm.string_, "Audit Log ID"),
      p("userId", Edm.string_, "User ID"),
      p("userName", Edm.string_, "User"),
      p("eventType", Edm.string_, "Event Type"),
      p("ipAddress", Edm.string_, "IP Address"),
      p("userAgent", Edm.string_, "User Agent"),
      p("clientId", Edm.string_, "Client ID"),
      p("identityProvider", Edm.string_, "Identity Provider"),
      p("authMethod", Edm.string_, "Auth Method"),
      p("outcome", Edm.string_, "Outcome"),
      p("failureReason", Edm.string_, "Failure Reason"),
      p("riskLevel", Edm.string_, "Risk Level"),
    ]
  };
  m.entitySets ~= securityEvents;

  ODataEntitySetDef dataAccessLogs = {
    name: "DataAccessLogs", entityType: "DataAccessLog", insertable: true,
    properties: tenantEntityProperties() ~ [
      p("timestamp", Edm.dateTimeOffset, "Time"),
      p("auditLogId", Edm.string_, "Audit Log ID"),
      p("accessedBy", Edm.string_, "Accessed By"),
      p("dataSubject", Edm.string_, "Data Subject"),
      p("dataObjectType", Edm.string_, "Object Type"),
      p("dataObjectId", Edm.string_, "Object ID"),
      strings("accessedFields", "Accessed Fields"),
      p("purpose", Edm.string_, "Purpose"),
      p("channel", Edm.string_, "Channel"),
    ]
  };
  m.entitySets ~= dataAccessLogs;

  ODataEntitySetDef configChangeLogs = {
    name: "ConfigChangeLogs", entityType: "ConfigChangeLog", insertable: true,
    properties: tenantEntityProperties() ~ [
      p("timestamp", Edm.dateTimeOffset, "Time"),
      p("auditLogId", Edm.string_, "Audit Log ID"),
      p("changedBy", Edm.string_, "Changed By"),
      p("configType", Edm.string_, "Configuration Type"),
      p("configObjectId", Edm.string_, "Configuration Object"),
      ODataPropertyDef("changes", ns ~ ".AuditAttribute", true, true, "Changes"),
      p("reason", Edm.string_, "Reason"),
    ]
  };
  m.entitySets ~= configChangeLogs;

  ODataEntitySetDef retentionPolicies = {
    name: "RetentionPolicies", entityType: "RetentionPolicy",
    insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Name"),
      p("description", Edm.string_, "Description"),
      p("retentionDays", Edm.int32, "Retention (Days)"),
      strings("categories", "Categories"),
      p("status", Edm.string_, "Status"),
      p("isDefault", Edm.boolean, "Default"),
    ]
  };
  m.entitySets ~= retentionPolicies;

  ODataEntitySetDef auditConfigs = {
    name: "AuditConfigs", entityType: "AuditConfig",
    insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Name"),
      p("status", Edm.string_, "Status"),
      p("logDataAccess", Edm.boolean, "Log Data Access"),
      p("logDataModification", Edm.boolean, "Log Data Modification"),
      p("logSecurityEvents", Edm.boolean, "Log Security Events"),
      p("logConfigurationChanges", Edm.boolean, "Log Configuration Changes"),
      p("enableDataMasking", Edm.boolean, "Data Masking"),
      strings("maskedFields", "Masked Fields"),
      strings("excludedServices", "Excluded Services"),
      p("minimumSeverity", Edm.string_, "Minimum Severity"),
      p("rateLimitPerSecond", Edm.int32, "Rate Limit / s"),
    ]
  };
  m.entitySets ~= auditConfigs;

  ODataEntitySetDef exportJobs = {
    name: "ExportJobs", entityType: "ExportJob", insertable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("requestedBy", Edm.string_, "Requested By"),
      p("format", Edm.string_, "Format"),
      p("status", Edm.string_, "Status"),
      strings("categories", "Categories"),
      p("timeFrom", Edm.dateTimeOffset, "From"),
      p("timeTo", Edm.dateTimeOffset, "To"),
      p("downloadUrl", Edm.string_, "Download"),
      p("totalRecords", Edm.int32, "Records"),
      p("completedAt", Edm.dateTimeOffset, "Completed At"),
      p("errorMessage", Edm.string_, "Error"),
    ]
  };
  m.entitySets ~= exportJobs;

  ODataEntitySetDef statistics = {
    name: "Statistics", entityType: "Statistic", key: "tenantId", singleton: true,
    properties: [
      p("tenantId", Edm.string_, "Tenant", false),
      p("totalEntries", Edm.int32, "Audit Entries"),
      p("securityEvents", Edm.int32, "Security Events"),
      p("failedLogins", Edm.int32, "Failed Security Events"),
      p("dataAccessLogs", Edm.int32, "Data Accesses"),
      p("configChanges", Edm.int32, "Configuration Changes"),
      p("retentionPolicies", Edm.int32, "Retention Policies"),
      p("exportJobs", Edm.int32, "Export Jobs"),
      p("retentionDays", Edm.int32, "Effective Retention (Days)"),
      p("lastEntryAt", Edm.dateTimeOffset, "Last Entry"),
      p("categorySecurityEvents", Edm.int32, "Security Events (Category)"),
      p("categoryConfiguration", Edm.int32, "Configuration (Category)"),
      p("categoryDataAccess", Edm.int32, "Data Access (Category)"),
      p("categoryDataModification", Edm.int32, "Data Modification (Category)"),
      p("severityInfo", Edm.int32, "Info"),
      p("severityWarning", Edm.int32, "Warning"),
      p("severityError", Edm.int32, "Error"),
      p("severityCritical", Edm.int32, "Critical"),
    ]
  };
  m.entitySets ~= statistics;

  m.actions ~= ODataActionDef("EnforceRetention", null, ns ~ ".RetentionResult");

  return m;
}

///
unittest {
  mixin(ShowTest!("auditLogODataModel"));

  auto m = auditLogODataModel();
  assert(m.has("AuditLogs"));
  assert(m.find("AuditLogs").hasProperty("message"));
  assert(m.find("Statistics").singleton);
  assert(!m.has("Unknown"));
}
