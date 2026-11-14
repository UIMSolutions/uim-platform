/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Conversion between domain entities / DTOs and OData v4 JSON payloads.
module uim.platform.transport.presentation.odata.serializers;

import core.time : Duration;
import std.datetime.systime : SysTime;
import std.datetime.timezone : UTC;
import uim.platform.transport;
import uim.platform.transport.presentation.tabular : NameLookup;

mixin(ShowModule!());

@safe:

/// stdTime (hnsecs) → Edm.DateTimeOffset ("2026-11-09T10:00:00Z"); 0 → null.
Json odataTime(long stdTime) {
  if (stdTime <= 0)
    return Json(null);
  auto t = SysTime(stdTime, UTC());
  t.fracSecs = Duration.zero;
  return Json(t.toISOExtString);
}

/// Edm.DateTimeOffset → stdTime; "" / null → 0. Throws on invalid values.
long parseODataTime(Json value) {
  if (value.type != Json.Type.string || value.get!string.length == 0)
    return 0;
  return SysTime.fromISOExtString(value.get!string).stdTime;
}

private void base(T)(ref Json j, const ref T e) {
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdBy"] = e.createdBy.value;
  j["createdAt"] = odataTime(e.createdAt);
  j["updatedBy"] = e.updatedBy.value;
  j["updatedAt"] = odataTime(e.updatedAt);
}

Json toOData(const TransportNode e, size_t pendingImports = 0) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["nodeType"] = enumName(e.nodeType);
  j["status"] = enumName(e.status);
  j["environment"] = e.environment;
  j["region"] = e.region;
  j["globalAccount"] = e.globalAccount;
  j["subaccountId"] = e.subaccountId.value;
  j["spaceId"] = e.spaceId.value;
  j["isForwardEnabled"] = e.isForwardEnabled;
  j["autoImport"] = e.autoImport;
  j["autoImportSchedule"] = e.autoImportSchedule;
  j["lastCheckedAt"] = odataTime(e.lastCheckedAt);
  j["connectionStatus"] = e.connectionStatus;
  j["pendingImports"] = cast(int) pendingImports;
  return j;
}

Json toOData(const TransportRoute e, const NameLookup names) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["sourceNodeId"] = e.sourceNodeId.value;
  j["sourceNodeName"] = names.node(e.sourceNodeId);
  j["destinationNodeId"] = e.destinationNodeId.value;
  j["destinationNodeName"] = names.node(e.destinationNodeId);
  j["status"] = enumName(e.status);
  j["isSequential"] = e.isSequential;
  j["sequence"] = e.sequence;
  return j;
}

Json toOData(const TransportRequest e, const NameLookup names) {
  auto j = Json.emptyObject;
  base(j, e);
  j["name"] = e.name;
  j["description"] = e.description;
  j["externalId"] = e.externalId;
  j["contentType"] = enumName(e.contentType);
  j["status"] = enumName(e.status);
  j["version"] = e.version_;
  j["contentSize"] = e.contentSize;
  j["storageUrl"] = e.storageUrl;
  j["checksum"] = e.checksum;
  j["sourceNodeId"] = e.sourceNodeId.value;
  j["sourceNodeName"] = e.sourceNodeId.isEmpty ? "" : names.node(e.sourceNodeId);
  j["namedUser"] = e.namedUser;
  j["systemId"] = e.systemId;
  j["queuedAt"] = odataTime(e.queuedAt);
  j["importedAt"] = odataTime(e.importedAt);
  j["errorMessage"] = e.errorMessage;
  return j;
}

Json toOData(const ImportQueueEntry e, const NameLookup names) {
  auto j = Json.emptyObject;
  base(j, e);
  j["nodeId"] = e.nodeId.value;
  j["nodeName"] = names.node(e.nodeId);
  j["requestId"] = e.requestId.value;
  j["requestName"] = names.request(e.requestId);
  j["status"] = enumName(e.status);
  j["queuePosition"] = e.queuePosition;
  j["queuedAt"] = odataTime(e.queuedAt);
  j["startedAt"] = odataTime(e.startedAt);
  j["completedAt"] = odataTime(e.completedAt);
  j["errorMessage"] = e.errorMessage;
  j["importLog"] = e.importLog;
  j["isSelected"] = e.isSelected;
  j["scheduledAt"] = odataTime(e.scheduledAt);
  return j;
}

