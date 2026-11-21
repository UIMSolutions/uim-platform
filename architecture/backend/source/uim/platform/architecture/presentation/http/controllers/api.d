/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST API (JSON) under <apiPath> (default /api/v1). A thin facade over the
/// OData engine, so validation, scopes and errors are identical to OData:
///
///   GET    /building-blocks[?kind=&status=&owner=&tag=&search=]   list
///   GET    /building-blocks/types/{kind}                            list by kind (1.x)
///   POST   /building-blocks                                        create
///   GET    /building-blocks/{id}                                   read
///   PATCH  /building-blocks/{id}   (PUT accepted)                  change
///   DELETE /building-blocks/{id}                                   delete
///   POST   /building-blocks/{id}/status   {"status": "approved"}  lifecycle transition
///   GET    /building-blocks/{id}/relationships                     relationships of a block
///   GET    /building-blocks/{id}/impact                            impact analysis
///   GET|POST /relationships, GET|PATCH|DELETE /relationships/{id}
///   GET    /analysis/statistics | /analysis/gaps | /analysis/orphans | /analysis/phase-out-risks
///   GET    /element-types                                          ArchiMate catalogue
///   GET    /export/archimate[?modelName=]                          ArchiMate exchange file (XML)
///   POST   /seed                                                   demo landscape
/// Errors: {"error": {"code": "...", "message": "..."}} with 400/401/403/404/405/409/422.
module uim.platform.architecture.presentation.http.controllers.api;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.service.presentation.odata;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ArchitectureApiController {
  protected ODataEngine engine;
  protected SecuritySetup security;
  protected string root;

  this(ODataEngine engine, SecuritySetup security, string apiPath) {
    this.engine = engine;
    this.security = security;
    this.root = "/" ~ apiPath.strip("/");
  }

  void registerRoutes(URLRouter router) {
    auto b = root ~ "/building-blocks";
    router.get(b, &listBlocks);
    router.get(b ~ "/types/:kind", &listBlocksOfKind);
    router.post(b, &createBlock);
    router.get(b ~ "/:id", &getBlock);
    router.patch(b ~ "/:id", &updateBlock);
    router.put(b ~ "/:id", &updateBlock);
    router.delete_(b ~ "/:id", &deleteBlock);
    router.post(b ~ "/:id/status", &changeStatus);
    router.get(b ~ "/:id/relationships", &blockRelationships);
    router.get(b ~ "/:id/impact", &impact);

    auto r = root ~ "/relationships";
    router.get(r, &listRelationships);
    router.post(r, &createRelationship);
    router.get(r ~ "/:id", &getRelationship);
    router.patch(r ~ "/:id", &updateRelationship);
    router.put(r ~ "/:id", &updateRelationship);
    router.delete_(r ~ "/:id", &deleteRelationship);

    router.get(root ~ "/analysis/statistics", &statistics);
    router.get(root ~ "/analysis/gaps", (HTTPServerRequest req, HTTPServerResponse res) { listSet(req, res, "Gaps"); });
    router.get(root ~ "/analysis/orphans", (HTTPServerRequest req, HTTPServerResponse res) {
      listSet(req, res, "Orphans");
    });
    router.get(root ~ "/analysis/phase-out-risks", (HTTPServerRequest req, HTTPServerResponse res) {
      listSet(req, res, "PhaseOutRisks");
    });
    router.get(root ~ "/element-types", (HTTPServerRequest req, HTTPServerResponse res) {
      listSet(req, res, "ElementTypes");
    });
    router.get(root ~ "/export/archimate", &exportArchiMate);
    router.post(root ~ "/seed", &seed);
  }

  // ── building blocks ─────────────────────────────────────────────────────

