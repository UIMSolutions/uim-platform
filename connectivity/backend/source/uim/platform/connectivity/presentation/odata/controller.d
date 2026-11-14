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
///   POST   <base>/<Set>
///   PATCH  <base>/<Set>('<key>')           (PUT accepted)
///   DELETE <base>/<Set>('<key>')
///   GET    <base>/Statistics               singleton
///   POST   <base>/RunHealthCheck           unbound action
///   POST   <base>/CheckAccess              unbound action {"connector": "...", "url": "https://..."}
///   POST   <base>/<Action><Type>           unbound actions, e.g. OpenServiceChannel {"id": "..."}
///
/// $batch is not supported — configure the UI5 model with groupId "$direct".
module uim.platform.connectivity.presentation.odata.controller;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPMethod;
import vibe.textfilter.urlencode : urlDecode;
import uim.platform.connectivity;
import uim.platform.connectivity.presentation.resources;
import uim.platform.connectivity.presentation.odata.model;
import uim.platform.connectivity.presentation.odata.metadata;
import uim.platform.connectivity.presentation.odata.query;

mixin(ShowModule!());

@safe:

/// The parsed resource path (after the service root).
struct ODataResource {
  string name; /// entity set, singleton or action
  string key; /// entity key, if addressed
  bool hasKey;
  bool countOnly; /// <Set>/$count
}

/// Parse "Destinations", "Destinations/$count", "Destinations('a')", "Destinations(id='a')".
ODataResource parseResourcePath(string path) {
  ODataResource r;
  auto p = path.strip("/");
  if (p.endsWith("/$count")) {
    r.countOnly = true;
    p = p[0 .. $ - "/$count".length];
  }
  if (p.canFind("/"))
    throw new ResourceError(400, "UnsupportedPath", "Navigation paths are not supported: " ~ path);

  auto open = p.indexOf('(');
  if (open < 0) {
    r.name = p;
    return r;
  }
  if (!p.endsWith(")"))
    throw new ResourceError(400, "InvalidKey", "Invalid key in " ~ path);

  r.name = p[0 .. open];
  auto key = p[open + 1 .. $ - 1];
  auto eq = key.indexOf('=');
  if (eq >= 0)
    key = key[eq + 1 .. $];
  if (key.length >= 2 && key[0] == '\'' && key[$ - 1] == '\'')
    key = key[1 .. $ - 1].replace("''", "'");
  r.key = key;
  r.hasKey = r.key.length > 0; // "RunHealthCheck()" is an action call, not a key
  return r;
}

class ConnectivityODataController {
  protected ResourceRegistry registry;
  protected ODataServiceModel model;
  protected string basePath;
  protected string defaultTenant;
  protected string metadataXml;

  this(ResourceRegistry registry, string basePath, string defaultTenant) {
    this.registry = registry;
    this.model = connectivityODataModel(registry);
    this.basePath = basePath.stripRight("/");
    this.defaultTenant = defaultTenant;
    this.metadataXml = buildMetadataXml(model);
  }

  /// The generated CSDL document.
  string metadata() const {
    return metadataXml;
  }

  void registerRoutes(URLRouter router) {
    router.get(basePath, &handleServiceDocument);
    router.get(basePath ~ "/", &handleServiceDocument);
    router.get(basePath ~ "/$metadata", &handleMetadata);
    router.any(basePath ~ "/*", &handle);
  }

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

      // unbound actions
      if (resource.name == "RunHealthCheck") {
        requirePost(req, resource.name);
        auto payload = registry.healthCheck(identity.tenantId);
        payload["@odata.context"] = "$metadata#" ~ model.qualified("HealthCheckResult");
        return writeJson(res, 200, payload);
      }
      if (resource.name == "CheckAccess") {
        requirePost(req, resource.name);
        auto body = requestBody(req);
        auto payload = registry.checkAccess(identity, fieldString(body, "connector"), fieldString(body, "url"));
        payload["@odata.context"] = "$metadata#" ~ model.qualified("AccessCheckResult");
        return writeJson(res, 200, payload);
      }
      ResourceAction action;
      if (auto owner = registry.byODataAction(resource.name, action)) {
        requirePost(req, resource.name);
        auto body = requestBody(req);
        auto id = fieldString(body, "id");
        if (id.length == 0)
          throw new ResourceError(400, "MissingParameter", resource.name ~ " requires the parameter 'id'");
        return writeEntity(res, 200, "$metadata#" ~ owner.setName ~ "/$entity",
          owner.invoke(identity, id, action.name, body));
      }