Json toOData(const TransportAction e, const NameLookup names) {
  auto j = Json.emptyObject;
  base(j, e);
  j["actionType"] = enumName(e.actionType);
  j["actionStatus"] = enumName(e.actionStatus);
  j["nodeId"] = e.nodeId.value;
  j["nodeName"] = e.nodeId.isEmpty ? "" : names.node(e.nodeId);
  j["requestId"] = e.requestId.value;
  j["requestName"] = e.requestId.isEmpty ? "" : names.request(e.requestId);
  j["routeId"] = e.routeId.value;
  j["performedBy"] = e.performedBy;
  j["performedAt"] = odataTime(e.performedAt);
  j["completedAt"] = odataTime(e.completedAt);
  j["description"] = e.description;
  j["errorMessage"] = e.errorMessage;
  j["logDetails"] = e.logDetails;
  return j;
}

Json toOData(const TransportStatistics s) {
  int byStatus(string key) {
    if (auto v = key in s.requestsByStatus)
      return cast(int)*v;
    return 0;
  }

  auto j = Json.emptyObject;
  j["tenantId"] = s.tenantId.value;
  j["nodes"] = cast(int) s.nodes;
  j["enabledNodes"] = cast(int) s.enabledNodes;
  j["routes"] = cast(int) s.routes;
  j["enabledRoutes"] = cast(int) s.enabledRoutes;
  j["requests"] = cast(int) s.requests;
  j["queueEntries"] = cast(int) s.queueEntries;
  j["pendingImports"] = cast(int) s.pendingImports;
  j["runningImports"] = cast(int) s.runningImports;
  j["successfulImports"] = cast(int) s.successfulImports;
  j["failedImports"] = cast(int) s.failedImports;
  j["actions"] = cast(int) s.actions;
  j["lastActionAt"] = odataTime(s.lastActionAt);
  foreach (st; ["initial", "running", "success", "warning", "failed", "repeating"])
    j["requests" ~ cast(char)(st[0] - 32) ~ st[1 .. $]] = byStatus(st);
  return j;
}

/// UsecaseResult → OperationResult complex type.
Json toOperationResult(const UsecaseResult r) {
  int count(string key) {
    return r.data.type == Json.Type.object ? fieldInt(r.data, key) : 0;
  }

  auto j = Json.emptyObject;
  j["success"] = r.success;
  j["id"] = r.id;
  j["message"] = r.message;
  foreach (key; ["imported", "succeeded", "warnings", "failed", "forwarded"])
    j[key] = count(key);
  return j;
}

// ── Payload → input DTOs ────────────────────────────────────────────────────

private bool boolOf(Json body, string key, bool defaultValue) {
  return fieldBool(body, key, defaultValue);
}

CreateNodeInput toCreateNodeInput(Json body, TenantId tenantId, UserId caller) {
  CreateNodeInput r;
  r.tenantId = tenantId;
  r.id = body.fieldString("id");
  r.name = body.fieldString("name");
  r.description = body.fieldString("description");
  r.nodeType = body.fieldString("nodeType");
  r.environment = body.fieldString("environment");
  r.region = body.fieldString("region");
  r.globalAccount = body.fieldString("globalAccount");
  r.subaccountId = body.fieldString("subaccountId");
  r.spaceId = body.fieldString("spaceId");
  r.serviceKey = body.fieldString("serviceKey");
  r.isForwardEnabled = boolOf(body, "isForwardEnabled", true);
  r.autoImport = boolOf(body, "autoImport", false);
  r.autoImportSchedule = body.fieldString("autoImportSchedule");
  r.createdBy = caller;
  return r;
}

/// PATCH semantics: properties missing in the body keep their current value.
UpdateNodeInput toUpdateNodeInput(Json body, const TransportNode current, UserId caller) {
  auto r = UpdateNodeInput.from(current);
  r.name = body.fieldString("name", r.name);
  r.description = body.fieldString("description", r.description);
  r.nodeType = body.fieldString("nodeType", r.nodeType);
  r.environment = body.fieldString("environment", r.environment);
  r.region = body.fieldString("region", r.region);
  r.globalAccount = body.fieldString("globalAccount", r.globalAccount);
  r.subaccountId = body.fieldString("subaccountId", r.subaccountId);
  r.spaceId = body.fieldString("spaceId", r.spaceId);
  r.serviceKey = body.fieldString("serviceKey");
  r.isForwardEnabled = boolOf(body, "isForwardEnabled", r.isForwardEnabled);
  r.autoImport = boolOf(body, "autoImport", r.autoImport);
  r.autoImportSchedule = body.fieldString("autoImportSchedule", r.autoImportSchedule);
  r.updatedBy = caller;
  return r;
}

