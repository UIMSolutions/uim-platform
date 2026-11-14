/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// OData v4 endpoint for SAP Fiori / UI5 (sap.ui.model.odata.v4.ODataModel).
///
///   GET    <base>/                         service document
///   GET    <base>/$metadata                CSDL (EDMX)
///   GET    <base>/<Set>[?$filter&$orderby&$select&$top&$skip&$count&$search]
///   GET    <base>/<Set>/$count
///   GET    <base>/<Set>('<key>')
///   POST   <base>/<Set>                    create
///   PATCH  <base>/<Set>('<key>')           update (PATCH semantics)
///   DELETE <base>/<Set>('<key>')           delete
///   GET    <base>/Statistics               singleton
///   POST   <base>/ExportRequest | ImportNode | ForwardRequest | ResetQueueEntry
///          | EnableNode | DisableNode | CheckConnection | EnableRoute | DisableRoute
///
/// $batch is not supported — configure the UI5 model with groupId "$direct".
module uim.platform.transport.presentation.odata.controller;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPMethod;
import vibe.textfilter.urlencode : urlDecode;
import uim.platform.transport;
import uim.platform.transport.presentation.tabular : NameLookup;
import uim.platform.transport.presentation.odata.model;
import uim.platform.transport.presentation.odata.metadata;
import uim.platform.transport.presentation.odata.query;
import uim.platform.transport.presentation.odata.serializers;

mixin(ShowModule!());

@safe:

/// Error with an HTTP status, rendered as an OData error payload.
class ODataError : Exception {
  int status;
  string code;

  this(int status, string code, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.status = status;
    this.code = code;
  }
}

/// The parsed resource path (after the service root).
struct ODataResource {
  string name; /// entity set, singleton or action
  string key; /// entity key, if addressed
  bool hasKey;
  bool countOnly; /// <Set>/$count
}

/// Parse "Set", "Set/$count", "Set('a')", "Set(id='a')", "Action()".
ODataResource parseResourcePath(string path) {
  ODataResource r;
  auto p = path.strip("/");
  if (p.endsWith("/$count")) {
    r.countOnly = true;
    p = p[0 .. $ - "/$count".length];
  }
  if (p.canFind("/"))
    throw new ODataError(400, "UnsupportedPath", "Navigation paths are not supported: " ~ path);

  auto open = p.indexOf('(');
  if (open < 0) {
    r.name = p;
    return r;
  }
  if (!p.endsWith(")"))
    throw new ODataError(400, "InvalidKey", "Invalid key in " ~ path);

  r.name = p[0 .. open];
  auto key = p[open + 1 .. $ - 1];
  auto eq = key.indexOf('=');
  if (eq >= 0)
    key = key[eq + 1 .. $];
  if (key.length >= 2 && key[0] == '\'' && key[$ - 1] == '\'')
    key = key[1 .. $ - 1].replace("''", "'");
  r.key = key;
  r.hasKey = r.key.length > 0;
  return r;
}

class TransportODataController {
  protected ODataServiceModel model;
  protected string basePath;
  protected string defaultTenant;
  protected string metadataXml;
  protected TransportPorts ports;

  this(TransportPorts ports, string basePath, string defaultTenant) {
    this.ports = ports;
    this.model = transportODataModel();
    this.basePath = basePath.stripRight("/");
    this.defaultTenant = defaultTenant;
    this.metadataXml = buildMetadataXml(model);
  }

  /// The generated CSDL (also used to refresh frontend/localService/metadata.xml).
  string metadata() const {
    return metadataXml;
  }

  void registerRoutes(URLRouter router) {
    router.get(basePath, &handleServiceDocument);
    router.get(basePath ~ "/", &handleServiceDocument);
    router.get(basePath ~ "/$metadata", &handleMetadata);
    router.any(basePath ~ "/*", &handle);
  }

  // ── Endpoints ───────────────────────────────────────────────────────────

  void handleServiceDocument(HTTPServerRequest req, HTTPServerResponse res) {
    writeJson(res, 200, buildServiceDocument(model, basePath ~ "/$metadata"));
  }