  void listBlocks(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 200, (ctx) {
      auto kind = req.query.get("kind", req.query.get("type", ""));
      return collection(filterBlocks(engine.query(ctx, "BuildingBlocks", noOptions).rows, kind, req.query.get("status", ""),
        req.query.get("owner", ""), req.query.get("tag", ""), req.query.get("search", "")));
    }, req);
  }

  void listBlocksOfKind(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 200, (ctx) => collection(filterBlocks(engine.query(ctx, "BuildingBlocks", noOptions).rows,
        req.params["kind"], "", "", "", "")), req);
  }

  void getBlock(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 200, (ctx) => engine.read(ctx, "BuildingBlocks", req.params["id"]), req);
  }

  void createBlock(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 201, (ctx) => engine.create(ctx, "BuildingBlocks", legacyAliases(bodyOf(req))), req);
  }

  void updateBlock(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 200, (ctx) {
      auto payload = legacyAliases(bodyOf(req));
      foreach (fixed; ["kind", "id"])
        if (fixed in payload)
          payload.remove(fixed);
      if ("status" in payload) {
        // lifecycle decisions are a separate, separately authorized operation
        auto current = engine.read(ctx, "BuildingBlocks", req.params["id"]);
        if (payload["status"] != current["status"])
          throw EntitySetException.invalid("Change the status with POST " ~ root ~ "/building-blocks/"
              ~ req.params["id"] ~ "/status");
        payload.remove("status");
      }
      return engine.update(ctx, "BuildingBlocks", req.params["id"], payload);
    }, req);
  }

  void deleteBlock(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 204, (ctx) {
      engine.remove(ctx, "BuildingBlocks", req.params["id"]);
      return Json(null);
    }, req);
  }

  void changeStatus(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 200, (ctx) {
      auto body = bodyOf(req);
      return engine.invoke(ctx, "ChangeStatus", Json([
          "id": Json(req.params["id"]), "status": "status" in body ? body["status"] : Json(null)
        ]));
    }, req);
  }

  void blockRelationships(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 200, (ctx) {
      auto id = req.params["id"];
      engine.read(ctx, "BuildingBlocks", id); // 404
      return collection(engine.query(ctx, "Relationships", noOptions).rows.filter!(r => r["sourceId"].get!string == id
        || r["targetId"].get!string == id).array);
    }, req);
  }

  void impact(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 200, (ctx) => collection(engine.invoke(ctx, "AnalyzeImpact", Json(["id": Json(req.params["id"])]))
        .get!(Json[])), req);
  }

  // ── relationships ───────────────────────────────────────────────────────

  void listRelationships(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 200, (ctx) {
      auto type = req.query.get("type", "");
      auto block = req.query.get("blockId", "");
      Json[] rows;
      foreach (r; engine.query(ctx, "Relationships", noOptions).rows) {
        if (type.length && enumKey(r["type"].get!string) != enumKey(type))
          continue;
        if (block.length && r["sourceId"].get!string != block && r["targetId"].get!string != block)
          continue;
        rows ~= r;
      }
      return collection(rows);
    }, req);
  }

  void createRelationship(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 201, (ctx) => engine.create(ctx, "Relationships", bodyOf(req)), req);
  }

  void getRelationship(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 200, (ctx) => engine.read(ctx, "Relationships", req.params["id"]), req);
  }

  void updateRelationship(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 200, (ctx) => engine.update(ctx, "Relationships", req.params["id"], bodyOf(req)), req);
  }

  void deleteRelationship(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 204, (ctx) {
      engine.remove(ctx, "Relationships", req.params["id"]);
      return Json(null);
    }, req);
  }

  // ── analysis, catalogue, export ─────────────────────────────────────────

  void statistics(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 200, (ctx) => engine.read(ctx, "Statistics", ""), req);
  }

  void listSet(HTTPServerRequest req, HTTPServerResponse res, string set) {
    respond(res, 200, (ctx) => collection(engine.query(ctx, set, noOptions).rows), req);
  }

  void exportArchiMate(HTTPServerRequest req, HTTPServerResponse res) @trusted {
    try {
      auto ctx = authorized(req);
      auto r = engine.invoke(ctx, "ExportArchiMate", Json(["modelName": Json(req.query.get("modelName", ""))]));
      res.headers["Content-Disposition"] = `attachment; filename="` ~ r["fileName"].get!string ~ `"`;
      res.writeBody(r["content"].get!string, "application/xml; charset=UTF-8");
    } catch (Exception e)
      writeError(res, e);
  }

  void seed(HTTPServerRequest req, HTTPServerResponse res) {
    respond(res, 201, (ctx) => engine.invoke(ctx, "SeedDemoData", Json.emptyObject), req);
  }

  // ── plumbing ────────────────────────────────────────────────────────────

  protected static string[string] noOptions() {
    string[string] none;
    return none;
  }

  protected RequestContext authorized(HTTPServerRequest req) {
    auto ctx = security.resolve(req, "rest");
    if (security.requireAuthentication && !ctx.authenticated)
      throw new EntitySetException(401, "Unauthorized", "A valid bearer token is required");
    return ctx;
  }

  protected void respond(HTTPServerResponse res, int status, scope Json delegate(RequestContext) @safe handler,
    HTTPServerRequest req) @trusted {
    try {
      auto result = handler(authorized(req));
      if (status == 204) {
        res.statusCode = 204;
        res.writeVoidBody();
      } else
        res.writeJsonBody(result, status);
    } catch (Exception e)
      writeError(res, e);
  }

  protected static void writeError(HTTPServerResponse res, Exception e) @trusted {
    int status = 500;
    string code = "InternalError";
    string message = e.msg;
    if (auto ese = cast(EntitySetException) e) {
      status = ese.status;
      code = ese.code;
    } else if (auto ae = cast(ArchitectureException) e) {
      auto translatedError = toEntitySetException(ae);
      status = translatedError.status;
      code = translatedError.code;
    } else if (cast(JSONException) e) {
      status = 400;
      code = "BadRequest";
      message = "Malformed JSON: " ~ e.msg;
    } else {
      logServiceEvent("error", "unhandled", Json(["message": Json(e.msg)]));
      message = "Internal error";
    }
    res.writeJsonBody(Json(["error": Json(["code": Json(code), "message": Json(message)])]), status);
  }

  protected static Json bodyOf(HTTPServerRequest req) @trusted {
    auto text = req.bodyReader.readAllUTF8(false, 4 * 1024 * 1024);
    if (text.strip.length == 0)
      return Json.emptyObject;
    auto body = parseJsonString(text);
    if (!body.isObject)
      throw EntitySetException.invalid("Request body must be a JSON object");
    return body;
  }
}

