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
///   PATCH  <base>/<Set>('<key>')
///   DELETE <base>/<Set>('<key>')           (Sessions / Tokens: revoke)
///   GET    <base>/Statistics               singleton
///   POST   <base>/<Action>                 unbound actions, JSON parameter object
///
/// $batch is not supported — configure the UI5 model with groupId "$direct".
module uim.platform.identity_authentication.presentation.odata.controller;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPMethod;
import vibe.textfilter.urlencode : urlDecode;
import uim.platform.identity_authentication;
import uim.platform.identity_authentication.presentation.odata.model;
import uim.platform.identity_authentication.presentation.odata.metadata;
import uim.platform.identity_authentication.presentation.odata.query;
import uim.platform.identity_authentication.presentation.odata.serializers;

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

/// Result of an action: the payload and its @odata.context.
struct ODataActionResult {
  Json value;
  string context;
  const(ODataEntitySetDef) set;
}

class IdentityODataController {
  protected ODataServiceModel model;
  protected string basePath;
  protected string defaultTenant;
  protected string metadataXml;
  protected IdentityPorts ports;
  protected ITokenService verifier;

  this(IdentityPorts ports, string basePath, string defaultTenant, ITokenService verifier = null) {
    this.ports = ports;
    this.model = identityODataModel();
    this.basePath = basePath.stripRight("/");
    this.defaultTenant = defaultTenant;
    this.verifier = verifier;
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
        req.headers.get("X-Tenant-Id", ""), req.headers.get("X-User-Id", ""), defaultTenant, verifier);
      auto ieee754 = ieee754Compatible(req);