  void handleMetadata(HTTPServerRequest req, HTTPServerResponse res) {
    res.headers["OData-Version"] = "4.0";
    res.writeBody(metadataXml, 200, "application/xml");
  }

  void handle(HTTPServerRequest req, HTTPServerResponse res) {
    try {
      auto path = urlDecode(req.requestPath.toString[basePath.length .. $]);
      auto resource = parseResourcePath(path);
      if (resource.name == "$metadata")
        return handleMetadata(req, res);
      if (resource.name.length == 0)
        return handleServiceDocument(req, res);

      auto identity = resolveIdentity(req.headers.get("Authorization", ""),
        req.headers.get("X-Tenant-Id", ""), req.headers.get("X-User-Id", ""), defaultTenant);

      if (model.hasAction(resource.name)) {
        if (req.method != HTTPMethod.POST)
          throw new ODataError(405, "MethodNotAllowed", resource.name ~ " must be invoked with POST");
        return invokeAction(res, resource.name, identity, requestBody(req, true));
      }

      if (!model.has(resource.name))
        throw new ODataError(404, "NotFound", "Unknown resource '" ~ resource.name ~ "'");
      auto set = model.find(resource.name);

      switch (req.method) {
      case HTTPMethod.GET:
        if (set.singleton)
          return writeEntity(res, 200, "$metadata#" ~ set.name, singletonOf(set, identity));
        if (resource.hasKey)
          return writeEntity(res, 200, "$metadata#" ~ set.name ~ "/$entity",
            requireEntity(set, identity.tenantId, resource.key));
        return readCollection(req, res, set, identity, resource.countOnly);

      case HTTPMethod.POST:
        if (!set.insertable || resource.hasKey)
          throw new ODataError(405, "MethodNotAllowed", set.name ~ " does not support POST here");
        auto created = createEntity(set, identity, requestBody(req));
        res.headers["Location"] = basePath ~ "/" ~ set.name ~ "('" ~ created["id"].get!string ~ "')";
        return writeEntity(res, 201, "$metadata#" ~ set.name ~ "/$entity", created);

      case HTTPMethod.PATCH, HTTPMethod.PUT:
        if (!set.updatable || !resource.hasKey)
          throw new ODataError(405, "MethodNotAllowed", set.name ~ " does not support updates");
        return writeEntity(res, 200, "$metadata#" ~ set.name ~ "/$entity",
          updateEntity(set, identity, resource.key, requestBody(req)));

      case HTTPMethod.DELETE:
        if (!set.deletable || !resource.hasKey)
          throw new ODataError(405, "MethodNotAllowed", set.name ~ " does not support DELETE");
        deleteEntity(set, identity, resource.key);
        res.headers["OData-Version"] = "4.0";
        res.statusCode = 204;
        res.writeVoidBody();
        return;

      default:
        throw new ODataError(405, "MethodNotAllowed", "Method not allowed");
      }
    } catch (ODataError e) {
      writeError(res, e.status, e.code, e.msg);
    } catch (ODataQueryException e) {
      writeError(res, 400, "InvalidQuery", e.msg);
    } catch (Exception e) {
      logError("transport odata: %s", e.msg);
      writeError(res, 500, "InternalError", e.msg);
    }
  }

  // ── Reading ─────────────────────────────────────────────────────────────

  protected void readCollection(HTTPServerRequest req, HTTPServerResponse res,
      const ODataEntitySetDef set, RequestIdentity identity, bool countOnly) {
    auto names = set.properties.map!(p => p.name).array;
    auto query = parseQuery((name) => req.query.get(name, ""), names, set.key);

    size_t total;
    auto page = query.apply(rowsOf(set, identity.tenantId), total);

    if (countOnly) {
      res.headers["OData-Version"] = "4.0";
      res.writeBody(total.to!string, 200, "text/plain");
      return;
    }

    auto context = "$metadata#" ~ set.name;
    if (query.select.length > 0)
      context ~= "(" ~ query.select.join(",") ~ ")";

    auto payload = Json.emptyObject;
    payload["@odata.context"] = context;
    if (query.count)
      payload["@odata.count"] = ieee754Compatible(req) ? Json(total.to!string) : Json(total);
    auto value = Json.emptyArray;
    foreach (row; page)
      value ~= row;
    payload["value"] = value;
    writeJson(res, 200, payload);
  }

