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
///   POST   <base>/EvaluateAccess           unbound action {"bucketId", "principal", "action", "key"}
///   POST   <base>/CheckCors                unbound action {"bucketId", "origin", "method", "requestHeaders": [...]}
///   POST   <base>/VerifyCredentials        unbound action {"accessKeyId", "secretAccessKey"}
///   POST   <base>/ApplyLifecycle           unbound action {"bucketId"} ("" = all buckets)
///   POST   <base>/PutObjectContent         unbound action {"bucketId", "key", "content", "contentEncoding", ...}
///                                          upload / overwrite (data plane: policies apply)
///   POST   <base>/<Action><Type>           unbound actions, e.g. ArchiveStorageObject {"id": "..."}
///
/// Reference data (Regions, StorageClasses) is read-only, ObjectVersions are
/// created by writing objects. Object content is uploaded through the
/// StorageObjects "content" property (text or base64) or the REST content API.
/// Edm.Int64 values are written as strings when the client asks for
/// IEEE754Compatible=true (UI5 does).
///
/// $batch is not supported — configure the UI5 model with groupId "$direct".
module uim.platform.object_store.presentation.odata.controller;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPMethod;
import vibe.textfilter.urlencode : urlDecode;
import uim.platform.object_store;
import uim.platform.object_store.presentation.resources;
import uim.platform.object_store.presentation.odata.model;
import uim.platform.object_store.presentation.odata.metadata;
import uim.platform.object_store.presentation.odata.query;

mixin(ShowModule!());

@safe:

/// The parsed resource path (after the service root).
struct ODataResource {
  string name; /// entity set, singleton or action
  string key; /// entity key, if addressed
  bool hasKey;
  bool countOnly; /// <Set>/$count
}

/// Parse "Buckets", "Buckets/$count", "Buckets('a')", "Regions(id='eu-central-1')".
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
  r.hasKey = r.key.length > 0; // "ProcessJobs()" is an action call, not a key
  return r;
}

class ObjectStoreODataController {
  protected ResourceRegistry registry;
  protected ODataServiceModel model;
  protected string basePath;
  protected string defaultTenant;
  protected string metadataXml;

