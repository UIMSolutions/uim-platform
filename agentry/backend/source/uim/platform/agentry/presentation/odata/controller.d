/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// OData v4 endpoint for SAP Fiori / UI5 (sap.ui.model.odata.v4.ODataModel).
///
///   GET    <base>/                         service document
///   GET    <base>/$metadata                CSDL (EDMX)
///   GET    <base>/<Set>[?$filter&$orderby&$select&$top&$skip&$count&$search]
///   GET    <base>/<Set>/$count
///   GET    <base>/<Set>('<key>')
///   POST   <base>/<Set>
///   PATCH  <base>/<Set>('<key>')
///   DELETE <base>/<Set>('<key>')
///   GET    <base>/Statistics               singleton
///   POST   <base>/<Action>                 unbound actions, JSON body {"id": ..., ...}
///
/// $batch is not supported — configure the UI5 model with groupId "$direct".
module uim.platform.agentry.presentation.odata.controller;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPMethod;
import vibe.textfilter.urlencode : urlDecode;
import uim.platform.agentry;
import uim.platform.agentry.presentation.odata.model;
import uim.platform.agentry.presentation.odata.metadata;
import uim.platform.agentry.presentation.odata.query;
import uim.platform.agentry.presentation.odata.serializers;

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

/// Parse "Devices", "Devices/$count", "Devices('a')", "Devices(id='a')".
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
  r.hasKey = r.key.length > 0; // "Action()" is a call, not a key
  return r;
}

class AgentryODataController {
  protected ODataServiceModel model;
  protected string basePath;
  protected string defaultTenant;
  protected string metadataXml;
  protected AgentryPorts ports;

  this(AgentryPorts ports, string basePath, string defaultTenant) {
    this.ports = ports;
    this.model = agentryODataModel();
    this.basePath = basePath.stripRight("/");
    this.defaultTenant = defaultTenant;
    this.metadataXml = buildMetadataXml(model);
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
      if (resource.name == "$batch")
        throw new ODataError(501, "NotImplemented", "$batch is not supported — use groupId $direct");

      auto identity = resolveIdentity(req.headers.get("Authorization", ""),
        req.headers.get("X-Tenant-Id", ""), req.headers.get("X-User-Id", ""), defaultTenant);
      auto ieee754 = ieee754Compatible(req);

      if (model.hasAction(resource.name)) {
        if (req.method != HTTPMethod.POST)
          throw new ODataError(405, "MethodNotAllowed", resource.name ~ " must be invoked with POST");
        auto action = model.findAction(resource.name);
        auto set = model.find(action.returnEntitySet);
        auto result = invokeAction(action.name, identity, optionalBody(req));
        return writeEntity(res, 200, "$metadata#" ~ set.name ~ "/$entity", adapt(result, set, ieee754));
      }

      if (!model.has(resource.name))
        throw new ODataError(404, "NotFound", "Unknown resource '" ~ resource.name ~ "'");
      auto set = model.find(resource.name);

      switch (req.method) {
      case HTTPMethod.GET:
        if (set.singleton)
          return writeEntity(res, 200, "$metadata#" ~ set.name, adapt(singletonOf(set, identity), set, ieee754));
        if (resource.hasKey)
          return writeEntity(res, 200, "$metadata#" ~ set.name ~ "/$entity",
            adapt(requireEntity(set, identity.tenantId, resource.key), set, ieee754));
        return readCollection(req, res, set, identity, resource.countOnly, ieee754);

      case HTTPMethod.POST:
        if (!set.insertable || resource.hasKey)
          throw new ODataError(405, "MethodNotAllowed", set.name ~ " does not support POST here");
        auto created = createEntity(set, identity, requestBody(req));
        res.headers["Location"] = basePath ~ "/" ~ set.name ~ "('" ~ created["id"].get!string ~ "')";
        return writeEntity(res, 201, "$metadata#" ~ set.name ~ "/$entity", adapt(created, set, ieee754));

      case HTTPMethod.PATCH, HTTPMethod.PUT:
        if (!set.updatable || !resource.hasKey)
          throw new ODataError(405, "MethodNotAllowed", set.name ~ " does not support updates");
        return writeEntity(res, 200, "$metadata#" ~ set.name ~ "/$entity",
          adapt(updateEntity(set, identity, resource.key, requestBody(req)), set, ieee754));

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
    } catch (PayloadException e) {
      writeError(res, 400, "InvalidPayload", e.msg);
    } catch (Exception e) {
      logError("agentry odata: %s", e.msg);
      writeError(res, 500, "InternalError", e.msg);
    }
  }

