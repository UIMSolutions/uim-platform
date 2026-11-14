/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Shared plumbing of the REST controllers: caller identity, JSON bodies,
/// uniform responses ({"status", "message", "code", "data"}) and generic
/// list / get / create / merge-update handlers.
module uim.platform.identity_authentication.presentation.http.controllers.base;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

alias RouteHandler = void delegate(HTTPServerRequest, HTTPServerResponse) @safe;

abstract class IdentityHttpController {
  protected string basePath;
  protected string defaultTenant;
  protected ITokenService verifier;

  this(string apiPath, string resource, string defaultTenant = "default", ITokenService verifier = null) {
    this.basePath = apiPath.stripRight("/") ~ "/" ~ resource;
    this.defaultTenant = defaultTenant;
    this.verifier = verifier;
  }

  abstract void registerRoutes(URLRouter router);

  // ── request ────────────────────────────────────────────────────────────

  protected RequestIdentity identity(HTTPServerRequest req) {
    return resolveIdentity(req.headers.get("Authorization", ""), req.headers.get("X-Tenant-Id", ""),
      req.headers.get("X-User-Id", ""), defaultTenant, verifier);
  }

  /// The JSON body (an empty object for an empty body).
  protected Json body(HTTPServerRequest req) {
    Json b;
    try
      b = req.json;
    catch (Exception e)
      throw new PayloadException("Request body is not valid JSON: " ~ e.msg);
    if (b.type == Json.Type.undefined || b.type == Json.Type.null_)
      return Json.emptyObject;
    if (b.type != Json.Type.object)
      throw new PayloadException("Request body must be a JSON object");
    return b;
  }

  protected static string param(HTTPServerRequest req, string name) {
    return req.params.get(name, "");
  }

  protected static string query(HTTPServerRequest req, string name, string fallback = "") {
    return req.query.get(name, fallback);
  }

  // ── responses ──────────────────────────────────────────────────────────

  protected static void reply(HTTPServerResponse res, int status, string message, Json data = Json.emptyObject) {
    res.writeJsonBody(Json.emptyObject
        .set("status", status < 400 ? "success" : "error")
        .set("message", message)
        .set("code", status)
        .set("data", data), status);
  }

  protected static void fail(HTTPServerResponse res, int status, string message) {
    res.writeJsonBody(errorResponse(message, status), status);
  }

  protected static void replyResult(HTTPServerResponse res, UsecaseResult r, int successStatus = 200) {
    if (!r.isSuccess)
      return fail(res, httpStatusOf(r), r.message);
    auto data = r.data.type == Json.Type.object ? r.data.clone : Json.emptyObject;
    if (r.id.length)
      data["id"] = r.id;
    reply(res, r.code == 201 ? 201 : successStatus, r.message, data);
  }

  protected static void replyList(T)(HTTPServerResponse res, T[] items, string what) {
    auto resources = Json.emptyArray;
    foreach (i; items)
      resources ~= i.toJson;
    reply(res, 200, what ~ " retrieved", Json.emptyObject.set("count", items.length).set("resources", resources));
  }

  protected static void replyOne(T)(HTTPServerResponse res, T item, string what, string id) {
    if (item.isNull)
      return fail(res, 404, what ~ " '" ~ id ~ "' not found");
    reply(res, 200, what ~ " retrieved", item.toJson);
  }

  /// Run a handler; payload errors → 400, anything else → 500.
  protected void guard(HTTPServerResponse res, scope void delegate() @safe action) {
    try
      action();
    catch (PayloadException e)
      fail(res, 400, e.msg);
    catch (Exception e) {
      logError("identity-authentication http: %s", e.msg);
      fail(res, 500, "Internal server error");
    }
  }

  // ── generic create / update ────────────────────────────────────────────

  /// POST: read the payload into a fresh DTO, stamp tenant and creator.
  protected void createWith(TDTO)(HTTPServerRequest req, HTTPServerResponse res,
      scope UsecaseResult delegate(TDTO) @safe call) {
    guard(res, () {
      auto who = identity(req);
      TDTO dto;
      readPayload(dto, body(req));
      dto.tenantId = who.tenantId;
      dto.createdBy = who.userId;
      replyResult(res, call(dto), 201);
    });
  }

  /// PUT / PATCH: start from the stored entity, overlay the supplied fields.
  protected void mergeWith(TDTO, TEntity)(HTTPServerRequest req, HTTPServerResponse res, string what,
      scope TEntity delegate(TenantId, string) @safe load, scope UsecaseResult delegate(TDTO) @safe call) {
    guard(res, () {
      auto who = identity(req);
      auto id = param(req, "id");
      auto current = load(who.tenantId, id);
      if (current.isNull)
        return fail(res, 404, what ~ " '" ~ id ~ "' not found");
      auto dto = TDTO.fromEntity(current);
      readPayload(dto, body(req));
      dto.tenantId = who.tenantId;
      dto.updatedBy = who.userId;
      replyResult(res, call(dto));
    });
  }

  /// Register GET/PUT/PATCH/DELETE on <base>/:id and GET/POST on <base>.
  protected void crudRoutes(URLRouter router, RouteHandler list, RouteHandler get, RouteHandler create,
      RouteHandler update, RouteHandler remove) {
    router.get(basePath, list);
    router.post(basePath, create);
    router.get(basePath ~ "/:id", get);
    router.put(basePath ~ "/:id", update);
    router.patch(basePath ~ "/:id", update);
    router.delete_(basePath ~ "/:id", remove);
  }
}