  this(ResourceRegistry registry, string basePath, string defaultTenant) {
    this.registry = registry;
    this.model = objectStoreODataModel(registry);
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
      if (auto op = resource.name in unboundActions) {
        requirePost(req, resource.name);
        auto body = requestBody(req);
        Json payload;
        switch (resource.name) {
        case "EvaluateAccess":
          payload = registry.evaluateAccess(identity.tenantId, body);
          break;
        case "CheckCors":
          payload = registry.checkCors(identity.tenantId, body);
          break;
        case "VerifyCredentials":
          payload = registry.verifyCredentials(identity.tenantId, body);
          break;
        default:
          payload = registry.applyLifecycle(identity, body);
        }
        payload["@odata.context"] = "$metadata#" ~ model.qualified(*op);
        return writeJson(res, 200, ieee754(req, payload, *op));
      }
      if (resource.name == "PutObjectContent") {
        requirePost(req, resource.name);
        return writeEntity(res, 200, "$metadata#StorageObjects/$entity",
          ieee754(req, registry.putContentJson(identity, requestBody(req)), "StorageObjects"));
      }
      ResourceAction action;
      if (auto owner = registry.byODataAction(resource.name, action)) {
        requirePost(req, resource.name);
        auto body = requestBody(req);
        auto id = fieldString(body, "id");
        if (id.length == 0)
          throw new ResourceError(400, "MissingParameter", resource.name ~ " requires the parameter 'id'");
        return writeEntity(res, 200, "$metadata#" ~ owner.setName ~ "/$entity",
          ieee754(req, owner.invoke(identity, id, action.name, registry.withReferences(identity.tenantId, body)),
          owner.setName));
      }

      if (resource.name == "Statistics") {
        if (req.method != HTTPMethod.GET)
          throw new ResourceError(405, "MethodNotAllowed", "Statistics is read-only");
        return writeEntity(res, 200, "$metadata#Statistics", ieee754(req, registry.statistics(identity.tenantId),
          "Statistics"));
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
        return writeEntity(res, 200, context ~ "/$entity", ieee754(req, row, adapter.setName));

      case HTTPMethod.POST:
        if (resource.hasKey)
          throw new ResourceError(405, "MethodNotAllowed", "POST to an entity is not supported");
        auto created = adapter.create(identity, registry.withReferences(identity.tenantId, requestBody(req)));
        res.headers["Location"] = basePath ~ "/" ~ adapter.setName ~ "('" ~ created["id"].get!string ~ "')";
        return writeEntity(res, 201, context ~ "/$entity", ieee754(req, created, adapter.setName));

      case HTTPMethod.PATCH, HTTPMethod.PUT:
        if (!resource.hasKey)
          throw new ResourceError(405, "MethodNotAllowed", "Updates need an entity key");
        return writeEntity(res, 200, context ~ "/$entity", ieee754(req,
          adapter.update(identity, resource.key, registry.withReferences(identity.tenantId, requestBody(req))),
          adapter.setName));

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
      logError("object-store odata: %s", e.msg);
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
      value ~= ieee754(req, row, adapter.setName);
    payload["value"] = value;
    writeJson(res, 200, payload);
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// Unbound actions and their return (complex) type.
  protected static immutable string[string] unboundActions;
  shared static this() {
    unboundActions = [
      "EvaluateAccess": "AccessDecision", "CheckCors": "CorsDecision", "VerifyCredentials": "CredentialCheck",
      "ApplyLifecycle": "LifecycleRunReport"
    ];
  }

  /// The properties of an entity set, singleton or complex type (by name).
  protected const(ODataPropertyDef)[] propertiesOf(string name) {
    if (model.has(name))
      return model.find(name).properties;
    foreach (c; model.complexTypes)
      if (c.name == name)
        return c.properties;
    return null;
  }

  /// Write Edm.Int64 values as strings if the client is IEEE754Compatible (UI5
  /// is) — also inside complex type values. `name`: set, singleton or complex type.
  protected Json ieee754(HTTPServerRequest req, Json row, string name) {
    if (!ieee754Compatible(req))
      return row;
    return stringifyInt64(row, name, 0);
  }

  protected Json stringifyInt64(Json row, string name, int depth) {
    if (row.type != Json.Type.object || depth > 4)
      return row;
    auto ns = model.namespace_ ~ ".";
    foreach (p; propertiesOf(name)) {
      auto v = p.name in row;
      if (v is null)
        continue;
      if (p.type == Edm.int64 && !p.collection && (v.type == Json.Type.int_ || v.type == Json.Type.bigInt))
        row[p.name] = Json(jsonText(*v));
      else if (p.type.startsWith(ns)) {
        auto nested = p.type[ns.length .. $];
        if (v.type == Json.Type.array) {
          auto arr = Json.emptyArray;
          foreach (item; v.get!(Json[]))
            arr ~= stringifyInt64(item, nested, depth + 1);
          row[p.name] = arr;
        } else
          row[p.name] = stringifyInt64(*v, nested, depth + 1);
      }
    }
    return row;
  }

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

  auto r = parseResourcePath("/Buckets");
  assert(r.name == "Buckets" && !r.hasKey && !r.countOnly);

  r = parseResourcePath("Buckets('a''b')");
  assert(r.name == "Buckets" && r.hasKey && r.key == "a'b");

  r = parseResourcePath("Regions(id='eu-central-1')");
  assert(r.key == "eu-central-1");

  r = parseResourcePath("StorageObjects/$count");
  assert(r.countOnly && r.name == "StorageObjects");

  r = parseResourcePath("ApplyLifecycle()");
  assert(r.name == "ApplyLifecycle" && !r.hasKey);
}