      if (resource.name == "Statistics") {
        if (req.method != HTTPMethod.GET)
          throw new ResourceError(405, "MethodNotAllowed", "Statistics is read-only");
        return writeEntity(res, 200, "$metadata#Statistics", registry.statistics(identity.tenantId));
      }

      auto adapter = registry.bySet(resource.name);
      if (adapter is null)
        throw new ResourceError(404, "NotFound", "Unknown resource '" ~ resource.name ~ "'");
      auto context = "$metadata#" ~ adapter.setName;

      switch (req.method) {
      case HTTPMethod.GET:
        if (!resource.hasKey)
          return readCollection(req, res, adapter, identity, resource.countOnly);
        auto row = adapter.get(identity.tenantId, resource.key);
        if (row.type == Json.Type.null_)
          throw new ResourceError(404, "NotFound", adapter.typeName ~ " '" ~ resource.key ~ "' not found");
        return writeEntity(res, 200, context ~ "/$entity", row);

      case HTTPMethod.POST:
        if (resource.hasKey)
          throw new ResourceError(405, "MethodNotAllowed", "POST to an entity is not supported");
        auto created = adapter.create(identity, registry.withReferences(identity.tenantId, requestBody(req)));
        res.headers["Location"] = basePath ~ "/" ~ adapter.setName ~ "('" ~ created["id"].get!string ~ "')";
        return writeEntity(res, 201, context ~ "/$entity", created);

      case HTTPMethod.PATCH, HTTPMethod.PUT:
        if (!resource.hasKey)
          throw new ResourceError(405, "MethodNotAllowed", "Updates need an entity key");
        return writeEntity(res, 200, context ~ "/$entity",
          adapter.update(identity, resource.key, registry.withReferences(identity.tenantId, requestBody(req))));

      case HTTPMethod.DELETE:
        if (!resource.hasKey)
          throw new ResourceError(405, "MethodNotAllowed", "DELETE needs an entity key");
        adapter.remove(identity, resource.key);
        res.headers["OData-Version"] = "4.0";
        res.statusCode = 204;
        res.writeVoidBody();
        return;

      default:
        throw new ResourceError(405, "MethodNotAllowed", "Method not allowed");
      }
    } catch (ResourceError e) {
      writeError(res, e.status, e.code, e.msg);
    } catch (ODataQueryException e) {
      writeError(res, 400, "InvalidQuery", e.msg);
    } catch (Exception e) {
      logError("connectivity odata: %s", e.msg);
      writeError(res, 500, "InternalError", e.msg);
    }
  }

  protected void readCollection(HTTPServerRequest req, HTTPServerResponse res,
      IResourceAdapter adapter, RequestIdentity identity, bool countOnly) {
    auto names = adapter.fields.map!(f => f.name).array;
    auto query = parseQuery((name) => req.query.get(name, ""), names, "id");

    size_t total;
    auto page = query.apply(adapter.list(identity.tenantId), total);

    if (countOnly) {
      res.headers["OData-Version"] = "4.0";
      res.writeBody(total.to!string, 200, "text/plain");
      return;
    }

    auto context = "$metadata#" ~ adapter.setName;
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

  // ── helpers ────────────────────────────────────────────────────────────

  protected static void requirePost(HTTPServerRequest req, string name) {
    if (req.method != HTTPMethod.POST)
      throw new ResourceError(405, "MethodNotAllowed", name ~ " must be invoked with POST");
  }

  protected Json requestBody(HTTPServerRequest req) {
    Json body;
    try
      body = req.json;
    catch (Exception e)
      throw new ResourceError(400, "InvalidPayload", "Request body is not valid JSON: " ~ e.msg);
    if (body.type == Json.Type.undefined || body.type == Json.Type.null_)
      return Json.emptyObject;
    if (body.type != Json.Type.object)
      throw new ResourceError(400, "InvalidPayload", "Request body must be a JSON object");
    // drop OData control information ("@odata.etag", ...)
    auto clean = Json.emptyObject;
    foreach (k, v; body.get!(Json[string]))
      if (!k.startsWith("@"))
        clean[k] = v;
    return clean;
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

  auto r = parseResourcePath("/Destinations");
  assert(r.name == "Destinations" && !r.hasKey && !r.countOnly);

  r = parseResourcePath("Destinations('a''b')");
  assert(r.name == "Destinations" && r.hasKey && r.key == "a'b");

  r = parseResourcePath("CloudConnectors(id='x')");
  assert(r.key == "x");

  r = parseResourcePath("ServiceChannels/$count");
  assert(r.countOnly && r.name == "ServiceChannels");

  r = parseResourcePath("RunHealthCheck()");
  assert(r.name == "RunHealthCheck" && !r.hasKey);
}