  protected Json nodeRow(const TransportNode n) {
    auto pending = ports.queue.listEntriesByNode(n.tenantId, n.id).count!(e => e.isPending);
    return toOData(n, pending);
  }

  protected Json[] rowsOf(const ODataEntitySetDef set, TenantId tenant) {
    auto names = NameLookup.of(ports, tenant);
    switch (set.name) {
    case "TransportNodes":
      return ports.nodes.listNodes(tenant).map!(e => nodeRow(e)).array;
    case "TransportRoutes":
      return ports.routes.listRoutes(tenant).map!(e => toOData(e, names)).array;
    case "TransportRequests":
      return ports.requests.listRequests(tenant).map!(e => toOData(e, names)).array;
    case "ImportQueueEntries":
      return ports.queue.listEntries(tenant).map!(e => toOData(e, names)).array;
    case "TransportActions":
      return ports.actions.listActions(tenant).map!(e => toOData(e, names)).array;
    default:
      throw new ODataError(404, "NotFound", "Unknown entity set " ~ set.name);
    }
  }

  /// Returns Json(null) if not found.
  protected Json entityOf(const ODataEntitySetDef set, TenantId tenant, string key) {
    auto names = NameLookup.of(ports, tenant);
    switch (set.name) {
    case "TransportNodes": {
      auto e = ports.nodes.getNode(tenant, TransportNodeId(key));
      return e.isNull ? Json(null) : nodeRow(e);
    }
    case "TransportRoutes": {
      auto e = ports.routes.getRoute(tenant, TransportRouteId(key));
      return e.isNull ? Json(null) : toOData(e, names);
    }
    case "TransportRequests": {
      auto e = ports.requests.getRequest(tenant, TransportRequestId(key));
      return e.isNull ? Json(null) : toOData(e, names);
    }
    case "ImportQueueEntries": {
      auto e = ports.queue.getEntry(tenant, ImportQueueEntryId(key));
      return e.isNull ? Json(null) : toOData(e, names);
    }
    case "TransportActions": {
      auto e = ports.actions.getAction(tenant, TransportActionId(key));
      return e.isNull ? Json(null) : toOData(e, names);
    }
    default: {
      return Json(null);
    }
    }
  }

  protected Json requireEntity(const ODataEntitySetDef set, TenantId tenant, string key) {
    auto e = entityOf(set, tenant, key);
    if (e.type == Json.Type.null_)
      throw new ODataError(404, "NotFound", set.entityType ~ " '" ~ key ~ "' not found");
    return e;
  }

  protected Json singletonOf(const ODataEntitySetDef set, RequestIdentity identity) {
    if (set.name == "Statistics")
      return toOData(ports.statistics.statistics(identity.tenantId));
    throw new ODataError(404, "NotFound", "Unknown singleton " ~ set.name);
  }

  // ── Writing ─────────────────────────────────────────────────────────────

  protected Json createEntity(const ODataEntitySetDef set, RequestIdentity identity, Json body) {
    auto tenant = identity.tenantId;
    auto caller = identity.userId;
    UsecaseResult result;
    switch (set.name) {
    case "TransportNodes": {
      result = check(ports.nodes.createNode(toCreateNodeInput(body, tenant, caller)));
      break;
    }
    case "TransportRoutes": {
      result = check(ports.routes.createRoute(toCreateRouteInput(body, tenant, caller)));
      break;
    }
    case "TransportRequests": {
      result = check(ports.requests.createRequest(toCreateRequestInput(body, tenant, caller)));
      break;
    }
    case "ImportQueueEntries": {
      result = check(ports.queue.enqueue(toEnqueueInput(body, tenant, caller)));
      break;
    }
    case "TransportActions": {
      result = check(ports.actions.recordAction(toRecordActionInput(body, tenant, caller)));
      break;
    }
    default: {
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is read-only");
    }
    }
    return requireEntity(set, tenant, result.id);
  }