  // ── Reading ─────────────────────────────────────────────────────────────

  protected void readCollection(HTTPServerRequest req, HTTPServerResponse res,
      const ODataEntitySetDef set, RequestIdentity identity, bool countOnly, bool ieee754) {
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
      payload["@odata.count"] = ieee754 ? Json(total.to!string) : Json(total);
    auto value = Json.emptyArray;
    foreach (row; page)
      value ~= adapt(row, set, ieee754);
    payload["value"] = value;
    writeJson(res, 200, payload);
  }

  protected Json[] rowsOf(const ODataEntitySetDef set, TenantId t) {
    switch (set.name) {
    case "MobileApplications":
      return ports.mobileApplications.listMobileApplications(t).map!(e => toOData(e)).array;
    case "AppDefinitions":
      return ports.appDefinitions.listDefinitions(t).map!(e => toOData(e)).array;
    case "AppVersions":
      return ports.appVersions.listAppVersions(t).map!(e => toOData(e)).array;
    case "Devices":
      return ports.devices.listDevices(t).map!(e => toOData(e)).array;
    case "SyncSessions":
      return ports.syncSessions.listSyncSessions(t).map!(e => toOData(e)).array;
    case "BackendConnections":
      return ports.backendConnections.listBackendConnections(t).map!(e => toOData(e)).array;
    case "Deployments":
      return ports.deployments.listDeployments(t).map!(e => toOData(e)).array;
    default:
      throw new ODataError(404, "NotFound", "Unknown entity set " ~ set.name);
    }
  }

