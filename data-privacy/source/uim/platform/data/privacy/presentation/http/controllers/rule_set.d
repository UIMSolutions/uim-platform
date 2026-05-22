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
class RuleSetController : PlatformController {
  private ManageRuleSetsUseCase usecase;

  this(ManageRuleSetsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/rule-sets", &handleCreate);
    router.get("/api/v1/rule-sets", &handleList);
    router.get("/api/v1/rule-sets/*", &handleGet);
    router.put("/api/v1/rule-sets/*", &handleUpdate);
    router.post("/api/v1/rule-sets/*/activate", &handleActivate);
    router.delete_("/api/v1/rule-sets/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateRuleSetRequest r;
      r.tenantId = tenantId;
      r.businessContextId = j.getString("businessContextId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.priority = cast(int)jsonLong(j, "priority");

      auto result = usecase.createRuleSet(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Rule set created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto items = usecase.listRuleSets(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Rule sets retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RuleSetId(extractIdFromPath(req.requestURI));

      auto entry = usecase.getRuleSet(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Rule set not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      UpdateRuleSetRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.priority = cast(int)jsonLong(j, "priority");

      auto result = usecase.updateRuleSet(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Rule set updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RuleSetId(extractIdFromPath(req.requestURI));

      auto result = usecase.activateRuleSet(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Rule set activated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RuleSetId(extractIdFromPath(req.requestURI));

      usecase.deleteRuleSet(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

}