  protected Json updateEntity(const ODataEntitySetDef set, RequestIdentity identity, string key, Json body) {
    auto tenant = identity.tenantId;
    auto caller = identity.userId;
    switch (set.name) {
    case "TransportNodes": {
      auto current = ports.nodes.getNode(tenant, TransportNodeId(key));
      if (current.isNull)
        throw new ODataError(404, "NotFound", "TransportNode '" ~ key ~ "' not found");
      check(ports.nodes.updateNode(toUpdateNodeInput(body, current, caller)));
      if ("status" in body) { // status changes go through the dedicated use cases
        auto enable = body.fieldString("status") == "enabled";
        if (enable != current.isEnabled)
          check(enable ? ports.nodes.enableNode(tenant, current.id) : ports.nodes.disableNode(tenant, current.id));
      }
      break;
    }
    case "TransportRoutes": {
      auto current = ports.routes.getRoute(tenant, TransportRouteId(key));
      if (current.isNull)
        throw new ODataError(404, "NotFound", "TransportRoute '" ~ key ~ "' not found");
      check(ports.routes.updateRoute(toUpdateRouteInput(body, current, caller)));
      break;
    }
    case "TransportRequests": {
      auto current = ports.requests.getRequest(tenant, TransportRequestId(key));
      if (current.isNull)
        throw new ODataError(404, "NotFound", "TransportRequest '" ~ key ~ "' not found");
      check(ports.requests.updateRequest(toUpdateRequestInput(body, current, caller)));
      break;
    }
    case "ImportQueueEntries": {
      if (!("isSelected" in body) || body["isSelected"].type != Json.Type.bool_)
        throw new ODataError(400, "BadRequest", "Only 'isSelected' can be changed — use ResetQueueEntry / ImportNode");
      check(ports.queue.selectEntry(tenant, ImportQueueEntryId(key), body["isSelected"].get!bool));
      break;
    }
    default: {
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is not updatable");
    }
    }
    return requireEntity(set, tenant, key);
  }

