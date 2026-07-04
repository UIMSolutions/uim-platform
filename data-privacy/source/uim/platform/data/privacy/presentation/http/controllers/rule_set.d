/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.rule_set;
// import uim.platform.data.privacy.application.usecases.manage.rule_sets;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.rule_set;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class RuleSetController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateRuleSetRequest r;
    r.tenantId = tenantId;
    r.contextId = data.getString("businessContextId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.priority = data.getInteger("priority");

    auto result = usecase.createRuleSet(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Rule set created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.listRuleSets(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Rule sets retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RuleSetId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid rule set ID", 400);

    auto entry = usecase.getRuleSet(tenantId, id);
    if (entry.isNull)
      return errorResponse("Rule set not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Rule set retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    UpdateRuleSetRequest r;
    r.tenantId = tenantId;
    r.setId = RuleSetId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.priority = data.getInteger("priority");

    auto result = usecase.updateRuleSet(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Rule set updated successfully", "Updated", 200, responseData);
  }

  protected Json activateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RuleSetId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid rule set ID", 400);

    auto result = usecase.activateRuleSet(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Rule set activated successfully", "Activated", 200, responseData);
  }

  mixin(HandleTemplate!("handleActivate", "activateHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RuleSetId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid rule set ID", 400);

    auto result = usecase.deleteRuleSet(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Rule set deleted successfully", "Deleted", 200, responseData);
  }
}
