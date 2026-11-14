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
///   POST   <base>/<Set>                    (if insertable)
///   PATCH  <base>/<Set>('<key>')           (if updatable)
///   DELETE <base>/<Set>('<key>')           (if deletable; Environments = deprovision)
///   GET    <base>/Overview                 singleton
///   POST   <base>/<Action>                 unbound actions, e.g. SuspendSubaccount {"id": "…"}
///
/// $batch is not supported — configure the UI5 model with groupId "$direct".
module uim.platform.management.presentation.odata.controller;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPMethod;
import vibe.textfilter.urlencode : urlDecode;
import uim.platform.management;
import uim.platform.management.presentation.odata.model;
import uim.platform.management.presentation.odata.metadata;
import uim.platform.management.presentation.odata.query;
import uim.platform.management.presentation.odata.serializers;

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

/// Parse "Subaccounts", "Subaccounts/$count", "Subaccounts('a')", "Subaccounts(id='a')".
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
  r.hasKey = r.key.length > 0; // "SeedDemoData()" is an action call, not a key
  return r;
}

class ManagementODataController {
  protected ODataServiceModel model;
  protected string basePath;
  protected string defaultTenant;
  protected string metadataXml;
  protected ManagementPorts ports;

  this(ManagementPorts ports, string basePath, string defaultTenant) {
    this.ports = ports;
    this.model = managementODataModel();
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
        throw new ODataError(501, "NotImplemented", "$batch is not supported; use groupId $direct");

      auto identity = resolveIdentity(req.headers.get("Authorization", ""),
        req.headers.get("X-Tenant-Id", ""), req.headers.get("X-User-Id", ""), defaultTenant);

      if (model.actions.any!(a => a.name == resource.name)) {
        if (req.method != HTTPMethod.POST)
          throw new ODataError(405, "MethodNotAllowed", resource.name ~ " must be invoked with POST");
        return writeActionResult(res, invokeAction(resource.name, identity, optionalBody(req)));
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
      logError("management odata: %s", e.msg);
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
    case "GlobalAccounts":
      return ports.globalAccounts.listAccounts(tenant).map!(e => toOData(e)).array;
    case "Directories":
      auto counts = subaccountsPerDirectory(tenant);
      return ports.directories.listDirectories(tenant).map!(e => toOData(e, counts.get(e.id.value, 0))).array;
    case "Subaccounts":
      return ports.subaccounts.listSubaccounts(tenant).map!(e => toOData(e)).array;
    case "Entitlements":
      return ports.entitlements.listEntitlements(tenant).map!(e => toOData(e)).array;
    case "Environments":
      return ports.environments.listEnvironments(tenant).map!(e => toOData(e)).array;
    case "Subscriptions":
      return ports.subscriptions.listSubscriptions(tenant).map!(e => toOData(e)).array;
    case "ServicePlans":
      return ports.servicePlans.listPlans(tenant).map!(e => toOData(e)).array;
    case "Labels":
      return ports.labels.listLabels(tenant).map!(e => toOData(e)).array;
    case "Events":
      return ports.events.listEvents(tenant).map!(e => toOData(e)).array;
    default:
      throw new ODataError(404, "NotFound", "Unknown entity set " ~ set.name);
    }
  }

  protected size_t[string] subaccountsPerDirectory(TenantId tenant) {
    size_t[string] counts;
    foreach (s; ports.subaccounts.listSubaccounts(tenant))
      if (!s.parentDirectoryId.isEmpty)
        counts[s.parentDirectoryId.value] = counts.get(s.parentDirectoryId.value, 0) + 1;
    return counts;
  }

