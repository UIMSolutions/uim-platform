/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.unification_rules;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;


mixin(ShowModule!());

@safe:
class UnificationRuleController : ManageHttpController {
  private ManageUnificationRulesUseCase usecase;

  this(ManageUnificationRulesUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/composer/rules",          &handleList);
    router.get("/api/v1/composer/rules/*",         &handleGet);
    router.post("/api/v1/composer/rules",          &handleCreate);
    router.post("/api/v1/composer/rules/reorder",  &handleReorder);
    router.put("/api/v1/composer/rules/*",         &handleUpdate);
    router.delete_("/api/v1/composer/rules/*",     &handleDelete);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto item = usecase.getById(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (item.isNull) { writeError(res, 404, "Rule not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    CreateUnificationRuleRequest r;
    r.tenantId    = tenantId;
    r.id          = precheck.id;
    r.name        = data.getString("name");
    r.description = data.getString("description");
    r.priority    = data.getInteger("priority");
    r.model       = data.getString("model");
    r.unique_     = data.getBoolean("unique");
    r.triggerMerge  = data.getBoolean("triggerMerge");
    r.preventMerge  = data.getBoolean("preventMerge");
    r.identifierAttributes = data.getStrings("identifierAttributes");
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleReorder(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    ReorderRulesRequest r;
    r.tenantId  = tenantId;
    r.orderedIds = data.getStrings("orderedIds");
    // Update priority of each rule per ordered list
    foreach (int i, string id; r.orderedIds) {
      auto rule = usecase.getById(r.tenantId, id);
      if (!rule.isNull) {
        UpdateUnificationRuleRequest upd;
        upd.tenantId  = r.tenantId;
        upd.id        = id;
        upd.priority  = i + 1;
        upd.name      = rule.name;
        upd.active    = rule.active;
        upd.unique_   = rule.unique_;
        upd.triggerMerge  = rule.triggerMerge;
        upd.preventMerge  = rule.preventMerge;
        usecase.update(upd);
      }
    }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    UpdateUnificationRuleRequest r;
    r.tenantId    = tenantId;
    r.id          = extractIdFromPath(req.requestPath.to!string);
    r.name        = data.getString("name");
    r.description = data.getString("description");
    r.priority    = data.getInteger("priority");
    r.model       = data.getString("model");
    r.unique_     = data.getBoolean("unique");
    r.triggerMerge  = data.getBoolean("triggerMerge");
    r.preventMerge  = data.getBoolean("preventMerge");
    r.active      = data.getBoolean("active");
    r.identifierAttributes = data.getStrings("identifierAttributes");
    auto result = usecase.update(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
    auto result = usecase.remove(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (!result.success) { writeError(res, 404, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }
}
