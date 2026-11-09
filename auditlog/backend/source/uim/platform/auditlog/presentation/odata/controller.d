/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// OData v4 endpoint for SAP Fiori / UI5 (sap.ui.model.odata.v4.ODataServiceModel).
///
///   GET    <base>/                         service document
///   GET    <base>/$metadata                CSDL (EDMX)
///   GET    <base>/<Set>[?$filter&$orderby&$select&$top&$skip&$count&$search]
///   GET    <base>/<Set>/$count
///   GET    <base>/<Set>('<key>')
///   POST   <base>/<Set>                    (if insertable)
///   PATCH  <base>/<Set>('<key>')           (if updatable)
///   DELETE <base>/<Set>('<key>')           (if deletable)
///   GET    <base>/Statistics               singleton
///   POST   <base>/EnforceRetention         unbound action
///
/// $batch is not supported — configure the UI5 model with groupId "$direct".
module uim.platform.auditlog.presentation.odata.controller;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPMethod;
import vibe.textfilter.urlencode : urlDecode;
import uim.platform.auditlog;
import uim.platform.auditlog.presentation.odata.model;
import uim.platform.auditlog.presentation.odata.metadata;
import uim.platform.auditlog.presentation.odata.query;
import uim.platform.auditlog.presentation.odata.serializers;

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

/// Parse "AuditLogs", "AuditLogs/$count", "AuditLogs('a')", "AuditLogs(id='a')".
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
  r.hasKey = true;
  // "EnforceRetention()" is an action call, not a key
  if (r.key.length == 0)
    r.hasKey = false;
  return r;
}

class AuditLogODataController {
  protected ODataServiceModel model;
  protected string basePath;
  protected string defaultTenant;
  protected string metadataXml;

  protected IWriteAuditLogUseCase writeAuditLog;
  protected IRetrieveAuditLogsUseCase retrieveAuditLogs;
  protected IBrowseAuditRecordsUseCase browseRecords;
  protected IWriteSecurityEventUseCase writeSecurityEvent;
  protected IWriteDataAccessLogUseCase writeDataAccessLog;
  protected IWriteConfigChangeUseCase writeConfigChange;
  protected IManageRetentionUseCase manageRetention;
  protected IEnforceRetentionUseCase enforceRetention;
  protected IManageAuditConfigUseCase manageAuditConfig;
  protected IManageExportsUseCase manageExports;
  protected IAuditStatisticsService statistics;