      if (model.hasAction(resource.name)) {
        if (req.method != HTTPMethod.POST)
          throw new ODataError(405, "MethodNotAllowed", resource.name ~ " must be invoked with POST");
        auto result = invokeAction(resource.name, identity, optionalBody(req));
        auto value = result.set.name.length ? adapt(result.value, result.set, ieee754) : result.value;
        return writeEntity(res, 200, result.context, value);
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
      logError("identity-authentication odata: %s", e.msg);
      writeError(res, 500, "InternalError", "Internal server error");
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
    case "Users":
      return ports.users.listUsers(t).map!(e => toOData(e)).array;
    case "Groups":
      return ports.groups.listGroups(t).map!(e => toOData(e)).array;
    case "Applications":
      return ports.applications.listApplications(t).map!(e => toOData(e)).array;
    case "Policies":
      return ports.policies.listPolicies(t).map!(e => toOData(e)).array;
    case "RiskRules":
      return ports.riskRules.listRiskRules(t).map!(e => toOData(e)).array;
    case "IdentityProviders":
      return ports.identityProviders.listIdps(t).map!(e => toOData(e)).array;
    case "Sessions":
      return ports.sessions.listSessions(t).map!(e => toOData(e)).array;
    case "Tokens":
      return ports.tokens.listTokens(t).map!(e => toOData(e)).array;
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
    case "Users":
      return wrap(ports.users.getUser(t, UserId(key)));
    case "Groups":
      return wrap(ports.groups.getGroup(t, GroupId(key)));
    case "Applications":
      return wrap(ports.applications.getApplication(t, ApplicationId(key)));
    case "Policies":
      return wrap(ports.policies.getPolicy(t, PolicyId(key)));
    case "RiskRules":
      return wrap(ports.riskRules.getRiskRule(t, RiskRuleId(key)));
    case "IdentityProviders":
      return wrap(ports.identityProviders.getIdp(t, IdpConfigId(key)));
    case "Sessions":
      return wrap(ports.sessions.getSession(t, SessionId(key)));
    case "Tokens":
      return wrap(ports.tokens.getToken(t, TokenId(key)));
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

    switch (set.name) {
    case "Users":
      return requireEntity(set, t, create!UserDTO(d => ports.users.createUser(d)).id);
    case "Groups":
      return requireEntity(set, t, create!GroupDTO(d => ports.groups.createGroup(d)).id);
    case "Applications":
      // the generated client secret is returned exactly once
      auto r = create!ApplicationDTO(d => ports.applications.createApplication(d));
      return toOData(ports.applications.getApplication(t, ApplicationId(r.id)), r.data["clientSecret"].get!string);
    case "Policies":
      return requireEntity(set, t, create!PolicyDTO(d => ports.policies.createPolicy(d)).id);
    case "RiskRules":
      return requireEntity(set, t, create!RiskRuleDTO(d => ports.riskRules.createRiskRule(d)).id);
    case "IdentityProviders":
      return requireEntity(set, t, create!IdpConfigDTO(d => ports.identityProviders.createIdp(d)).id);
    default:
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is read-only");
    }
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
    case "Users":
      merge!UserDTO(ports.users.getUser(t, UserId(key)), (d) {
        d.userId = UserId(key);
        d.password = ""; // passwords change via ResetPassword only
        return ports.users.updateUser(d);
      });
      break;
    case "Groups":
      merge!GroupDTO(ports.groups.getGroup(t, GroupId(key)), (d) {
        d.groupId = GroupId(key);
        return ports.groups.updateGroup(d);
      });
      break;
    case "Applications":
      merge!ApplicationDTO(ports.applications.getApplication(t, ApplicationId(key)), (d) {
        d.applicationId = ApplicationId(key);
        return ports.applications.updateApplication(d);
      });
      break;
    case "Policies":
      merge!PolicyDTO(ports.policies.getPolicy(t, PolicyId(key)), (d) {
        d.policyId = PolicyId(key);
        return ports.policies.updatePolicy(d);
      });
      break;
    case "RiskRules":
      merge!RiskRuleDTO(ports.riskRules.getRiskRule(t, RiskRuleId(key)), (d) {
        d.ruleId = RiskRuleId(key);
        return ports.riskRules.updateRiskRule(d);
      });
      break;
    case "IdentityProviders":
      merge!IdpConfigDTO(ports.identityProviders.getIdp(t, IdpConfigId(key)), (d) {
        d.idpId = IdpConfigId(key);
        return ports.identityProviders.updateIdp(d);
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
    case "Users":
      check(ports.users.deleteUser(t, UserId(key)));
      return;
    case "Groups":
      check(ports.groups.deleteGroup(t, GroupId(key)));
      return;
    case "Applications":
      check(ports.applications.deleteApplication(t, ApplicationId(key)));
      return;
    case "Policies":
      check(ports.policies.deletePolicy(t, PolicyId(key)));
      return;
    case "RiskRules":
      check(ports.riskRules.deleteRiskRule(t, RiskRuleId(key)));
      return;
    case "IdentityProviders":
      check(ports.identityProviders.deleteIdp(t, IdpConfigId(key)));
      return;
    case "Sessions":
      check(ports.sessions.revokeSession(t, SessionId(key)));
      return;
    case "Tokens":
      check(ports.tokens.revokeToken(t, TokenId(key)));
      return;
    default:
      throw new ODataError(405, "MethodNotAllowed", set.name ~ " is not deletable");
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  /// Run an unbound action.
  protected ODataActionResult invokeAction(string name, RequestIdentity identity, Json body) {
    auto t = identity.tenantId;
    auto by = identity.userId;

    string text(string key) {
      string v;
      readString(body, key, v);
      return v;
    }

    string required(string key) {
      auto v = text(key);
      if (v.length == 0)
        throw new ODataError(400, "InvalidPayload", name ~ ": parameter '" ~ key ~ "' is required");
      return v;
    }

    ODataActionResult entity(string setName, string id) {
      auto set = model.find(setName);
      return ODataActionResult(requireEntity(set, t, id), "$metadata#" ~ setName ~ "/$entity", set);
    }

    ODataActionResult complex(string typeName, Json value) {
      return ODataActionResult(value, "$metadata#" ~ model.qualified(typeName), ODataEntitySetDef.init);
    }

    switch (name) {
    case "SetUserStatus": {
        UserStatus status;
        if (!tryParseEnum!UserStatus(required("status"), status))
          throw new ODataError(400, "InvalidPayload", "status must be one of " ~ enumValues!UserStatus().join(", "));
        check(ports.users.setUserStatus(t, UserId(required("id")), status, by));
        return entity("Users", text("id"));
    }
    case "ResetPassword":
      check(ports.users.resetPassword(t, UserId(required("id")), required("newPassword"), by));
      return entity("Users", text("id"));
    case "DisableMfa":
      check(ports.users.disableMfa(t, UserId(required("id")), by));
      return entity("Users", text("id"));
    case "RevokeUserSessions":
      check(ports.sessions.revokeAllForUser(t, UserId(required("id"))));
      return entity("Users", text("id"));
    case "EnrollMfa": {
        MfaType type;
        if (!tryParseEnum!MfaType(required("mfaType"), type))
          throw new ODataError(400, "InvalidPayload", "mfaType must be one of totp, sms, email");
        auto r = check(ports.users.enrollMfa(t, UserId(required("id")), type, by));
        return complex("MfaEnrollment", Json.emptyObject
            .set("id", r.id)
            .set("mfaType", enumValue(type))
            .set("secret", fieldString(r.data, "secret"))
            .set("provisioningUri", fieldString(r.data, "provisioningUri")));
    }
    case "AddGroupMember":
      check(ports.groups.addMember(t, GroupId(required("id")), UserId(required("userId"))));
      return entity("Groups", text("id"));
    case "RemoveGroupMember":
      check(ports.groups.removeMember(t, GroupId(required("id")), UserId(required("userId"))));
      return entity("Groups", text("id"));
    case "RotateClientSecret": {
        auto r = check(ports.applications.rotateClientSecret(t, ApplicationId(required("id")), by));
        auto set = model.find("Applications");
        return ODataActionResult(toOData(ports.applications.getApplication(t, ApplicationId(r.id)),
            r.data["clientSecret"].get!string), "$metadata#Applications/$entity", set);
    }
    case "EvaluateAccess": {
        PolicyEvaluationContext ctx;
        ctx.ipAddress = text("ipAddress");
        ctx.authMethod = parseEnum!AuthMethod(text("authMethod"), AuthMethod.form);
        readBool(body, "mfaUsed", ctx.mfaUsed);
        auto r = check(ports.policies.evaluateAccess(t, ApplicationId(required("applicationId")),
            UserId(required("userId")), ctx));
        return complex("AccessDecision", Json.emptyObject
            .set("granted", r.data["granted"].get!bool)
            .set("denyingPolicies", fieldStrings(r.data, "denyingPolicies").join(", ")));
    }
    case "AssessRisk": {
        RiskEvaluationContext ctx;
        ctx.ipAddress = text("ipAddress");
        ctx.userAgent = text("userAgent");
        auto r = check(ports.riskRules.assess(t, UserId(required("userId")), ctx));
        return complex("RiskAssessment", Json.emptyObject
            .set("riskLevel", fieldString(r.data, "riskLevel"))
            .set("requiredMfa", fieldString(r.data, "requiredMfa"))
            .set("denied", fieldBool(r.data, "denied"))
            .set("triggeredRules", fieldStrings(r.data, "triggeredRules").join(", ")));
    }
    case "PurgeExpired": {
        auto s = check(ports.sessions.purgeExpired(t));
        auto k = check(ports.tokens.purgeExpired(t));
        return complex("PurgeResult", Json.emptyObject
            .set("sessions", cast(int) fieldLong(s.data, "removed"))
            .set("tokens", cast(int) fieldLong(k.data, "removed")));
    }
    default:
      throw new ODataError(404, "NotFound", "Unknown action " ~ name);
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Map a failed use case result to an OData error.
  protected UsecaseResult check(UsecaseResult result) {
    if (result.isSuccess)
      return result;
    auto status = httpStatusOf(result);
    auto code = status == 404 ? "NotFound" : status == 409 ? "Conflict" : status == 401 ? "Unauthorized"
      : status == 403 ? "Forbidden" : status == 422 ? "BusinessRuleViolation" : "BadRequest";
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

  auto r = parseResourcePath("/Users");
  assert(r.name == "Users" && !r.hasKey && !r.countOnly);

  r = parseResourcePath("Users('a''b')");
  assert(r.name == "Users" && r.hasKey && r.key == "a'b");

  r = parseResourcePath("Groups(id='x')");
  assert(r.key == "x");

  r = parseResourcePath("Sessions/$count");
  assert(r.countOnly && r.name == "Sessions");

  r = parseResourcePath("SetUserStatus()");
  assert(r.name == "SetUserStatus" && !r.hasKey);
}

///
unittest {
  mixin(ShowTest!("IdentityODataController actions"));

  auto c = buildContainer(testConfig());
  auto odata = new IdentityODataController(c.ports, "/odata/v4/identity-authentication", "default");
  RequestIdentity who;
  who.tenantId = TenantId("default");
  who.userId = UserId("admin");

  auto users = identityODataModel().find("Users");
  auto created = odata.createEntity(users, who,
    parseJsonString(`{"email": "jane@example.com", "password": "Secret123", "firstName": "Jane"}`));
  auto id = created["id"].get!string;
  assert(created["userName"].get!string == "jane" && created["password"].type == Json.Type.null_);

  auto locked = odata.invokeAction("SetUserStatus", who, parseJsonString(`{"id": "` ~ id ~ `", "status": "locked"}`));
  assert(locked.value["status"].get!string == "locked" && locked.context == "$metadata#Users/$entity");

  auto mfa = odata.invokeAction("EnrollMfa", who, parseJsonString(`{"id": "` ~ id ~ `", "mfaType": "totp"}`));
  assert(mfa.context == "$metadata#uim.ias.MfaEnrollment" && mfa.value["secret"].get!string.length == 32);

  auto apps = identityODataModel().find("Applications");
  auto app = odata.createEntity(apps, who, parseJsonString(`{"name": "Portal", "allowedScopes": "openid profile"}`));
  assert(app["clientSecret"].get!string.length > 20);
  assert(odata.entityOf(apps, who.tenantId, app["id"].get!string)["clientSecret"].type == Json.Type.null_);

  bool rejected;
  try
    odata.invokeAction("SetUserStatus", who, parseJsonString(`{"id": "` ~ id ~ `", "status": "pendingVerification"}`));
  catch (ODataError e)
    rejected = e.status == 422;
  assert(rejected);
}