  /// Returns Json(null) if not found.
  protected Json entityOf(const ODataEntitySetDef set, TenantId tenant, string key) {
    Json wrap(T)(T e) {
      return e.isNull ? Json(null) : toOData(e);
    }

    switch (set.name) {
    case "GlobalAccounts":
      return wrap(ports.globalAccounts.getAccount(tenant, GlobalAccountId(key)));
    case "Directories":
      auto d = ports.directories.getDirectory(tenant, DirectoryId(key));
      return d.isNull ? Json(null) : toOData(d, ports.subaccounts.listSubaccounts(tenant, d.id).length);
    case "Subaccounts":
      return wrap(ports.subaccounts.getSubaccount(tenant, SubaccountId(key)));
    case "Entitlements":
      return wrap(ports.entitlements.getEntitlement(tenant, EntitlementId(key)));
    case "Environments":
      return wrap(ports.environments.getEnvironment(tenant, EnvironmentId(key)));
    case "Subscriptions":
      return wrap(ports.subscriptions.getSubscription(tenant, SubscriptionId(key)));
    case "ServicePlans":
      return wrap(ports.servicePlans.getPlan(tenant, ServicePlanId(key)));
    case "Labels":
      return wrap(ports.labels.getLabel(tenant, LabelId(key)));
    case "Events":
      return wrap(ports.events.getEvent(tenant, EnvironmentEventId(key)));
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
    if (set.name == "Overview")
      return toOData(ports.overview.getTenantOverview(identity.tenantId));
    throw new ODataError(404, "NotFound", "Unknown singleton " ~ set.name);
  }

  // ── Writing ─────────────────────────────────────────────────────────────

  protected Json createEntity(const ODataEntitySetDef set, RequestIdentity identity, Json body) {
    auto tenant = identity.tenantId;
    auto user = identity.userId;
    UsecaseResult result;

    switch (set.name) {
    case "GlobalAccounts":
      result = check(ports.globalAccounts.createAccount(toCreateGlobalAccountRequest(body, tenant, user)));
      break;
    case "Directories":
      result = check(ports.directories.createDirectory(toCreateDirectoryRequest(body, tenant, user)));
      break;
    case "Subaccounts":
      result = check(ports.subaccounts.createSubaccount(toCreateSubaccountRequest(body, tenant, user)));
      break;
    case "Entitlements":
      result = check(ports.entitlements.assignEntitlement(toAssignEntitlementRequest(body, tenant, user)));
      break;
    case "Environments":
      result = check(ports.environments.createEnvironment(toCreateEnvironmentRequest(body, tenant, user)));
      break;
    case "Subscriptions":
      result = check(ports.subscriptions.createSubscription(toCreateSubscriptionRequest(body, tenant, user)));
      break;
    case "ServicePlans":
      result = check(ports.servicePlans.createPlan(toCreateServicePlanRequest(body, tenant, user)));
      break;
    case "Labels":
      result = check(ports.labels.createLabel(toCreateLabelRequest(body, tenant, user)));
      break;
    default:
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is read-only");
    }
    return requireEntity(set, tenant, result.id);
  }

  protected Json updateEntity(const ODataEntitySetDef set, RequestIdentity identity, string key, Json body) {
    auto tenant = identity.tenantId;
    auto user = identity.userId;

    T current(T)(T entity) {
      if (entity.isNull)
        throw new ODataError(404, "NotFound", set.entityType ~ " '" ~ key ~ "' not found");
      return entity;
    }

    switch (set.name) {
    case "GlobalAccounts":
      auto e = current(ports.globalAccounts.getAccount(tenant, GlobalAccountId(key)));
      check(ports.globalAccounts.updateAccount(toUpdateGlobalAccountRequest(body, e, user)));
      break;
    case "Directories":
      auto e = current(ports.directories.getDirectory(tenant, DirectoryId(key)));
      check(ports.directories.updateDirectory(toUpdateDirectoryRequest(body, e)));
      break;
    case "Subaccounts":
      auto e = current(ports.subaccounts.getSubaccount(tenant, SubaccountId(key)));
      check(ports.subaccounts.updateSubaccount(toUpdateSubaccountRequest(body, e)));
      break;
    case "Entitlements":
      auto e = current(ports.entitlements.getEntitlement(tenant, EntitlementId(key)));
      check(ports.entitlements.updateEntitlementQuota(toUpdateEntitlementQuotaRequest(body, e)));
      break;
    case "Environments":
      auto e = current(ports.environments.getEnvironment(tenant, EnvironmentId(key)));
      check(ports.environments.updateEnvironment(toUpdateEnvironmentRequest(body, e)));
      break;
    case "Subscriptions":
      auto e = current(ports.subscriptions.getSubscription(tenant, SubscriptionId(key)));
      check(ports.subscriptions.updateSubscriptionPlan(toUpdateSubscriptionRequest(body, e)));
      break;
    case "ServicePlans":
      auto e = current(ports.servicePlans.getPlan(tenant, ServicePlanId(key)));
      check(ports.servicePlans.updatePlan(toUpdateServicePlanRequest(body, e, user)));
      break;
    case "Labels":
      auto e = current(ports.labels.getLabel(tenant, LabelId(key)));
      check(ports.labels.updateLabel(tenant, e.id, toUpdateLabelRequest(body, e, user)));
      break;
    default:
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is not updatable");
    }
    return requireEntity(set, tenant, key);
  }

  protected void deleteEntity(const ODataEntitySetDef set, RequestIdentity identity, string key) {
    auto tenant = identity.tenantId;
    switch (set.name) {
    case "GlobalAccounts":
      check(ports.globalAccounts.deleteAccount(tenant, GlobalAccountId(key)));
      return;
    case "Directories":
      check(ports.directories.deleteDirectory(tenant, DirectoryId(key)));
      return;
    case "Subaccounts":
      check(ports.subaccounts.deleteSubaccount(tenant, SubaccountId(key)));
      return;
    case "Entitlements":
      check(ports.entitlements.deleteEntitlement(tenant, EntitlementId(key)));
      return;
    case "Environments":
      check(ports.environments.deprovisionEnvironment(tenant, EnvironmentId(key)));
      return;
    case "ServicePlans":
      check(ports.servicePlans.deletePlan(tenant, ServicePlanId(key)));
      return;
    case "Labels":
      check(ports.labels.deleteLabel(tenant, LabelId(key)));
      return;
    default:
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is not deletable");
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  protected UsecaseResult invokeAction(string action, RequestIdentity identity, Json body) {
    auto tenant = identity.tenantId;
    string id() {
      auto v = fieldString(body, "id");
      if (v.length == 0)
        throw new ODataError(400, "MissingParameter", action ~ " requires the parameter 'id'");
      return v;
    }

    switch (action) {
    case "SuspendGlobalAccount":
      return check(ports.globalAccounts.suspendAccount(tenant, GlobalAccountId(id())));
    case "ReactivateGlobalAccount":
      return check(ports.globalAccounts.reactivateAccount(tenant, GlobalAccountId(id())));
    case "SuspendSubaccount":
      return check(ports.subaccounts.suspendSubaccount(tenant, SubaccountId(id())));
    case "ReactivateSubaccount":
      return check(ports.subaccounts.reactivateSubaccount(tenant, SubaccountId(id())));
    case "MoveSubaccount":
      auto sub = SubaccountId(id());
      MoveSubaccountRequest r;
      r.tenantId = tenant;
      r.subaccountId = sub;
      r.targetDirectoryId = DirectoryId(fieldString(body, "targetDirectoryId"));
      r.movedBy = identity.userId;
      return check(ports.subaccounts.moveSubaccount(tenant, sub, r));
    case "RevokeEntitlement":
      return check(ports.entitlements.revokeEntitlement(tenant, EntitlementId(id())));
    case "Unsubscribe":
      return check(ports.subscriptions.unsubscribeSubscription(tenant, SubscriptionId(id())));
    case "SeedDemoData":
      return check(ports.demoData.seed(tenant));
    default:
      throw new ODataError(404, "NotFound", "Unknown action " ~ action);
    }
  }

  protected void writeActionResult(HTTPServerResponse res, UsecaseResult result) {
    auto payload = Json.emptyObject;
    payload["@odata.context"] = "$metadata#" ~ model.qualified("ActionResult");
    payload["id"] = result.id;
    payload["success"] = result.isSuccess;
    payload["message"] = result.message;
    writeJson(res, 200, payload);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Map a failed use case result to an OData error.
  protected UsecaseResult check(UsecaseResult result) {
    if (result.isSuccess)
      return result;
    int status;
    string code;
    switch (result.code) {
    case ResultCode.notFound:
      status = 404;
      code = "NotFound";
      break;
    case ResultCode.conflict:
      status = 409;
      code = "Conflict";
      break;
    case ResultCode.ruleViolation:
      status = 422;
      code = "BusinessRuleViolation";
      break;
    default:
      status = 400;
      code = "BadRequest";
    }
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

  /// Actions without parameters may be posted with an empty body.
  protected Json optionalBody(HTTPServerRequest req) {
    try {
      auto body = req.json;
      return body.type == Json.Type.object ? body : Json.emptyObject;
    } catch (Exception) {
      return Json.emptyObject;
    }
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

  auto r = parseResourcePath("/Subaccounts");
  assert(r.name == "Subaccounts" && !r.hasKey && !r.countOnly);

  r = parseResourcePath("Subaccounts('a''b')");
  assert(r.name == "Subaccounts" && r.hasKey && r.key == "a'b");

  r = parseResourcePath("Labels(id='x')");
  assert(r.key == "x");

  r = parseResourcePath("Events/$count");
  assert(r.countOnly && r.name == "Events");

  r = parseResourcePath("SeedDemoData()");
  assert(r.name == "SeedDemoData" && !r.hasKey);
}