  protected void deleteEntity(const ODataEntitySetDef set, RequestIdentity identity, string key) {
    auto tenant = identity.tenantId;
    auto by = identity.userName;
    switch (set.name) {
    case "TransportNodes": {
      check(ports.nodes.deleteNode(tenant, TransportNodeId(key)));
      return;
    }
    case "TransportRoutes": {
      check(ports.routes.deleteRoute(tenant, TransportRouteId(key)));
      return;
    }
    case "TransportRequests": {
      check(ports.requests.deleteRequest(tenant, TransportRequestId(key), by));
      return;
    }
    case "ImportQueueEntries": {
      check(ports.queue.deleteEntry(tenant, ImportQueueEntryId(key), by));
      return;
    }
    default: {
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is not deletable");
    }
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  protected void invokeAction(HTTPServerResponse res, string action, RequestIdentity identity, Json body) {
    auto t = identity.tenantId;
    auto by = identity.userName.length ? identity.userName : identity.userId.value;
    string param(string name, bool required = true) {
      auto v = body.fieldString(name);
      if (required && v.length == 0)
        throw new ODataError(400, "MissingParameter", action ~ ": parameter '" ~ name ~ "' is required");
      return v;
    }

    UsecaseResult result;
    switch (action) {
    case "ExportRequest": {
      ExportInput ex;
      ex.tenantId = t;
      ex.requestId = TransportRequestId(param("requestId"));
      ex.nodeId = TransportNodeId(param("nodeId", false));
      ex.performedBy = by;
      result = ports.operations.exportRequest(ex);
      break;
    }
    case "ImportNode": {
      ImportInput im;
      im.tenantId = t;
      im.nodeId = TransportNodeId(param("nodeId"));
      foreach (id; body.fieldStrings("entryIds"))
        im.entryIds ~= ImportQueueEntryId(id);
      im.performedBy = by;
      result = ports.operations.importNode(im);
      break;
    }
    case "ForwardRequest": {
      ForwardInput fw;
      fw.tenantId = t;
      fw.requestId = TransportRequestId(param("requestId"));
      fw.fromNodeId = TransportNodeId(param("fromNodeId"));
      fw.performedBy = by;
      result = ports.operations.forwardRequest(fw);
      break;
    }
    case "ResetQueueEntry": {
      result = ports.queue.resetEntry(t, ImportQueueEntryId(param("entryId")), by);
      break;
    }
    case "EnableNode": {
      result = ports.nodes.enableNode(t, TransportNodeId(param("nodeId")));
      break;
    }
    case "DisableNode": {
      result = ports.nodes.disableNode(t, TransportNodeId(param("nodeId")));
      break;
    }
    case "CheckConnection": {
      result = ports.operations.checkConnection(t, TransportNodeId(param("nodeId")));
      break;
    }
    case "EnableRoute": {
      result = ports.routes.enableRoute(t, TransportRouteId(param("routeId")));
      break;
    }
    case "DisableRoute": {
      result = ports.routes.disableRoute(t, TransportRouteId(param("routeId")));
      break;
    }
    default: {
      throw new ODataError(404, "NotFound", "Unknown action " ~ action);
    }
    }
    check(result);
    auto payload = toOperationResult(result);
    payload["@odata.context"] = "$metadata#" ~ model.qualified("OperationResult");
    writeJson(res, 200, payload);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Map a failed use case result to an OData error.
  protected UsecaseResult check(UsecaseResult result) {
    if (result.isSuccess)
      return result;
    int status = result.code == 404 ? 404 : result.code == 409 ? 409 : result.code == 422 ? 422 : 400;
    auto code = status == 404 ? "NotFound" : status == 409 ? "Conflict"
      : status == 422 ? "BusinessRuleViolation" : "BadRequest";
    throw new ODataError(status, code, result.message.length > 0 ? result.message : "Request failed");
  }

  protected Json requestBody(HTTPServerRequest req, bool allowEmpty = false) {
    Json body;
    try
      body = req.json;
    catch (Exception e) {
      if (allowEmpty)
        return Json.emptyObject;
      throw new ODataError(400, "InvalidPayload", "Request body is not valid JSON: " ~ e.msg);
    }
    if (body.type == Json.Type.undefined && allowEmpty)
      return Json.emptyObject;
    if (body.type != Json.Type.object)
      throw new ODataError(400, "InvalidPayload", "Request body must be a JSON object");
    return body;
  }

  protected static bool ieee754Compatible(HTTPServerRequest req) {
    return req.headers.get("Accept", "").canFind("IEEE754Compatible=true")
      || req.headers.get("Content-Type", "").canFind("IEEE754Compatible=true");
  }

  protected void writeEntity(HTTPServerResponse res, int status, string context, Json entity) {
    auto payload = Json.emptyObject;
    payload["@odata.context"] = context;
    foreach (k, v; entity.get!(Json[string]))
      payload[k] = v;
    writeJson(res, status, payload);
  }

  protected static void writeJson(HTTPServerResponse res, int status, Json payload) {
    res.headers["OData-Version"] = "4.0";
    res.writeBody(payload.toString, status, "application/json;odata.metadata=minimal");
  }

  protected static void writeError(HTTPServerResponse res, int status, string code, string message) {
    auto err = Json.emptyObject;
    err["code"] = code;
    err["message"] = message;
    auto payload = Json.emptyObject;
    payload["error"] = err;
    writeJson(res, status, payload);
  }
}

///
unittest {
  mixin(ShowTest!("parseResourcePath"));

  auto r = parseResourcePath("/TransportNodes");
  assert(r.name == "TransportNodes" && !r.hasKey && !r.countOnly);

  r = parseResourcePath("TransportNodes('a''b')");
  assert(r.name == "TransportNodes" && r.hasKey && r.key == "a'b");

  r = parseResourcePath("TransportRoutes(id='x')");
  assert(r.key == "x");

  r = parseResourcePath("ImportQueueEntries/$count");
  assert(r.countOnly && r.name == "ImportQueueEntries");

  r = parseResourcePath("ImportNode()");
  assert(r.name == "ImportNode" && !r.hasKey);
}
