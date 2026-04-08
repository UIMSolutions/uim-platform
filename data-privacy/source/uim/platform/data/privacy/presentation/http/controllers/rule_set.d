/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.rule_set;

// import uim.platform.data.privacy.application.usecases.manage.rule_sets;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.rule_set;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class RuleSetController : SAPController {
  private ManageRuleSetsUseCase uc;

  this(ManageRuleSetsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/rule-sets", &handleCreate);
    router.get("/api/v1/rule-sets", &handleList);
    router.get("/api/v1/rule-sets/*", &handleGetById);
    router.put("/api/v1/rule-sets/*", &handleUpdate);
    router.post("/api/v1/rule-sets/*/activate", &handleActivate);
    router.delete_("/api/v1/rule-sets/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateRuleSetRequest r;
      r.tenantId = req.getTenantId;
      r.businessContextId = j.getString("businessContextId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.priority = cast(int) jsonLong(j, "priority");

      auto result = uc.createRuleSet(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listRuleSets(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getRuleSet(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Rule set not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateRuleSetRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.priority = cast(int) jsonLong(j, "priority");

      auto result = uc.updateRuleSet(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;

      auto result = uc.activateRuleSet(id, tenantId);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      uc.deleteRuleSet(id, tenantId);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(ref const RuleSet e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["businessContextId"] = Json(e.businessContextId);
    j["name"] = Json(e.name);
    j["description"] = Json(e.description);
    j["status"] = Json(e.status.to!string);
    j["priority"] = Json(cast(long) e.priority);
    j["createdAt"] = Json(e.createdAt);
    j["updatedAt"] = Json(e.updatedAt);
    j["activatedAt"] = Json(e.activatedAt);
    return j;
  }
}