  this(AuditLogPorts c, string basePath, string defaultTenant) {
    this.model = auditLogODataModel();
    this.basePath = basePath.stripRight("/");
    this.defaultTenant = defaultTenant;
    this.metadataXml = buildMetadataXml(model);

    writeAuditLog = c.writeAuditLog;
    retrieveAuditLogs = c.retrieveAuditLogs;
    browseRecords = c.browseRecords;
    writeSecurityEvent = c.writeSecurityEvent;
    writeDataAccessLog = c.writeDataAccessLog;
    writeConfigChange = c.writeConfigChange;
    manageRetention = c.manageRetention;
    enforceRetention = c.enforceRetention;
    manageAuditConfig = c.manageAuditConfig;
    manageExports = c.manageExports;
    statistics = c.statistics;
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

      // unbound action
      if (resource.name == "EnforceRetention") {
        if (req.method != HTTPMethod.POST)
          throw new ODataError(405, "MethodNotAllowed", "EnforceRetention must be invoked with POST");
        return invokeEnforceRetention(res, identity);
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
      logError("auditlog odata: %s", e.msg);
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

  protected Json[] rowsOf(const ODataEntitySetDef set, TenantId tenant) {
    switch (set.name) {
    case "AuditLogs":
      AuditLogQueryRequest q;
      q.tenantId = tenant;
      q.limit = int.max;
      return retrieveAuditLogs.queryAuditLogs(q).map!(e => toOData(e)).array;
    case "SecurityEvents":
      return browseRecords.listSecurityEvents(tenant).map!(e => toOData(e)).array;
    case "DataAccessLogs":
      return browseRecords.listDataAccessLogs(tenant).map!(e => toOData(e)).array;
    case "ConfigChangeLogs":
      return browseRecords.listConfigChangeLogs(tenant).map!(e => toOData(e)).array;
    case "RetentionPolicies":
      return manageRetention.listPolicies(tenant).map!(e => toOData(e)).array;
    case "AuditConfigs":
      return manageAuditConfig.listAuditConfigs(tenant).map!(e => toOData(e)).array;
    case "ExportJobs":
      return manageExports.listExports(tenant).map!(e => toOData(e)).array;
    default:
      throw new ODataError(404, "NotFound", "Unknown entity set " ~ set.name);
    }
  }

  /// Returns Json(null) if not found.
  protected Json entityOf(const ODataEntitySetDef set, TenantId tenant, string key) {
    Json wrap(T)(T e) {
      return e.isNull ? Json(null) : toOData(e);
    }

    switch (set.name) {
    case "AuditLogs":
      return wrap(retrieveAuditLogs.getAuditLog(tenant, AuditLogId(key)));
    case "SecurityEvents":
      return wrap(browseRecords.getSecurityEvent(tenant, SecurityEventId(key)));
    case "DataAccessLogs":
      return wrap(browseRecords.getDataAccessLog(tenant, DataAccessLogId(key)));
    case "ConfigChangeLogs":
      return wrap(browseRecords.getConfigChangeLog(tenant, ConfigChangeLogId(key)));
    case "RetentionPolicies":
      return wrap(manageRetention.getPolicy(tenant, RetentionPolicyId(key)));
    case "AuditConfigs":
      foreach (c; manageAuditConfig.listAuditConfigs(tenant))
        if (c.id.value == key)
          return toOData(c);
      return Json(null);
    case "ExportJobs":
      return wrap(manageExports.getExport(tenant, ExportJobId(key)));
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
      return toOData(statistics.statistics(identity.tenantId));
    throw new ODataError(404, "NotFound", "Unknown singleton " ~ set.name);
  }

  // ── Writing ─────────────────────────────────────────────────────────────

  protected Json createEntity(const ODataEntitySetDef set, RequestIdentity identity, Json body) {
    auto tenant = identity.tenantId;
    UsecaseResult result;

    // find a detail record by the id of its parent audit entry
    Json detailOf(T)(T[] records) {
      foreach (r; records)
        if (r.auditLogId.value == result.id)
          return toOData(r);
      throw new ODataError(500, "InternalError", "Created record not found");
    }

    switch (set.name) {
    case "AuditLogs":
      auto req = toWriteAuditLogRequest(body, tenant);
      if (req.userId.isEmpty)
        req.userId = identity.userId;
      result = check(writeAuditLog.writeAuditLog(req));
      return requireEntity(set, tenant, result.id);

    case "SecurityEvents":
      result = check(writeSecurityEvent.writeEvent(toWriteSecurityEventRequest(body, tenant)));
      return detailOf(browseRecords.listSecurityEvents(tenant));

    case "DataAccessLogs":
      result = check(writeDataAccessLog.writeLog(toWriteDataAccessLogRequest(body, tenant)));
      return detailOf(browseRecords.listDataAccessLogs(tenant));

    case "ConfigChangeLogs":
      result = check(writeConfigChange.writeChange(toWriteConfigChangeRequest(body, tenant)));
      return detailOf(browseRecords.listConfigChangeLogs(tenant));

    case "RetentionPolicies":
      result = check(manageRetention.createPolicy(toCreateRetentionPolicyRequest(body, tenant)));
      return requireEntity(set, tenant, result.id);

    case "AuditConfigs":
      result = check(manageAuditConfig.createAuditConfig(toCreateAuditConfigRequest(body, tenant)));
      return requireEntity(set, tenant, result.id);

    case "ExportJobs":
      auto caller = identity.userId.isEmpty ? UserId("anonymous") : identity.userId;
      result = check(manageExports.createExport(toCreateExportJobRequest(body, tenant, caller)));
      return requireEntity(set, tenant, result.id);

    default:
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is read-only");
    }
  }

  protected Json updateEntity(const ODataEntitySetDef set, RequestIdentity identity, string key, Json body) {
    auto tenant = identity.tenantId;
    switch (set.name) {
    case "RetentionPolicies":
      auto current = manageRetention.getPolicy(tenant, RetentionPolicyId(key));
      if (current.isNull)
        throw new ODataError(404, "NotFound", "RetentionPolicy '" ~ key ~ "' not found");
      check(manageRetention.updatePolicy(toUpdateRetentionPolicyRequest(body, current)));
      return requireEntity(set, tenant, key);

    case "AuditConfigs":
      AuditConfig current;
      foreach (c; manageAuditConfig.listAuditConfigs(tenant))
        if (c.id.value == key)
          current = c;
      if (current.isNull)
        throw new ODataError(404, "NotFound", "AuditConfig '" ~ key ~ "' not found");
      check(manageAuditConfig.updateAuditConfig(toUpdateAuditConfigRequest(body, current)));
      return requireEntity(set, tenant, key);

    default:
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is not updatable");
    }
  }

  protected void deleteEntity(const ODataEntitySetDef set, RequestIdentity identity, string key) {
    auto tenant = identity.tenantId;
    switch (set.name) {
    case "RetentionPolicies":
      check(manageRetention.deletePolicy(tenant, RetentionPolicyId(key)));
      return;
    case "AuditConfigs":
      check(manageAuditConfig.deleteAuditConfig(tenant, AuditConfigId(key)));
      return;
    case "ExportJobs":
      check(manageExports.deleteExport(tenant, ExportJobId(key)));
      return;
    default:
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is not deletable");
    }
  }

  protected void invokeEnforceRetention(HTTPServerResponse res, RequestIdentity identity) {
    auto result = check(enforceRetention.enforce(identity.tenantId));
    auto payload = Json.emptyObject;
    payload["@odata.context"] = "$metadata#" ~ model.qualified("RetentionResult");
    payload["tenantId"] = identity.tenantId.value;
    payload["retentionDays"] = result.data["retentionDays"];
    payload["removed"] = cast(int) result.data["removed"].get!long;
    payload["cutoff"] = odataTime(result.data["cutoff"].get!long);
    writeJson(res, 200, payload);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Map a failed use case result to an OData error.
  protected UsecaseResult check(UsecaseResult result) {
    if (result.isSuccess)
      return result;
    auto status = result.code == 404 ? 404 : (result.code == 422 ? 422 : 400);
    auto code = status == 404 ? "NotFound" : (status == 422 ? "BusinessRuleViolation" : "BadRequest");
    throw new ODataError(status, code, result.message.length > 0 ? result.message : "Request failed");
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

  auto r = parseResourcePath("/AuditLogs");
  assert(r.name == "AuditLogs" && !r.hasKey && !r.countOnly);

  r = parseResourcePath("AuditLogs('a''b')");
  assert(r.name == "AuditLogs" && r.hasKey && r.key == "a'b");

  r = parseResourcePath("RetentionPolicies(id='x')");
  assert(r.key == "x");

  r = parseResourcePath("AuditLogs/$count");
  assert(r.countOnly && r.name == "AuditLogs");

  r = parseResourcePath("EnforceRetention()");
  assert(r.name == "EnforceRetention" && !r.hasKey);
}