CreateRouteInput toCreateRouteInput(Json body, TenantId tenantId, UserId caller) {
  CreateRouteInput r;
  r.tenantId = tenantId;
  r.id = body.fieldString("id");
  r.name = body.fieldString("name");
  r.description = body.fieldString("description");
  r.sourceNodeId = body.fieldString("sourceNodeId");
  r.destinationNodeId = body.fieldString("destinationNodeId");
  r.status = body.fieldString("status");
  r.isSequential = boolOf(body, "isSequential", true);
  r.sequence = body.fieldInt("sequence");
  r.createdBy = caller;
  return r;
}

UpdateRouteInput toUpdateRouteInput(Json body, const TransportRoute current, UserId caller) {
  auto r = UpdateRouteInput.from(current);
  r.name = body.fieldString("name", r.name);
  r.description = body.fieldString("description", r.description);
  r.status = body.fieldString("status", r.status);
  r.isSequential = boolOf(body, "isSequential", r.isSequential);
  r.sequence = body.fieldInt("sequence", r.sequence);
  r.updatedBy = caller;
  return r;
}

CreateRequestInput toCreateRequestInput(Json body, TenantId tenantId, UserId caller) {
  CreateRequestInput r;
  r.tenantId = tenantId;
  r.id = body.fieldString("id");
  r.name = body.fieldString("name");
  r.description = body.fieldString("description");
  r.externalId = body.fieldString("externalId");
  r.contentType = body.fieldString("contentType");
  r.version_ = body.fieldString("version");
  r.contentSize = body.fieldString("contentSize");
  r.storageUrl = body.fieldString("storageUrl");
  r.checksum = body.fieldString("checksum");
  r.sourceNodeId = body.fieldString("sourceNodeId");
  r.namedUser = body.fieldString("namedUser");
  r.systemId = body.fieldString("systemId");
  r.createdBy = caller;
  return r;
}

UpdateRequestInput toUpdateRequestInput(Json body, const TransportRequest current, UserId caller) {
  auto r = UpdateRequestInput.from(current);
  r.name = body.fieldString("name", r.name);
  r.description = body.fieldString("description", r.description);
  r.externalId = body.fieldString("externalId", r.externalId);
  r.contentType = body.fieldString("contentType", r.contentType);
  r.version_ = body.fieldString("version", r.version_);
  r.contentSize = body.fieldString("contentSize", r.contentSize);
  r.storageUrl = body.fieldString("storageUrl", r.storageUrl);
  r.checksum = body.fieldString("checksum", r.checksum);
  r.namedUser = body.fieldString("namedUser", r.namedUser);
  r.systemId = body.fieldString("systemId", r.systemId);
  r.updatedBy = caller;
  return r;
}

EnqueueInput toEnqueueInput(Json body, TenantId tenantId, UserId caller) {
  EnqueueInput r;
  r.tenantId = tenantId;
  r.id = body.fieldString("id");
  r.nodeId = body.fieldString("nodeId");
  r.requestId = body.fieldString("requestId");
  r.queuePosition = body.fieldInt("queuePosition");
  r.isSelected = boolOf(body, "isSelected", true);
  r.scheduledAt = parseODataTime("scheduledAt" in body ? body["scheduledAt"] : Json(null));
  r.createdBy = caller;
  return r;
}

RecordActionInput toRecordActionInput(Json body, TenantId tenantId, UserId caller) {
  RecordActionInput r;
  r.tenantId = tenantId;
  r.id = body.fieldString("id");
  r.actionType = body.fieldString("actionType");
  r.actionStatus = body.fieldString("actionStatus");
  r.nodeId = body.fieldString("nodeId");
  r.requestId = body.fieldString("requestId");
  r.routeId = body.fieldString("routeId");
  r.performedBy = body.fieldString("performedBy", caller.value);
  r.description = body.fieldString("description");
  r.logDetails = body.fieldString("logDetails");
  r.errorMessage = body.fieldString("errorMessage");
  return r;
}

///
unittest {
  mixin(ShowTest!("OData serializers"));

  assert(odataTime(0).type == Json.Type.null_);
  auto t = odataTime(SysTime.fromISOExtString("2026-11-09T10:11:12.345Z").stdTime);
  assert(t.get!string == "2026-11-09T10:11:12Z");

  auto a = TransportAction(TenantId("t1"));
  a.actionType = ActionType.import_;
  assert(toOData(a, NameLookup.init)["actionType"].get!string == "import");

  TransportStatistics s;
  s.requestsByStatus["failed"] = 2;
  assert(toOData(s)["requestsFailed"].get!int == 2);

  TransportRoute current;
  current.name = "old";
  current.sequence = 3;
  auto upd = toUpdateRouteInput(parseJsonString(`{"description": "new"}`), current, UserId("u"));
  assert(upd.name == "old" && upd.sequence == 3 && upd.description == "new");
}
