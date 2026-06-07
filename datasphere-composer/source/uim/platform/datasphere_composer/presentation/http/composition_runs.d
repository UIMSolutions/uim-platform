/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.composition_runs;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;


// mixin(ShowModule!());

@safe:
class CompositionRunController : ManageHttpController {
  private ManageCompositionRunsUseCase usecase;

  this(ManageCompositionRunsUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/composer/runs",           &handleList);
    router.get("/api/v1/composer/runs/*",          &handleGet);
    router.post("/api/v1/composer/runs",           &handleStart);
    router.post("/api/v1/composer/runs/*/action",  &handleAction);
    router.delete_("/api/v1/composer/runs/*",      &handleDelete);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) { writeError(res, 404, "Composition run not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleStart(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    StartCompositionRunRequest r;
    r.tenantId      = tenantId;
    r.id            = precheck.id;
    r.name          = data.getString("name");
    r.triggeredBy   = data.getString("triggeredBy");
    r.dataProductIds = data.getStrings("dataProductIds");
    auto result = usecase.start(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleAction(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    CompositionRunActionRequest r;
    r.tenantId = tenantId;
    r.id       = extractIdFromPath(req.requestPath.to!string);
    r.action   = data.getString("action");
    auto result = usecase.performAction(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
    auto result = usecase.remove(tenantId, extractIdFromPath(req.requestPath.to!string));
    if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Composition run deleted successfully", "Deleted", 200, responseData);
  }
}