  /// Returns Json(null) if not found.
  protected Json entityOf(const ODataEntitySetDef set, TenantId t, string key) {
    Json wrap(T)(T e) {
      return e.isNull ? Json(null) : toOData(e);
    }

    switch (set.name) {
    case "MobileApplications":
      return wrap(ports.mobileApplications.getMobileApplication(t, MobileApplicationId(key)));
    case "AppDefinitions":
      return wrap(ports.appDefinitions.getDefinition(t, AppDefinitionId(key)));
    case "AppVersions":
      return wrap(ports.appVersions.getAppVersion(t, AppVersionId(key)));
    case "Devices":
      return wrap(ports.devices.getDevice(t, DeviceId(key)));
    case "SyncSessions":
      return wrap(ports.syncSessions.getSyncSession(t, SyncSessionId(key)));
    case "BackendConnections":
      return wrap(ports.backendConnections.getBackendConnection(t, BackendConnectionId(key)));
    case "Deployments":
      return wrap(ports.deployments.getDeployment(t, DeploymentId(key)));
    default:
      return Json(null);
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
    auto t = identity.tenantId;
    UsecaseResult create(TDTO)(scope UsecaseResult delegate(TDTO) @safe call) {
      TDTO dto;
      readPayload(dto, body);
      dto.tenantId = t;
      dto.createdBy = identity.userId;
      return check(call(dto));
    }

    UsecaseResult result;
    switch (set.name) {
    case "MobileApplications":
      result = create!MobileApplicationDTO(d => ports.mobileApplications.createMobileApplication(d));
      break;
    case "AppDefinitions":
      result = create!AppDefinitionDTO(d => ports.appDefinitions.createDefinition(d));
      break;
    case "AppVersions":
      result = create!AppVersionDTO(d => ports.appVersions.createAppVersion(d));
      break;
    case "Devices":
      result = create!DeviceDTO(d => ports.devices.enrollDevice(d));
      break;
    case "SyncSessions":
      result = create!SyncSessionDTO(d => ports.syncSessions.createSyncSession(d));
      break;
    case "BackendConnections":
      result = create!BackendConnectionDTO(d => ports.backendConnections.createBackendConnection(d));
      break;
    case "Deployments":
      result = create!DeploymentDTO(d => ports.deployments.createDeployment(d));
      break;
    default:
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is read-only");
    }
    return requireEntity(set, t, result.id);
  }

  protected Json updateEntity(const ODataEntitySetDef set, RequestIdentity identity, string key, Json body) {
    auto t = identity.tenantId;
    // merge: current entity → DTO, overlay the PATCH body, update
    void merge(TDTO, TEntity)(TEntity current, scope UsecaseResult delegate(TDTO) @safe call) {
      if (current.isNull)
        throw new ODataError(404, "NotFound", set.entityType ~ " '" ~ key ~ "' not found");
      auto dto = TDTO.fromEntity(current);
      readPayload(dto, body);
      dto.tenantId = t;
      dto.updatedBy = identity.userId;
      check(call(dto));
    }

    switch (set.name) {
    case "MobileApplications":
      merge!MobileApplicationDTO(ports.mobileApplications.getMobileApplication(t, MobileApplicationId(key)), (d) {
        d.applicationId = MobileApplicationId(key);
        return ports.mobileApplications.updateMobileApplication(d);
      });
      break;
    case "AppDefinitions":
      merge!AppDefinitionDTO(ports.appDefinitions.getDefinition(t, AppDefinitionId(key)), (d) {
        d.definitionId = AppDefinitionId(key);
        return ports.appDefinitions.updateDefinition(d);
      });
      break;
    case "AppVersions":
      merge!AppVersionDTO(ports.appVersions.getAppVersion(t, AppVersionId(key)), (d) {
        d.versionId = AppVersionId(key);
        return ports.appVersions.updateAppVersion(d);
      });
      break;
    case "Devices":
      merge!DeviceDTO(ports.devices.getDevice(t, DeviceId(key)), (d) {
        d.deviceId = DeviceId(key);
        return ports.devices.updateDevice(d);
      });
      break;
    case "SyncSessions":
      merge!SyncSessionDTO(ports.syncSessions.getSyncSession(t, SyncSessionId(key)), (d) {
        d.sessionId = SyncSessionId(key);
        return ports.syncSessions.updateSyncSession(d);
      });
      break;
    case "BackendConnections":
      merge!BackendConnectionDTO(ports.backendConnections.getBackendConnection(t, BackendConnectionId(key)), (d) {
        d.connectionId = BackendConnectionId(key);
        return ports.backendConnections.updateBackendConnection(d);
      });
      break;
    case "Deployments":
      merge!DeploymentDTO(ports.deployments.getDeployment(t, DeploymentId(key)), (d) {
        d.deploymentId = DeploymentId(key);
        return ports.deployments.updateDeployment(d);
      });
      break;
    default:
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is not updatable");
    }
    return requireEntity(set, t, key);
  }

  protected void deleteEntity(const ODataEntitySetDef set, RequestIdentity identity, string key) {
    auto t = identity.tenantId;
    switch (set.name) {
    case "MobileApplications":
      check(ports.mobileApplications.deleteMobileApplication(t, MobileApplicationId(key)));
      return;
    case "AppDefinitions":
      check(ports.appDefinitions.deleteDefinition(t, AppDefinitionId(key)));
      return;
    case "AppVersions":
      check(ports.appVersions.deleteAppVersion(t, AppVersionId(key)));
      return;
    case "Devices":
      check(ports.devices.removeDevice(t, DeviceId(key)));
      return;
    case "SyncSessions":
      check(ports.syncSessions.deleteSyncSession(t, SyncSessionId(key)));
      return;
    case "BackendConnections":
      check(ports.backendConnections.deleteBackendConnection(t, BackendConnectionId(key)));
      return;
    case "Deployments":
      check(ports.deployments.deleteDeployment(t, DeploymentId(key)));
      return;
    default:
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is not deletable");
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  /// Run an unbound action and return the affected entity (OData JSON).
  protected Json invokeAction(string name, RequestIdentity identity, Json body) {
    auto t = identity.tenantId;
    auto by = identity.userId;
    string id;
    readString(body, "id", id);
    if (id.length == 0)
      throw new ODataError(400, "InvalidPayload", name ~ ": parameter 'id' is required");

    string text(string key) {
      string v;
      readString(body, key, v);
      return v;
    }

    long number(string key) {
      long v;
      readLong(body, key, v);
      return v;
    }

    E status(E)() {
      E value;
      if (!tryParseEnum!E(text("status"), value))
        throw new ODataError(400, "InvalidPayload", "status must be one of " ~ enumValues!E().join(", "));
      return value;
    }

    UsecaseResult r;
    string set;
    switch (name) {
    case "SetMobileApplicationStatus":
      r = ports.mobileApplications.setMobileApplicationStatus(t, MobileApplicationId(id), status!AppStatus, by);
      set = "MobileApplications";
      break;
    case "ValidateAppDefinition":
      r = ports.appDefinitions.validateDefinition(t, AppDefinitionId(id));
      set = "AppDefinitions";
      break;
    case "PublishAppDefinition":
      r = ports.appDefinitions.publishDefinition(t, AppDefinitionId(id), by);
      set = "AppDefinitions";
      break;
    case "ArchiveAppDefinition":
      r = ports.appDefinitions.archiveDefinition(t, AppDefinitionId(id), by);
      set = "AppDefinitions";
      break;
    case "PublishAppVersion":
      r = ports.appVersions.publishAppVersion(t, AppVersionId(id), by);
      set = "AppVersions";
      break;
    case "WithdrawAppVersion":
      r = ports.appVersions.withdrawAppVersion(t, AppVersionId(id), by);
      set = "AppVersions";
      break;
    case "SetDeviceStatus":
      r = ports.devices.setDeviceStatus(t, DeviceId(id), status!DeviceStatus, by);
      set = "Devices";
      break;
    case "StartSyncSession":
      r = ports.syncSessions.startSyncSession(t, SyncSessionId(id));
      set = "SyncSessions";
      break;
    case "CompleteSyncSession":
      SyncMetricsDTO metrics;
      readPayload(metrics, body);
      r = ports.syncSessions.completeSyncSession(t, SyncSessionId(id), metrics);
      set = "SyncSessions";
      break;
    case "FailSyncSession":
      r = ports.syncSessions.failSyncSession(t, SyncSessionId(id), text("errorMessage"));
      set = "SyncSessions";
      break;
    case "CancelSyncSession":
      r = ports.syncSessions.cancelSyncSession(t, SyncSessionId(id));
      set = "SyncSessions";
      break;
    case "TestBackendConnection":
      r = ports.backendConnections.testBackendConnection(t, BackendConnectionId(id), by);
      set = "BackendConnections";
      break;
    case "StartDeployment":
      r = ports.deployments.startDeployment(t, DeploymentId(id), by);
      set = "Deployments";
      break;
    case "CompleteDeployment":
      r = ports.deployments.completeDeployment(t, DeploymentId(id), number("devicesSucceeded"), number("devicesFailed"));
      set = "Deployments";
      break;
    case "RollbackDeployment":
      r = ports.deployments.rollbackDeployment(t, DeploymentId(id), by);
      set = "Deployments";
      break;
    default:
      throw new ODataError(404, "NotFound", "Unknown action " ~ name);
    }
    check(r);
    return requireEntity(model.find(set), t, id);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Map a failed use case result to an OData error.
  protected UsecaseResult check(UsecaseResult result) {
    if (result.isSuccess)
      return result;
    auto status = httpStatusOf(result);
    auto code = status == 404 ? "NotFound" : status == 409 ? "Conflict"
      : status == 422 ? "BusinessRuleViolation" : "BadRequest";
    throw new ODataError(status, code, result.message.length > 0 ? result.message : "Request failed");
  }

  /// IEEE754Compatible=true: Edm.Int64 values are sent as strings (UI5 default).
  protected static Json adapt(Json row, const ODataEntitySetDef set, bool ieee754) {
    if (!ieee754 || row.type != Json.Type.object)
      return row;
    foreach (name; set.propertiesOfType(cast(string) Edm.int64))
      if (auto v = name in row)
        if (v.type == Json.Type.int_)
          row[name] = v.get!long.to!string;
    return row;
  }

  protected Json requestBody(HTTPServerRequest req) {
    Json body;
    try
      body = req.json;
    catch (Exception e)
      throw new ODataError(400, "InvalidPayload", "Request body is not valid JSON: " ~ e.msg);
    if (body.type != Json.Type.object)
      throw new ODataError(400, "InvalidPayload", "Request body must be a JSON object");
    return body;
  }

  /// Actions without parameters may be posted with an empty body.
  protected Json optionalBody(HTTPServerRequest req) {
    Json body;
    try
      body = req.json;
    catch (Exception e)
      throw new ODataError(400, "InvalidPayload", "Request body is not valid JSON: " ~ e.msg);
    return body.type == Json.Type.object ? body : Json.emptyObject;
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

  auto r = parseResourcePath("/Devices");
  assert(r.name == "Devices" && !r.hasKey && !r.countOnly);

  r = parseResourcePath("Devices('a''b')");
  assert(r.name == "Devices" && r.hasKey && r.key == "a'b");

  r = parseResourcePath("Deployments(id='x')");
  assert(r.key == "x");

  r = parseResourcePath("SyncSessions/$count");
  assert(r.countOnly && r.name == "SyncSessions");

  r = parseResourcePath("PublishAppVersion()");
  assert(r.name == "PublishAppVersion" && !r.hasKey);
}
