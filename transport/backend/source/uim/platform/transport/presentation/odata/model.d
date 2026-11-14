/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.presentation.odata.model;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Primitive EDM types used by the service.
enum Edm : string {
  string_ = "Edm.String",
  int32 = "Edm.Int32",
  boolean = "Edm.Boolean",
  dateTimeOffset = "Edm.DateTimeOffset",
}

/// A structural property of an entity or complex type (or an action parameter).
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
  string name; /// entity set name, e.g. "TransportNodes"
  string entityType; /// entity type name, e.g. "TransportNode"
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

  bool has(string name) const {
    return entitySets.any!(s => s.name == name);
  }

  const(ODataEntitySetDef) find(string name) const {
    foreach (s; entitySets)
      if (s.name == name)
        return s;
    return ODataEntitySetDef.init;
  }

  bool hasAction(string name) const {
    return actions.any!(a => a.name == name);
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

/// The EDM model of the transport OData service.
ODataServiceModel transportODataModel() {
  enum ns = "uim.transport";
  auto m = new ODataServiceModel(ns, "TransportService");

  m.complexTypes ~= ODataComplexTypeDef("OperationResult", [
      p("success", Edm.boolean, "Success"),
      p("id", Edm.string_, "ID"),
      p("message", Edm.string_, "Message"),
      p("imported", Edm.int32, "Imported"),
      p("succeeded", Edm.int32, "Succeeded"),
      p("warnings", Edm.int32, "Warnings"),
      p("failed", Edm.int32, "Failed"),
      p("forwarded", Edm.int32, "Forwarded"),
    ]);

  ODataEntitySetDef nodes = {
    name: "TransportNodes", entityType: "TransportNode", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Node"),
      p("description", Edm.string_, "Description"),
      p("nodeType", Edm.string_, "Runtime"),
      p("status", Edm.string_, "Status"),
      p("environment", Edm.string_, "Environment"),
      p("region", Edm.string_, "Region"),
      p("globalAccount", Edm.string_, "Global Account"),
      p("subaccountId", Edm.string_, "Subaccount"),
      p("spaceId", Edm.string_, "Space"),
      p("isForwardEnabled", Edm.boolean, "Forward Enabled"),
      p("autoImport", Edm.boolean, "Auto-Import"),
      p("autoImportSchedule", Edm.string_, "Auto-Import Schedule"),
      p("lastCheckedAt", Edm.dateTimeOffset, "Last Check"),
      p("connectionStatus", Edm.string_, "Connection"),
      p("pendingImports", Edm.int32, "Pending Imports"),
    ]
  };
  m.entitySets ~= nodes;

  ODataEntitySetDef routes = {
    name: "TransportRoutes", entityType: "TransportRoute", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Route"),
      p("description", Edm.string_, "Description"),
      p("sourceNodeId", Edm.string_, "Source Node ID"),
      p("sourceNodeName", Edm.string_, "Source Node"),
      p("destinationNodeId", Edm.string_, "Destination Node ID"),
      p("destinationNodeName", Edm.string_, "Destination Node"),
      p("status", Edm.string_, "Status"),
      p("isSequential", Edm.boolean, "Sequential"),
      p("sequence", Edm.int32, "Sequence"),
    ]
  };
  m.entitySets ~= routes;

  ODataEntitySetDef requests = {
    name: "TransportRequests", entityType: "TransportRequest", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Transport Request"),
      p("description", Edm.string_, "Description"),
      p("externalId", Edm.string_, "External ID"),
      p("contentType", Edm.string_, "Content Type"),
      p("status", Edm.string_, "Status"),
      p("version", Edm.string_, "Version"),
      p("contentSize", Edm.string_, "Size"),
      p("storageUrl", Edm.string_, "Content Archive"),
      p("checksum", Edm.string_, "Checksum"),
      p("sourceNodeId", Edm.string_, "Source Node ID"),
      p("sourceNodeName", Edm.string_, "Source Node"),
      p("namedUser", Edm.string_, "Owner"),
      p("systemId", Edm.string_, "System"),
      p("queuedAt", Edm.dateTimeOffset, "Queued At"),
      p("importedAt", Edm.dateTimeOffset, "Imported At"),
      p("errorMessage", Edm.string_, "Error"),
    ]
  };
  m.entitySets ~= requests;

  ODataEntitySetDef queue = {
    name: "ImportQueueEntries", entityType: "ImportQueueEntry", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("nodeId", Edm.string_, "Node ID"),
      p("nodeName", Edm.string_, "Node"),
      p("requestId", Edm.string_, "Request ID"),
      p("requestName", Edm.string_, "Transport Request"),
      p("status", Edm.string_, "Status"),
      p("queuePosition", Edm.int32, "Position"),
      p("queuedAt", Edm.dateTimeOffset, "Queued At"),
      p("startedAt", Edm.dateTimeOffset, "Started At"),
      p("completedAt", Edm.dateTimeOffset, "Completed At"),
      p("errorMessage", Edm.string_, "Error"),
      p("importLog", Edm.string_, "Import Log"),
      p("isSelected", Edm.boolean, "Selected"),
      p("scheduledAt", Edm.dateTimeOffset, "Scheduled At"),
    ]
  };
  m.entitySets ~= queue;

  ODataEntitySetDef actions = {
    name: "TransportActions", entityType: "TransportAction", insertable: true,
    properties: tenantEntityProperties() ~ [
      p("actionType", Edm.string_, "Action"),
      p("actionStatus", Edm.string_, "Status"),
      p("nodeId", Edm.string_, "Node ID"),
      p("nodeName", Edm.string_, "Node"),
      p("requestId", Edm.string_, "Request ID"),
      p("requestName", Edm.string_, "Transport Request"),
      p("routeId", Edm.string_, "Route ID"),
      p("performedBy", Edm.string_, "Performed By"),
      p("performedAt", Edm.dateTimeOffset, "Performed At"),
      p("completedAt", Edm.dateTimeOffset, "Completed At"),
      p("description", Edm.string_, "Description"),
      p("errorMessage", Edm.string_, "Error"),
      p("logDetails", Edm.string_, "Log"),
    ]
  };
  m.entitySets ~= actions;

  ODataEntitySetDef statistics = {
    name: "Statistics", entityType: "Statistic", key: "tenantId", singleton: true,
    properties: [
      p("tenantId", Edm.string_, "Tenant", false),
      p("nodes", Edm.int32, "Nodes"),
      p("enabledNodes", Edm.int32, "Enabled Nodes"),
      p("routes", Edm.int32, "Routes"),
      p("enabledRoutes", Edm.int32, "Enabled Routes"),
      p("requests", Edm.int32, "Transport Requests"),
      p("queueEntries", Edm.int32, "Queue Entries"),
      p("pendingImports", Edm.int32, "Pending Imports"),
      p("runningImports", Edm.int32, "Running Imports"),
      p("successfulImports", Edm.int32, "Successful Imports"),
      p("failedImports", Edm.int32, "Failed Imports"),
      p("actions", Edm.int32, "Actions"),
      p("lastActionAt", Edm.dateTimeOffset, "Last Action"),
      p("requestsInitial", Edm.int32, "Requests Initial"),
      p("requestsRunning", Edm.int32, "Requests Running"),
      p("requestsSuccess", Edm.int32, "Requests Successful"),
      p("requestsWarning", Edm.int32, "Requests With Warnings"),
      p("requestsFailed", Edm.int32, "Requests Failed"),
      p("requestsRepeating", Edm.int32, "Requests Repeating"),
    ]
  };
  m.entitySets ~= statistics;

  auto result = ns ~ ".OperationResult";
  auto str = (string name) => ODataPropertyDef(name, cast(string) Edm.string_, true, false, "");
  m.actions ~= ODataActionDef("ExportRequest", [str("requestId"), str("nodeId")], result);
  m.actions ~= ODataActionDef("ImportNode", [
      str("nodeId"), ODataPropertyDef("entryIds", cast(string) Edm.string_, true, true, "")
    ], result);
  m.actions ~= ODataActionDef("ForwardRequest", [str("requestId"), str("fromNodeId")], result);
  m.actions ~= ODataActionDef("ResetQueueEntry", [str("entryId")], result);
  m.actions ~= ODataActionDef("EnableNode", [str("nodeId")], result);
  m.actions ~= ODataActionDef("DisableNode", [str("nodeId")], result);
  m.actions ~= ODataActionDef("CheckConnection", [str("nodeId")], result);
  m.actions ~= ODataActionDef("EnableRoute", [str("routeId")], result);
  m.actions ~= ODataActionDef("DisableRoute", [str("routeId")], result);
  return m;
}

///
unittest {
  mixin(ShowTest!("transportODataModel"));

  auto m = transportODataModel();
  assert(m.has("TransportNodes"));
  assert(m.find("TransportRoutes").hasProperty("sourceNodeName"));
  assert(m.find("Statistics").singleton);
  assert(m.hasAction("ImportNode"));
  assert(!m.has("Unknown"));
}