/// {"value": rows, "count": n}
Json collection(Json[] rows) {
  return Json(["value": Json(rows), "count": Json(rows.length)]);
}

/// Accept the field names of the 1.x API: type → kind, title → name,
/// lifecycleState → status (if no status is given), version → versionLabel.
Json legacyAliases(Json payload) @trusted {
  foreach (alias_, name; ["type": "kind", "title": "name", "lifecycleState": "status", "version": "versionLabel",
      "archimateElement": "elementType"]) {
    if (alias_ !in payload)
      continue;
    if (name !in payload)
      payload[name] = payload[alias_];
    payload.remove(alias_);
  }
  return payload;
}

/// Filter block rows by the query parameters (kind accepts ABB, SBB, ...).
Json[] filterBlocks(Json[] rows, string kind, string status, string owner, string tag, string search) {
  auto kindKey = kind.strip.length ? cast(string) parseBlockKind(kind) : "";
  auto statusKey = status.strip.length ? cast(string) parseLifecycleStatus(status) : "";
  Json[] result;
  foreach (r; rows) {
    if (kindKey.length && r["kind"].get!string != kindKey)
      continue;
    if (statusKey.length && r["status"].get!string != statusKey)
      continue;
    if (owner.strip.length && r["owner"].get!string != owner.strip)
      continue;
    if (tag.strip.length && !r["tags"].get!(Json[]).canFind!(t => t.get!string == tag.strip.toLower))
      continue;
    if (search.strip.length && !["id", "name", "description", "capability", "vendor"].any!(k => containsText(r[k].get!string,
        search.strip)))
      continue;
    result ~= r;
  }
  return result;
}

///
unittest {
  auto p = legacyAliases(parseJsonString(`{"type":"technology","title":"Gateway","lifecycleState":"identified","status":"active"}`));
  assert(p["kind"].get!string == "technology" && p["name"].get!string == "Gateway" && p["status"].get!string == "active");
  assert("type" !in p && "lifecycleState" !in p);
}
